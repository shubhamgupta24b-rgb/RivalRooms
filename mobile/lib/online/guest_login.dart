import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'online_models.dart';

Future<GuestLogin> requestGuestLogin(String url, String name, {bool allowDevAuth = false}) async {
  final uri = Uri.parse(url).replace(path: '/auth/guest');
  final client = HttpClient();
  try {
    final request = await client.postUrl(uri).timeout(const Duration(seconds: 8));
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(jsonEncode({'name': _cleanName(name)})));
    final response = await request.close().timeout(const Duration(seconds: 8));
    final raw = await response.transform(utf8.decoder).join();
    final body = raw.isEmpty ? const <String, dynamic>{} : jsonDecode(raw);
    if (response.statusCode == 200 && body is Map && body['token'] is String && body['userId'] is String) {
      return GuestLogin(token: body['token'] as String, userId: body['userId'] as String, username: '${body['username'] ?? name}');
    }
    if (response.statusCode == 404 && allowDevAuth) return devGuestLogin(name);
    if (response.statusCode == 404) throw OnlineException('This server does not accept guest sign-in.');
    if (response.statusCode == 503) throw OnlineException('Guest sign-in is not configured on this server.');
    throw OnlineException('The online connection failed.');
  } on OnlineException {
    rethrow;
  } on TimeoutException {
    throw OnlineException('The server did not answer. Check the address and retry.');
  } on SocketException {
    throw OnlineException('The online connection failed.');
  } finally {
    client.close(force: true);
  }
}

String _cleanName(String name) {
  final cleaned = name.replaceAll(RegExp(r'[^\p{L}\p{N} _.-]', unicode: true), '').trim();
  if (cleaned.isEmpty) return 'Guest';
  return cleaned.length <= 20 ? cleaned : cleaned.substring(0, 20);
}

final _random = Random.secure();
String? _devUid;

GuestLogin devGuestLogin(String name) {
  _devUid ??= List.generate(12, (_) => 'abcdefghijklmnopqrstuvwxyz0123456789'[_random.nextInt(36)]).join();
  final shown = _cleanName(name);
  return GuestLogin(token: 'dev:$_devUid:$shown', userId: _devUid!, username: shown);
}
