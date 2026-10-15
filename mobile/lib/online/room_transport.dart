import 'online_models.dart';

class OnlineConnected {}
class OnlineDisconnected {}
class OnlineConnectFailed {
  final String message;
  const OnlineConnectFailed(this.message);
}
class OnlineRoomEvent {
  final RoomSnapshot room;
  const OnlineRoomEvent(this.room);
}
class OnlineGameEvent {
  final Map<String, dynamic> state;
  const OnlineGameEvent(this.state);
}
class OnlineFinishedEvent {
  final Map<String, dynamic> result;
  const OnlineFinishedEvent(this.result);
}
class OnlineReplaced {}
class OnlineAborted {}

abstract class RoomTransport {
  Stream<Object> get events;
  Future<void> connect({required String url, required String token});
  Future<Map<String, dynamic>> request(String event, Map<String, dynamic> payload);
  Future<void> disconnect();
}
