import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'online_models.dart';
import 'room_transport.dart';

class GameSocket implements RoomTransport {
  io.Socket? _socket;
  final _events = StreamController<Object>.broadcast();
  @override
  Stream<Object> get events => _events.stream;

  @override
  Future<void> connect({required String url, required String token}) async {
    await disconnect();
    final completer = Completer<void>();
    final socket = io.io(url, io.OptionBuilder()
      .setTransports(['websocket'])
      .disableAutoConnect()
      .enableForceNew()
      .disableMultiplex()
      .enableReconnection()
      .setReconnectionAttempts(6)
      .setReconnectionDelay(400)
      .setReconnectionDelayMax(8000)
      .setTimeout(8000)
      .setAuth({'token': token})
      .build());
    _socket = socket;
    socket.onConnect((_) {
      if (!completer.isCompleted) completer.complete();
      _events.add(OnlineConnected());
    });
    socket.onConnectError((data) {
      final message = '$data';
      final friendly = message.contains('UNAUTHORIZED') ? 'Sign-in was rejected.' : 'The online connection failed.';
      if (!completer.isCompleted) completer.completeError(OnlineException(friendly));
      _events.add(OnlineConnectFailed(friendly));
    });
    socket.onDisconnect((_) => _events.add(OnlineDisconnected()));
    socket.onReconnectFailed((_) => _events.add(const OnlineConnectFailed('The online connection failed.')));
    socket.on('room_state', (data) {
      if (data is Map) _events.add(OnlineRoomEvent(RoomSnapshot.fromJson(Map<String, dynamic>.from(data))));
    });
    socket.on('game_state', (data) {
      if (data is Map) _events.add(OnlineGameEvent(Map<String, dynamic>.from(data)));
    });
    socket.on('game_finished', (data) {
      if (data is Map) _events.add(OnlineFinishedEvent(Map<String, dynamic>.from(data)));
    });
    socket.on('error', (data) {
      final code = data is Map ? data['code'] : null;
      if (code == 'SESSION_REPLACED') {
        socket.disconnect();
        _events.add(OnlineReplaced());
      } else if (code == 'GAME_ABORTED') {
        _events.add(OnlineAborted());
      }
    });
    socket.connect();
    try {
      await completer.future.timeout(const Duration(seconds: 8));
    } catch (e) {
      await disconnect();
      if (e is TimeoutException) throw OnlineException('The server did not answer. Check the address and retry.');
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> request(String event, Map<String, dynamic> payload) {
    final socket = _socket;
    if (socket == null || socket.disconnected) throw OnlineException('The online connection failed.');
    final completer = Completer<Map<String, dynamic>>();
    final timer = Timer(const Duration(seconds: 8), () {
      if (!completer.isCompleted) completer.completeError(TimeoutException(event));
    });
    socket.emitWithAck(event, payload, ack: (data) {
      timer.cancel();
      if (completer.isCompleted) return;
      if (data is Map) completer.complete(Map<String, dynamic>.from(data));
      else completer.completeError(OnlineException('The server sent an unexpected reply.'));
    });
    return completer.future;
  }

  @override
  Future<void> disconnect() async {
    final socket = _socket;
    _socket = null;
    if (socket == null) return;
    socket.dispose();
  }
}
