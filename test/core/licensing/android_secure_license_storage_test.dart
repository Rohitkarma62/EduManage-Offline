import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:edumanage_offline/core/licensing/android_secure_license_storage.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.edumanage/license_storage');
  final values = <String, String>{};

  setUp(() {
    values.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final key = call.arguments['key'] as String;
      switch (call.method) {
        case 'read':
          return values[key];
        case 'write':
          values[key] = call.arguments['value'] as String;
          return null;
        case 'delete':
          values.remove(key);
          return null;
        default:
          throw MissingPluginException();
      }
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('device identity is generated once and persisted', () async {
    final storage = AndroidSecureLicenseStorage(channel: channel);
    final first = await storage.readOrCreateDeviceId();
    final second = await storage.readOrCreateDeviceId();

    expect(first, isNotEmpty);
    expect(first, second);
    expect(first, matches(RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
  });

  test('license token and trusted time use separate secure keys', () async {
    final storage = AndroidSecureLicenseStorage(channel: channel);
    final time = DateTime.utc(2026, 10, 31, 12);

    await storage.writeToken('signed.token');
    await storage.writeLastTrustedTime(time);

    expect(await storage.readToken(), 'signed.token');
    expect(await storage.readLastTrustedTime(), time);
    await storage.clearToken();
    expect(await storage.readToken(), isNull);
    expect(await storage.readLastTrustedTime(), time);
  });
}
