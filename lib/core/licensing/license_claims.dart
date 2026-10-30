import 'dart:convert';

/// Claims covered by the server's Ed25519 signature.
class LicenseClaims {
  const LicenseClaims({
    required this.licenseId,
    required this.customer,
    required this.deviceLimit,
    required this.issuedAt,
    required this.activatedAt,
    required this.expiresAt,
    required this.deviceIdHash,
  });

  final String licenseId;
  final String customer;
  final int deviceLimit;
  final DateTime issuedAt;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final String? deviceIdHash;

  factory LicenseClaims.fromJson(Map<String, dynamic> json) {
    DateTime? date(String key) {
      final value = json[key];
      if (value == null) return null;
      if (value is! int || value <= 0) {
        throw FormatException('Invalid $key claim.');
      }
      return DateTime.fromMillisecondsSinceEpoch(value * 1000, isUtc: true);
    }

    final licenseId = json['license_id'];
    final customer = json['customer'];
    final deviceLimit = json['device_limit'];
    if (licenseId is! String || licenseId.trim().isEmpty) {
      throw const FormatException('Missing license_id claim.');
    }
    if (customer is! String || customer.trim().isEmpty) {
      throw const FormatException('Missing customer claim.');
    }
    if (deviceLimit is! int) {
      throw const FormatException('Missing device_limit claim.');
    }
    final issuedAt = date('issued_at');
    if (issuedAt == null) {
      throw const FormatException('Missing issued_at claim.');
    }
    final activatedAt = date('activated_at');
    final expiresAt = date('expires_at');
    final deviceIdHash = json['device_id_hash'];
    if (deviceIdHash != null &&
        (deviceIdHash is! String || deviceIdHash.trim().isEmpty)) {
      throw const FormatException('Invalid device_id_hash claim.');
    }
    if ((activatedAt == null) != (expiresAt == null) ||
        (activatedAt == null) != (deviceIdHash == null)) {
      throw const FormatException('Incomplete activation claims.');
    }
    if (activatedAt != null && !expiresAt!.isAfter(activatedAt)) {
      throw const FormatException('License expiry must follow activation.');
    }

    return LicenseClaims(
      licenseId: licenseId,
      customer: customer,
      deviceLimit: deviceLimit,
      issuedAt: issuedAt,
      activatedAt: activatedAt,
      expiresAt: expiresAt,
      deviceIdHash: deviceIdHash as String?,
    );
  }

  static Map<String, dynamic> decodePayload(List<int> bytes) {
    final decoded = jsonDecode(utf8.decode(bytes));
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('License payload must be a JSON object.');
    }
    return decoded;
  }
}
