import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

import 'license_service.dart';
import 'license_verifier.dart';

/// Android Keystore-backed storage. Values are encrypted natively with an
/// AES-GCM key whose material never leaves Android Keystore.
class AndroidSecureLicenseStorage
    implements LicenseTokenStore, LicenseDeviceIdentity, TrustedTimeStore {
  AndroidSecureLicenseStorage({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel('com.edumanage/license_storage');

  final MethodChannel _channel;
  static const _tokenKey = 'license.token';
  static const _deviceIdKey = 'license.device_id';
  static const _trustedTimeKey = 'license.trusted_time';

  Future<String?> _read(String key) =>
      _channel.invokeMethod<String>('read', {'key': key});

  Future<void> _write(String key, String value) =>
      _channel.invokeMethod<void>('write', {'key': key, 'value': value});

  Future<void> _delete(String key) =>
      _channel.invokeMethod<void>('delete', {'key': key});

  @override
  Future<String?> readToken() => _read(_tokenKey);

  @override
  Future<void> writeToken(String token) => _write(_tokenKey, token);

  @override
  Future<void> clearToken() => _delete(_tokenKey);

  @override
  Future<String> readOrCreateDeviceId() async {
    final existing = await _read(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;
    final created = const Uuid().v4();
    await _write(_deviceIdKey, created);
    return created;
  }

  @override
  Future<DateTime?> readLastTrustedTime() async {
    final value = await _read(_trustedTimeKey);
    return value == null ? null : DateTime.tryParse(value)?.toUtc();
  }

  @override
  Future<void> writeLastTrustedTime(DateTime value) =>
      _write(_trustedTimeKey, value.toUtc().toIso8601String());
}
