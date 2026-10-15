import 'dart:async';
import 'package:flutter/foundation.dart';
import 'app_config.dart';
import 'game_socket.dart';
import 'guest_login.dart';
import 'online_models.dart';
import 'room_transport.dart';

enum OnlineLink { idle, connecting, connected, failed }

class OnlineSession extends ChangeNotifier {
  OnlineSession({RoomTransport? transport, Future<GuestLogin> Function(String url, String name)? signIn, String? initialUrl, String? initialName})
      : _transport = transport ?? GameSocket(),
        _signIn = signIn,
        serverUrl = (initialUrl ?? AppConfig.serverUrl).trim(),
        displayName = (initialName ?? 'Guest').trim() {
    _sub = _transport.events.listen(_onEvent);
  }

  final RoomTransport _transport;
  final Future<GuestLogin> Function(String url, String name)? _signIn;
  StreamSubscription<Object>? _sub;
  String serverUrl;
  String displayName;
  String? userId, failure;
  OnlineLink link = OnlineLink.idle;
  RoomSnapshot? room;
  MemoryView? memory;
  Map<String, dynamic>? result;
  bool submitting = false;
  bool _hadRoom = false;
  int _seq = DateTime.now().millisecondsSinceEpoch;

  bool get isHost => room != null && room!.hostId == userId;

  Future<void> connect() async {
    final url = serverUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      link = OnlineLink.failed;
      failure = 'Enter the server address, then try again.';
      notifyListeners();
      return;
    }
    serverUrl = url;
    link = OnlineLink.connecting;
    failure = null;
    notifyListeners();
    try {
      final login = _signIn != null ? await _signIn(url, displayName) : await requestGuestLogin(url, displayName, allowDevAuth: AppConfig.allowDevAuth);
      userId = login.userId;
      displayName = login.username;
      await _transport.connect(url: url, token: login.token);
      link = OnlineLink.connected;
      failure = null;
      notifyListeners();
      await _resume();
    } on OnlineException catch (e) {
      link = OnlineLink.failed;
      failure = e.message;
      notifyListeners();
    } on TimeoutException {
      link = OnlineLink.failed;
      failure = 'The server did not answer. Check the address and retry.';
      notifyListeners();
    } catch (_) {
      link = OnlineLink.failed;
      failure = 'The online connection failed.';
      notifyListeners();
    }
  }

  Future<void> createRoom({required int maxPlayers, required int cardCount}) => _enter('create_room', {
    'gameType': 'memory',
    'maxPlayers': maxPlayers,
    'memoryCardCount': cardCount,
  });

  Future<void> joinRoom(String code) => _enter('join_room', {'code': code.trim()});

  Future<void> quickPlay() => _enter('quick_play', {'gameType': 'memory'});

  Future<void> setReady(bool ready) async {
    await _act(ready ? 'player_ready' : 'player_unready', {});
  }

  Future<void> startGame() async {
    await _act('start_game', {});
  }

  Future<void> flip(int id) async {
    if (submitting || memory == null || memory!.phase != 'turn' || memory!.turn != userId) return;
    final seq = ++_seq;
    await _act('game_action', {'type': 'memory:flip', 'seq': seq, 'payload': {'id': id}});
  }

  Future<void> rematch() async {
    await _act('next_game', {'gameType': 'memory'});
  }

  Future<void> returnToLobby() async {
    await _act('return_to_lobby', {});
  }

  Future<void> leave() async {
    if (link == OnlineLink.connected && room != null) {
      try { await _request('leave_room', {}); } catch (_) {}
    }
    room = null;
    memory = null;
    result = null;
    _hadRoom = false;
    notifyListeners();
  }

  Future<void> _enter(String event, Map<String, dynamic> payload) async {
    if (link != OnlineLink.connected) await connect();
    if (link != OnlineLink.connected) return;
    try {
      final reply = await _request(event, payload);
      _applyRoom(reply['room']);
      failure = null;
    } on OnlineException catch (e) {
      failure = e.message;
    } on TimeoutException {
      failure = 'The server did not answer. Check the address and retry.';
    }
    notifyListeners();
  }

  Future<void> _act(String event, Map<String, dynamic> payload) async {
    if (link != OnlineLink.connected) {
      failure = 'The online connection failed.';
      notifyListeners();
      return;
    }
    try {
      final reply = await _request(event, payload);
      if (reply['room'] is Map) _applyRoom(reply['room']);
      failure = null;
    } on OnlineException catch (e) {
      failure = e.message;
    } on TimeoutException {
      failure = 'The server did not answer. Check the address and retry.';
    }
    notifyListeners();
  }

  Future<Map<String, dynamic>> _request(String event, Map<String, dynamic> payload) async {
    if (submitting) throw OnlineException('Wait for the last request to finish.');
    submitting = true;
    notifyListeners();
    try {
      final reply = await _transport.request(event, payload);
      if (reply['ok'] != true) throw OnlineException(explainServer(reply));
      return reply;
    } finally {
      submitting = false;
    }
  }

  Future<void> _resume() async {
    try {
      final reply = await _transport.request('resume_session', {});
      if (reply['ok'] != true) return;
      if (reply['room'] == null) {
        if (_hadRoom) {
          room = null;
          memory = null;
          failure = 'The match is no longer on the server.';
        }
      } else {
        _applyRoom(reply['room']);
      }
      notifyListeners();
    } catch (_) {}
  }

  void _onEvent(Object event) {
    if (event is OnlineConnected && link == OnlineLink.connected) {
      _resume();
      return;
    }
    if (event is OnlineConnectFailed) {
      link = OnlineLink.failed;
      failure = event.message;
      notifyListeners();
      return;
    }
    if (event is OnlineDisconnected) {
      if (link == OnlineLink.connected) failure = 'Reconnecting…';
      notifyListeners();
      return;
    }
    if (event is OnlineReplaced) {
      link = OnlineLink.failed;
      failure = 'This player signed in somewhere else.';
      notifyListeners();
      return;
    }
    if (event is OnlineRoomEvent) {
      room = event.room;
      _hadRoom = true;
      if (room!.playing) result = null;
      notifyListeners();
    } else if (event is OnlineGameEvent) {
      if (event.state['gameType'] == 'memory') memory = MemoryView.fromJson(event.state);
      notifyListeners();
    } else if (event is OnlineFinishedEvent) {
      result = event.result;
      notifyListeners();
    } else if (event is OnlineAborted) {
      failure = 'The match ended because a player left.';
      notifyListeners();
    }
  }

  void _applyRoom(dynamic raw) {
    if (raw is! Map) return;
    room = RoomSnapshot.fromJson(Map<String, dynamic>.from(raw));
    _hadRoom = true;
  }

  @override
  void dispose() {
    _sub?.cancel();
    _transport.disconnect();
    super.dispose();
  }
}
