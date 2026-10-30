import 'package:edumanage_offline/core/licensing/license_claims.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses an unactivated license with required customer and device limit',
      () {
    final claims = LicenseClaims.fromJson({
      'license_id': 'LIC-001',
      'customer': 'Demo Institute',
      'device_limit': 1,
      'issued_at': 1793380000,
      'activated_at': null,
      'expires_at': null,
      'device_id_hash': null,
    });

    expect(claims.licenseId, 'LIC-001');
    expect(claims.customer, 'Demo Institute');
    expect(claims.deviceLimit, 1);
    expect(claims.activatedAt, isNull);
    expect(claims.expiresAt, isNull);
  });

  test('parses activation-based expiry and device binding', () {
    final claims = LicenseClaims.fromJson({
      'license_id': 'LIC-002',
      'customer': 'Institute',
      'device_limit': 1,
      'issued_at': 1793380000,
      'activated_at': 1793380100,
      'expires_at': 1799432100,
      'device_id_hash': 'abc123',
    });

    expect(claims.activatedAt, isNotNull);
    expect(claims.expiresAt!.isAfter(claims.activatedAt!), isTrue);
    expect(claims.deviceIdHash, 'abc123');
  });

  test('rejects missing customer and partial activation', () {
    expect(
      () => LicenseClaims.fromJson({
        'license_id': 'LIC-003',
        'customer': ' ',
        'device_limit': 1,
        'issued_at': 1793380000,
      }),
      throwsFormatException,
    );
    expect(
      () => LicenseClaims.fromJson({
        'license_id': 'LIC-005',
        'customer': 'Institute',
        'device_limit': 1,
        'issued_at': 1793380000,
        'activated_at': 1793380100,
        'expires_at': null,
        'device_id_hash': null,
      }),
      throwsFormatException,
    );
  });

  test('rejects expiry before activation', () {
    expect(
      () => LicenseClaims.fromJson({
        'license_id': 'LIC-006',
        'customer': 'Institute',
        'device_limit': 1,
        'issued_at': 1793380000,
        'activated_at': 1793380100,
        'expires_at': 1793380000,
        'device_id_hash': 'abc123',
      }),
      throwsFormatException,
    );
  });
}
