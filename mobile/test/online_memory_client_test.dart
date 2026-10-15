import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/online/online_models.dart';
import 'package:rivalrooms/online/online_session.dart';

void main() {
  test('two Flutter sessions play Memory Match through the server', () async {
    final server = await Process.start(
      'node',
      ['src/index.js'],
      workingDirectory: '../server',
      environment: {...Platform.environment, 'PORT': '3017', 'HOST': '127.0.0.1', 'AUTH_MODE': 'dev', 'NODE_ENV': 'development'},
    );
    addTearDown(() {
      server.kill();
    });
    server.stderr.transform(utf8.decoder).listen((_) {});
    final ready = await _waitForHealth();
    expect(ready, isTrue);

    final host = OnlineSession(signIn: (url, name) async => const GuestLogin(token: 'dev:host1:Host', userId: 'host1', username: 'Host'), initialUrl: 'http://127.0.0.1:3017', initialName: 'Host');
    final guest = OnlineSession(signIn: (url, name) async => const GuestLogin(token: 'dev:guest1:Guest', userId: 'guest1', username: 'Guest'), initialUrl: 'http://127.0.0.1:3017', initialName: 'Guest');
    addTearDown(() { host.dispose(); guest.dispose(); });

    await host.createRoom(maxPlayers: 2, cardCount: 8);
    expect(host.room?.gameType, 'memory');
    expect(host.failure, isNull);
    await guest.joinRoom(host.room!.code);
    await _until(() => guest.room?.players.length == 2 && host.room?.players.length == 2, () => 'join host=${host.room?.players.length} guest=${guest.room?.players.length} hf=${host.failure} gf=${guest.failure} gl=${guest.link}');
    await guest.setReady(true);
    await _until(() => host.room!.players.every((p) => p.ready), () => 'ready ${host.room?.players.map((p) => p.ready)} hf=${host.failure}');
    await host.startGame();
    await _until(() => host.memory != null && guest.memory != null, () => 'start hf=${host.failure} gf=${guest.failure} status=${host.room?.status}');
    expect(host.memory!.cards.every((card) => card.value == null), isTrue);

    final seen = <String, List<int>>{};
    void note(MemoryView? board) {
      if (board == null) return;
      for (final card in board.cards) {
        if (card.value == null || card.matched) continue;
        final ids = seen.putIfAbsent(card.value!, () => []);
        if (!ids.contains(card.id)) ids.add(card.id);
      }
    }
    host.addListener(() => note(host.memory));
    var guard = 0;
    while (host.memory!.phase != 'finished' && guard++ < 30) {
      await _until(() => host.memory!.phase == 'turn' || host.memory!.phase == 'finished', () => 'phase ${host.memory?.phase} turn ${host.memory?.turn} hf=${host.failure}');
      if (host.memory!.phase == 'finished') break;
      final actor = host.memory!.turn == 'host1' ? host : guest;
      note(host.memory);
      if (host.memory!.selected.length == 1) {
        final open = host.memory!.selected.first;
        final value = host.memory!.cards.firstWhere((card) => card.id == open).value;
        final known = (seen[value] ?? []).where((id) => id != open);
        final other = host.memory!.cards.where((card) => !card.matched && card.id != open);
        await actor.flip(known.isEmpty ? other.first.id : known.first);
        continue;
      }
      final unmatched = host.memory!.cards.where((card) => !card.matched).toList();
      List<int>? pair;
      for (final ids in seen.values) {
        final live = ids.where((id) => unmatched.any((card) => card.id == id)).toList();
        if (live.length >= 2) { pair = live.take(2).toList(); break; }
      }
      if (pair != null) {
        await actor.flip(pair[0]);
        await _until(() => host.memory!.selected.length == 1 || host.memory!.phase != 'turn', () => 'pair ${host.memory?.selected} ${host.failure}');
        await actor.flip(pair[1]);
        continue;
      }
      final knownIds = seen.values.expand((ids) => ids).toSet();
      final unknown = unmatched.where((card) => !knownIds.contains(card.id)).toList();
      await actor.flip(unknown.first.id);
      await _until(() => host.memory!.cards.firstWhere((card) => card.id == unknown.first.id).value != null, () => 'reveal ${host.memory?.selected} ${host.failure}');
      note(host.memory);
      final value = host.memory!.cards.firstWhere((card) => card.id == unknown.first.id).value!;
      final known = (seen[value] ?? []).where((id) => id != unknown.first.id && unmatched.any((card) => card.id == id));
      final second = known.isEmpty ? unknown.firstWhere((card) => card.id != unknown.first.id).id : known.first;
      await actor.flip(second);
    }
    await _until(() => host.result != null && guest.result != null, () => 'result phase=${host.memory?.phase}');
    expect(host.memory!.phase, 'finished');
    expect(guest.memory!.scores, host.memory!.scores);
    final before = host.memory!.scores['host1'];
    await host.flip(0);
    await Future<void>.delayed(const Duration(milliseconds: 200));
    expect(host.memory!.scores['host1'], before);
  }, timeout: const Timeout(Duration(seconds: 30)));
}

Future<bool> _waitForHealth() async {
  final client = HttpClient();
  try {
    for (var i = 0; i < 40; i++) {
      try {
        final request = await client.getUrl(Uri.parse('http://127.0.0.1:3017/health')).timeout(const Duration(seconds: 1));
        final response = await request.close().timeout(const Duration(seconds: 1));
        if (response.statusCode == 200) return true;
      } catch (_) {}
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<void> _until(bool Function() pred, String Function() why) async {
  final start = DateTime.now();
  while (!pred()) {
    if (DateTime.now().difference(start) > const Duration(seconds: 8)) fail(why());
    await Future<void>.delayed(const Duration(milliseconds: 30));
  }
}
