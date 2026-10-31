import 'dart:convert';

import 'license_api_client.dart';
import 'license_claims.dart';
import 'license_verifier.dart';

/// Implement with platform-protected storage and an app-scoped device ID
/// before enabling licensing in a production build.
abstract interface class LicenseTokenStore {
  Future<String?> readToken();
  Future<void> writeToken(String token);
  Future<void> clearToken();
}

abstract interface class LicenseDeviceIdentity {
  Future<String> readOrCreateDeviceId();
}

class LicenseService {
  LicenseService(
      {required LicenseApiClient api,
      required LicenseTokenStore tokenStore,
      required LicenseDeviceIdentity deviceIdentity,
      required LicenseVerifier verifier,
      required TrustedTimeStore trustedTimeStore})
      : _api = api,
        _tokenStore = tokenStore,
        _deviceIdentity = deviceIdentity,
        _verifier = verifier,
        _trustedTimeStore = trustedTimeStore;

  final LicenseApiClient _api;
  final LicenseTokenStore _tokenStore;
  final LicenseDeviceIdentity _deviceIdentity;
  final LicenseVerifier _verifier;
  final TrustedTimeStore _trustedTimeStore;

  Future<LicenseVerification> activate(String issuedToken) async {
    final claims = _claimsFromToken(issuedToken);
    final deviceId = await _deviceIdentity.readOrCreateDeviceId();
    final activatedToken = await _api.activate(
        licenseId: claims.licenseId, token: issuedToken, deviceId: deviceId);
    final result =
        await _verifier.verify(token: activatedToken, deviceId: deviceId);
    if (!result.isActive) {
      throw LicenseApiException(
          result.message ?? 'Activated license verification failed.');
    }
    await _tokenStore.writeToken(activatedToken);
    return result;
  }

  Future<LicenseVerification> verifyOffline() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      return const LicenseVerification(
          status: LicenseStatus.activationRequired,
          message:
              'Enter the issued license token to activate this institute.');
    }
    final deviceId = await _deviceIdentity.readOrCreateDeviceId();
    return _verifier.verify(token: token, deviceId: deviceId);
  }

  /// Server validation is authoritative for revocation. Network failures are
  /// surfaced; the caller can still display the last locally verified state.
  Future<LicenseVerification> synchronize() async {
    final token = await _tokenStore.readToken();
    if (token == null || token.isEmpty) {
      return const LicenseVerification(
          status: LicenseStatus.activationRequired,
          message: 'No activated license is stored on this device.');
    }
    final claims = _claimsFromToken(token);
    final deviceId = await _deviceIdentity.readOrCreateDeviceId();
    final serverTime = await _api.validate(
        licenseId: claims.licenseId, token: token, deviceId: deviceId);
    await _trustedTimeStore.writeLastTrustedTime(serverTime);
    return _verifier.verify(token: token, deviceId: deviceId, now: serverTime);
  }

  Future<void> clear() => _tokenStore.clearToken();

  LicenseClaims _claimsFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 2) {
      throw const FormatException('Malformed license token.');
    }
    try {
      final bytes = base64Url.decode(base64Url.normalize(parts.first));
      return LicenseClaims.fromJson(LicenseClaims.decodePayload(bytes));
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Malformed license token payload.');
    }
  }
}
