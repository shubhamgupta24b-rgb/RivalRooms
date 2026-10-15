class OnlineException implements Exception {
  final String message;
  OnlineException(this.message);
  @override
  String toString() => message;
}

class GuestLogin {
  final String token, userId, username;
  const GuestLogin({required this.token, required this.userId, required this.username});
}

class RoomPlayer {
  final String userId, username;
  final bool ready, connected;
  const RoomPlayer({required this.userId, required this.username, required this.ready, required this.connected});

  factory RoomPlayer.fromJson(Map<String, dynamic> json) => RoomPlayer(
    userId: '${json['userId'] ?? ''}',
    username: '${json['username'] ?? 'Player'}',
    ready: json['ready'] == true,
    connected: json['connected'] == true,
  );
}

class RoomSnapshot {
  final String code, gameType, hostId, status;
  final int maxPlayers, memoryCardCount;
  final List<RoomPlayer> players;
  const RoomSnapshot({required this.code, required this.gameType, required this.hostId, required this.status, required this.maxPlayers, required this.memoryCardCount, required this.players});

  bool get playing => status == 'playing';
  bool get finished => status == 'finished';

  factory RoomSnapshot.fromJson(Map<String, dynamic> json) => RoomSnapshot(
    code: '${json['code'] ?? ''}',
    gameType: '${json['gameType'] ?? ''}',
    hostId: '${json['hostId'] ?? ''}',
    status: '${json['status'] ?? ''}',
    maxPlayers: json['maxPlayers'] is int ? json['maxPlayers'] as int : 2,
    memoryCardCount: json['memoryCardCount'] is int ? json['memoryCardCount'] as int : 24,
    players: (json['players'] as List? ?? const []).whereType<Map>().map((p) => RoomPlayer.fromJson(Map<String, dynamic>.from(p))).toList(),
  );
}

class MemoryCardView {
  final int id;
  final bool matched;
  final String? value;
  const MemoryCardView({required this.id, required this.matched, required this.value});
}

class MemoryView {
  final String phase, turn, myId;
  final Map<String, int> scores;
  final List<MemoryCardView> cards;
  final List<int> selected;
  const MemoryView({required this.phase, required this.turn, required this.myId, required this.scores, required this.cards, required this.selected});

  factory MemoryView.fromJson(Map<String, dynamic> json) => MemoryView(
    phase: '${json['phase'] ?? ''}',
    turn: '${json['turn'] ?? ''}',
    myId: json['you'] is Map ? '${(json['you'] as Map)['userId'] ?? ''}' : '',
    scores: (json['scores'] is Map) ? (json['scores'] as Map).map((k, v) => MapEntry('$k', v is int ? v : 0)) : const {},
    cards: (json['cards'] as List? ?? const []).whereType<Map>().map((c) {
      final map = Map<String, dynamic>.from(c);
      return MemoryCardView(id: map['id'] is int ? map['id'] as int : 0, matched: map['matched'] == true, value: map['value'] as String?);
    }).toList(),
    selected: (json['selected'] as List? ?? const []).whereType<int>().toList(),
  );
}

String explainServer(Map<String, dynamic> reply) {
  switch (reply['error']) {
    case 'RATE_LIMITED': return 'Too many requests. Wait a moment and retry.';
    case 'ROOM_NOT_FOUND': return 'That room code does not exist.';
    case 'ROOM_FULL': return 'That room is full.';
    case 'ALREADY_IN_ROOM': return 'You are already in a room.';
    case 'NOT_ENOUGH_PLAYERS': return 'Wait for another player before starting.';
    case 'PLAYERS_NOT_READY': return 'Everyone needs to be ready.';
    case 'NOT_HOST': return 'Only the host can do that.';
    case 'BAD_PHASE': return 'That move is not available right now.';
    case 'DUPLICATE_ACTION': return 'That move was already sent.';
    case 'INVALID_ACTION': return 'The server rejected that move.';
    case 'INVALID_PAYLOAD': return reply['message'] is String ? reply['message'] as String : 'That request was not valid.';
    case 'GAME_NOT_AVAILABLE': return 'That game is not available online.';
    default: return 'The server rejected the request.';
  }
}
