import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/licensing/android_secure_license_storage.dart';
import '../../../core/licensing/license_api_client.dart';
import '../../../core/licensing/license_service.dart';
import '../../../core/licensing/license_verifier.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  State<LicenseScreen> createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  static const _apiBaseUrl = String.fromEnvironment('LICENSE_API_BASE_URL');
  static const _publicKey =
      String.fromEnvironment('LICENSE_ED25519_PUBLIC_KEY');

  final _tokenController = TextEditingController();
  final _storage = AndroidSecureLicenseStorage();
  LicenseService? _service;
  LicenseVerification? _verification;
  String? _configurationError;
  String? _message;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      if (_apiBaseUrl.isEmpty || _publicKey.isEmpty) {
        setState(() => _configurationError =
            'Licensing is not configured for this build. Contact the app administrator.');
        return;
      }
      final key = base64Url.decode(base64Url.normalize(_publicKey));
      if (key.length != 32) {
        throw const FormatException('The Ed25519 public key must be 32 bytes.');
      }
      final api = LicenseApiClient(
        baseUri: Uri.parse(_apiBaseUrl),
        transport: IoLicenseApiTransport(),
      );
      _service = LicenseService(
        api: api,
        tokenStore: _storage,
        deviceIdentity: _storage,
        verifier: LicenseVerifier(
          publicKeyBytes: key,
          trustedTimeStore: _storage,
        ),
        trustedTimeStore: _storage,
      );
      final result = await _service!.verifyOffline();
      if (mounted) setState(() => _verification = result);
    } catch (error) {
      if (mounted) setState(() => _configurationError = error.toString());
    }
  }

  Future<void> _run(Future<LicenseVerification> Function() action) async {
    if (_service == null || _busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      final result = await action();
      if (mounted) {
        setState(() {
          _verification = result;
          _message = result.message;
        });
      }
    } catch (error) {
      if (mounted) setState(() => _message = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final verification = _verification;
    final claims = verification?.claims;
    return Scaffold(
      appBar: AppBar(title: const Text('License activation')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('License status',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(_configurationError ??
                      (verification == null
                          ? 'Checking this device…'
                          : verification.status.name)),
                  if (claims != null) ...[
                    Text('Institute: ${claims.customer}'),
                    Text(
                        'Expires: ${claims.expiresAt?.toLocal().toString() ?? 'Not activated'}'),
                  ],
                  if (_configurationError != null) ...[
                    const SizedBox(height: 8),
                    const Text('Activation remains disabled until a production '
                        'HTTPS API URL and the matching Ed25519 public key are '
                        'provided at build time.'),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _tokenController,
            minLines: 2,
            maxLines: 4,
            autocorrect: false,
            enableSuggestions: false,
            decoration: const InputDecoration(
              labelText: 'Issued license token',
              hintText: 'Paste the token supplied by your administrator',
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _busy ||
                    _service == null ||
                    _tokenController.text.trim().isEmpty
                ? null
                : () => _run(
                    () => _service!.activate(_tokenController.text.trim())),
            child: Text(_busy ? 'Please wait…' : 'Activate license'),
          ),
          OutlinedButton(
            onPressed: _busy || _service == null
                ? null
                : () => _run(_service!.verifyOffline),
            child: const Text('Verify offline'),
          ),
          OutlinedButton(
            onPressed: _busy || _service == null
                ? null
                : () => _run(_service!.synchronize),
            child: const Text('Sync with licensing server'),
          ),
          if (_message != null) ...[
            const SizedBox(height: 12),
            Text(_message!),
          ],
        ],
      ),
    );
  }
}
