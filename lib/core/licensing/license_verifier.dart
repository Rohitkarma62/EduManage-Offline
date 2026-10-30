import 'dart:convert';

import 'package:cryptography/cryptography.dart';
import 'package:crypto/crypto.dart' as hash;

import 'license_claims.dart';

enum LicenseStatus {
  active,
  activationRequired,
  expired,
  invalid,
  deviceMismatch,
  clockRollback,
}

class LicenseVerification {
  const LicenseVerification({
    required this.status,
    this.claims,
    this.message,
  });

  final LicenseStatus status;
  final LicenseClaims? claims;
  final String? message;

  bool get isActive => status == LicenseStatus.active;
}

/// Production implementations must persist this value in platform-protected
/// storage. Keeping storage behind an interface makes the verifier testable.
abstract interface class TrustedTimeStore {
  Future<DateTime?> readLastTrustedTime();
  Future<void> writeLastTrustedTime(DateTime value);
}

/// Verifies compact tokens in the form payload.signature. The signature is
/// Ed25519 over the exact UTF-8 payload bytes.
class LicenseVerifier {
  LicenseVerifier({
    required List<int> publicKeyBytes,
    required TrustedTimeStore trustedTimeStore,
    this.clockRollbackTolerance = const Duration(minutes: 5),
  })  : _publicKey = SimplePublicKey(
          publicKeyBytes,
          type: KeyPairType.ed25519,
        ),
        _trustedTimeStore = trustedTimeStore {
    if (publicKeyBytes.length != 32) {
      throw ArgumentError.value(
        publicKeyBytes.length,
        'publicKeyBytes',
        'An Ed25519 public key must be exactly 32 bytes.',
      );
    }
  }

  final SimplePublicKey _publicKey;
  final TrustedTimeStore _trustedTimeStore;
  final Duration clockRollbackTolerance;
  final Ed25519 _algorithm = Ed25519();

  Future<LicenseVerification> verify({
    required String token,
    required String deviceId,
    DateTime? now,
  }) async {
    try {
      final parts = token.split('.');
      if (parts.length != 2 || deviceId.trim().isEmpty) {
        return const LicenseVerification(
          status: LicenseStatus.invalid,
          message: 'Malformed license token or device identifier.',
        );
      }
      final payloadBytes = _decodeBase64Url(parts[0]);
      final signatureBytes = _decodeBase64Url(parts[1]);
      final signature = Signature(signatureBytes, publicKey: _publicKey);
      final validSignature = await _algorithm.verify(
        payloadBytes,
        signature: signature,
      );
      if (!validSignature) {
        return const LicenseVerification(
          status: LicenseStatus.invalid,
          message: 'License signature is not valid.',
        );
      }

      final claims = LicenseClaims.fromJson(
        LicenseClaims.decodePayload(payloadBytes),
      );
      if (claims.deviceLimit != 1) {
        return const LicenseVerification(
          status: LicenseStatus.invalid,
          message: 'This app supports licenses for one device only.',
        );
      }
      if (claims.activatedAt == null) {
        return LicenseVerification(
          status: LicenseStatus.activationRequired,
          claims: claims,
          message: 'Activate this license while connected to the internet.',
        );
      }

      final expectedDeviceHash =
          hash.sha256.convert(utf8.encode(deviceId)).toString();
      if (claims.deviceIdHash != expectedDeviceHash) {
        return LicenseVerification(
          status: LicenseStatus.deviceMismatch,
          claims: claims,
          message: 'This license is activated on a different device.',
        );
      }

      final currentTime = (now ?? DateTime.now()).toUtc();
      final lastTrustedTime =
          (await _trustedTimeStore.readLastTrustedTime())?.toUtc();
      if (lastTrustedTime != null &&
          currentTime.isBefore(
            lastTrustedTime.subtract(clockRollbackTolerance),
          )) {
        return LicenseVerification(
          status: LicenseStatus.clockRollback,
          claims: claims,
          message:
              'The device clock moved backwards. Connect to the internet to revalidate the license.',
        );
      }

      if (!currentTime.isBefore(claims.expiresAt!)) {
        return LicenseVerification(
          status: LicenseStatus.expired,
          claims: claims,
          message: 'This license has expired.',
        );
      }

      final trustedTime =
          lastTrustedTime != null && lastTrustedTime.isAfter(currentTime)
              ? lastTrustedTime
              : currentTime;
      await _trustedTimeStore.writeLastTrustedTime(trustedTime);

      return LicenseVerification(
        status: LicenseStatus.active,
        claims: claims,
      );
    } on FormatException catch (error) {
      return LicenseVerification(
        status: LicenseStatus.invalid,
        message: error.message,
      );
    } on ArgumentError catch (error) {
      return LicenseVerification(
        status: LicenseStatus.invalid,
        message: error.message?.toString() ?? 'Invalid license.',
      );
    } catch (_) {
      return const LicenseVerification(
        status: LicenseStatus.invalid,
        message: 'License verification failed.',
      );
    }
  }

  List<int> _decodeBase64Url(String value) =>
      base64Url.decode(base64Url.normalize(value));
}
