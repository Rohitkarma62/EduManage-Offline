import 'package:edumanage_offline/core/licensing/license_api_client.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeTransport implements LicenseApiTransport {
  FakeTransport(this.response);
  final Map<String, dynamic> response;
  Uri? uri;
  Map<String, dynamic>? body;
  @override
  Future<Map<String, dynamic>> post(Uri uri, {required Map<String, dynamic> body}) async {
    this.uri = uri;
    this.body = body;
    return response;
  }
  @override
  Future<void> close() async {}
}

void main() {
  test('activation sends token and device id to app-facing endpoint', () async {
    final transport = FakeTransport({'token': 'activated.payload'});
    final api = LicenseApiClient(baseUri: Uri.parse('https://licensing.example.com'),
        transport: transport);
    expect(await api.activate(licenseId: 'license-123', token: 'issued.payload',
        deviceId: 'device-abc'), 'activated.payload');
    expect(transport.uri, Uri.parse(
        'https://licensing.example.com/v1/licenses/license-123/activate'));
    expect(transport.body, {'token': 'issued.payload', 'device_id': 'device-abc'});
  });

  test('validation returns server trusted time in UTC', () async {
    final transport = FakeTransport({'status': 'active',
        'server_time': '2026-10-31T10:00:00+00:00'});
    final api = LicenseApiClient(baseUri: Uri.parse('https://licensing.example.com/'),
        transport: transport);
    final time = await api.validate(licenseId: 'license-123', token: 'signed.payload',
        deviceId: 'device-abc');
    expect(time, DateTime.utc(2026, 10, 31, 10));
  });

  test('rejects insecure non-local API URLs', () {
    expect(() => LicenseApiClient(baseUri: Uri.parse('http://licensing.example.com'),
        transport: FakeTransport({})), throwsArgumentError);
  });

  test('surfaces server revocation status', () async {
    final api = LicenseApiClient(baseUri: Uri.parse('https://licensing.example.com'),
        transport: FakeTransport({'status': 'revoked',
          'server_time': '2026-10-31T10:00:00Z'}));
    expect(() => api.validate(licenseId: 'license-123', token: 'signed.payload',
        deviceId: 'device-abc'), throwsA(isA<LicenseApiException>().having(
          (e) => e.serverStatus, 'serverStatus', 'revoked')));
  });
}
