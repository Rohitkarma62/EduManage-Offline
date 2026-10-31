import 'dart:async';
import 'dart:convert';
import 'dart:io';

abstract interface class LicenseApiTransport {
  Future<Map<String, dynamic>> post(Uri uri,
      {required Map<String, dynamic> body});
  Future<void> close();
}

class IoLicenseApiTransport implements LicenseApiTransport {
  IoLicenseApiTransport({HttpClient? client})
      : _client = client ?? HttpClient();
  final HttpClient _client;

  @override
  Future<Map<String, dynamic>> post(Uri uri,
      {required Map<String, dynamic> body}) async {
    final request =
        await _client.postUrl(uri).timeout(const Duration(seconds: 15));
    request.headers.contentType = ContentType.json;
    request.write(jsonEncode(body));
    final response = await request.close().timeout(const Duration(seconds: 15));
    final text = await response.transform(utf8.decoder).join();
    Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(text);
      if (value is! Map<String, dynamic>) throw const FormatException();
      decoded = value;
    } on FormatException {
      throw const LicenseApiException(
          'The licensing server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final status = decoded['status'];
      final error = decoded['error'];
      throw LicenseApiException(
        status is String
            ? 'License request rejected: $status.'
            : error is String
                ? 'License request failed: $error.'
                : 'License request failed (${response.statusCode}).',
        statusCode: response.statusCode,
        serverStatus: status is String ? status : null,
      );
    }
    return decoded;
  }

  @override
  Future<void> close() async => _client.close(force: true);
}

class LicenseApiException implements Exception {
  const LicenseApiException(this.message, {this.statusCode, this.serverStatus});
  final String message;
  final int? statusCode;
  final String? serverStatus;
  @override
  String toString() => message;
}

/// App-facing client only. Admin credentials never belong in the Flutter app.
class LicenseApiClient {
  LicenseApiClient(
      {required Uri baseUri, required LicenseApiTransport transport})
      : _baseUri = _validateBaseUri(baseUri),
        _transport = transport;

  final Uri _baseUri;
  final LicenseApiTransport _transport;

  static Uri _validateBaseUri(Uri uri) {
    final localHttp = uri.scheme == 'http' &&
        (uri.host == 'localhost' || uri.host == '127.0.0.1');
    if ((uri.scheme != 'https' && !localHttp) ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.query.isNotEmpty ||
        uri.fragment.isNotEmpty) {
      throw ArgumentError.value(uri, 'baseUri',
          'Use HTTPS (HTTP is allowed only for localhost tests).');
    }
    return uri.replace(
        path: uri.path.endsWith('/')
            ? uri.path.substring(0, uri.path.length - 1)
            : uri.path);
  }

  Uri _licenseUri(String id, String action) => _baseUri.replace(
      path: '${_baseUri.path}/v1/licenses/${Uri.encodeComponent(id)}/$action');

  Future<String> activate(
      {required String licenseId,
      required String token,
      required String deviceId}) async {
    final response = await _transport.post(_licenseUri(licenseId, 'activate'),
        body: {'token': token, 'device_id': deviceId});
    final activated = response['token'];
    if (activated is! String || activated.isEmpty) {
      throw const LicenseApiException(
          'The server did not return an activated token.');
    }
    return activated;
  }

  Future<DateTime> validate(
      {required String licenseId,
      required String token,
      required String deviceId}) async {
    final response = await _transport.post(_licenseUri(licenseId, 'validate'),
        body: {'token': token, 'device_id': deviceId});
    if (response['status'] != 'active') {
      final status = response['status'];
      throw LicenseApiException(
          'License is not active: ${status ?? 'unknown'}.',
          serverStatus: status is String ? status : null);
    }
    final rawTime = response['server_time'];
    final parsed = rawTime is String ? DateTime.tryParse(rawTime) : null;
    if (parsed == null) {
      throw const LicenseApiException(
          'The server returned invalid trusted time.');
    }
    return parsed.toUtc();
  }

  Future<void> close() => _transport.close();
}
