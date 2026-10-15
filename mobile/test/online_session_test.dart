import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:rivalrooms/online/online_models.dart';
import 'package:rivalrooms/online/online_session.dart';
import 'package:rivalrooms/online/room_transport.dart';

class ScriptedTransport implements RoomTransport {
  ScriptedTransport(this.replies);
  final List<Object> replies;
  final List<Map<String, dynamic>> sent = [];
  int n = 0;
  final _events = StreamController<Object>.broadcast();
  @override
  Stream<Object> get events => _events.stream;
  @override
  Future<void> connect({required String url, required String token}) async {}
  @override
  Future<Map<String, dynamic>> request(String event, Map<String, dynamic> payload) async {
    sent.add({'event': event, ...payload});
    if (n >= replies.length) throw TimeoutException(event);
    final next = replies[n++];
    if (next is TimeoutException) throw next;
    return Map<String, dynamic>.from(next as Map);
  }
  @override
  Future<void> disconnect() async {}
}

void main() {
  Future<GuestLogin> login(String url, String name) async => GuestLogin(token: 't', userId: 'me', username: name);

  test('a rejected room reply does not open a room', () async {
    final transport = ScriptedTransport([
      {'ok': true, 'room': null},
      {'ok': false, 'error': 'ROOM_FULL'},
    ]);
    final session = OnlineSession(transport: transport, signIn: login, initialUrl: 'http://127.0.0.1:9', initialName: 'Ada');
    await session.createRoom(maxPlayers: 2, cardCount: 8);
    expect(session.room, isNull);
    expect(session.failure, 'That room is full.');
    expect(session.link, OnlineLink.connected);
    session.dispose();
  });

  test('create room waits for the server acknowledgement', () async {
    final transport = ScriptedTransport([
      {'ok': true, 'room': null},
      {'ok': true, 'room': {'code': 'AB12CD', 'gameType': 'memory', 'hostId': 'me', 'status': 'lobby', 'maxPlayers': 2, 'memoryCardCount': 8, 'players': [{'userId': 'me', 'username': 'Ada', 'ready': true, 'connected': true}]}},
    ]);
    final session = OnlineSession(transport: transport, signIn: login, initialUrl: 'http://127.0.0.1:9', initialName: 'Ada');
    await session.createRoom(maxPlayers: 2, cardCount: 8);
    expect(session.room?.code, 'AB12CD');
    expect(transport.sent.map((e) => e['event']), ['resume_session', 'create_room']);
    session.dispose();
  });

  test('a missing acknowledgement stays a connection failure', () async {
    final transport = ScriptedTransport([
      {'ok': true, 'room': null},
      TimeoutException('create_room'),
    ]);
    final session = OnlineSession(transport: transport, signIn: login, initialUrl: 'http://127.0.0.1:9', initialName: 'Ada');
    await session.createRoom(maxPlayers: 2, cardCount: 8);
    expect(session.room, isNull);
    expect(session.failure, contains('did not answer'));
    session.dispose();
  });

  test('memory flips use increasing sequence numbers', () async {
    final transport = ScriptedTransport([
      {'ok': true},
      {'ok': true},
    ]);
    final session = OnlineSession(transport: transport, signIn: login, initialUrl: 'http://127.0.0.1:9', initialName: 'Ada');
    session.link = OnlineLink.connected;
    session.userId = 'me';
    transport.events; // subscribed in the constructor
    session.memory = MemoryView(phase: 'turn', turn: 'me', myId: 'me', scores: const {}, cards: const [], selected: const []);
    await session.flip(3);
    session.memory = MemoryView(phase: 'turn', turn: 'me', myId: 'me', scores: const {}, cards: const [], selected: const []);
    await session.flip(4);
    final seqs = transport.sent.map((e) => e['seq'] as int).toList();
    expect(seqs[1], greaterThan(seqs[0]));
    session.dispose();
  });

  test('an empty server address does not pretend the room connected', () async {
    final session = OnlineSession(transport: ScriptedTransport([]), signIn: login, initialUrl: '', initialName: 'Ada');
    await session.connect();
    expect(session.link, OnlineLink.failed);
    expect(session.failure, 'Enter the server address, then try again.');
    expect(session.room, isNull);
    session.dispose();
  });
}
