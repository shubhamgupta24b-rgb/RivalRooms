import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../leave_game.dart';
import 'online_models.dart';
import 'online_session.dart';

const _ink = Color(0xFF202520);
const _green = Color(0xFF476B4B);
const _coral = Color(0xFFE4775D);
const _muted = Color(0xFF777A70);

class OnlinePlayPage extends StatefulWidget {
  const OnlinePlayPage({super.key});
  @override
  State<OnlinePlayPage> createState() => _OnlinePlayPageState();
}

class _OnlinePlayPageState extends State<OnlinePlayPage> {
  late final OnlineSession session;
  late final TextEditingController url;
  late final TextEditingController name;
  int cardCount = 16;
  int players = 2;
  bool _pushed = false;

  @override
  void initState() {
    super.initState();
    session = OnlineSession();
    url = TextEditingController(text: session.serverUrl);
    name = TextEditingController(text: 'Guest');
    session.addListener(_sync);
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final savedUrl = prefs.getString('rivalrooms.serverUrl');
    final savedName = prefs.getString('rivalrooms.displayName');
    setState(() {
      if (savedUrl != null && savedUrl.isNotEmpty) url.text = savedUrl;
      if (savedName != null && savedName.isNotEmpty) name.text = savedName;
    });
  }

  void _sync() {
    if (!mounted) return;
    setState(() {});
    if (session.link == OnlineLink.connected) {
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('rivalrooms.serverUrl', session.serverUrl);
        prefs.setString('rivalrooms.displayName', name.text.trim());
      });
    }
    if (session.room != null && !_pushed) {
      _pushed = true;
      Navigator.push(context, MaterialPageRoute(builder: (_) => OnlineRoomPage(session: session))).then((_) {
        _pushed = false;
        if (mounted) setState(() {});
      });
    }
  }

  Future<void> _run(Future<void> Function() action) async {
    session.serverUrl = url.text.trim();
    session.displayName = name.text.trim().isEmpty ? 'Guest' : name.text.trim();
    await action();
  }

  @override
  void dispose() {
    session.removeListener(_sync);
    session.dispose();
    url.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final status = switch (session.link) {
      OnlineLink.connected => 'Connected',
      OnlineLink.connecting => 'Connecting…',
      OnlineLink.failed => 'Not connected',
      OnlineLink.idle => 'Not connected',
    };
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Text('Play online', style: TextStyle(fontSize: 31, fontWeight: FontWeight.w900, letterSpacing: -1)),
      const SizedBox(height: 6),
      const Text('Bring your friends into the same room.', style: TextStyle(color: _muted)),
      const SizedBox(height: 16),
      Text(status, key: const Key('online-status'), style: const TextStyle(fontWeight: FontWeight.w800, color: _green)),
      const SizedBox(height: 12),
      _field(url, 'Server address', 'https://your-service.onrender.com'),
      const SizedBox(height: 10),
      _field(name, 'Your name', 'Guest'),
      const SizedBox(height: 10),
      Row(children: [
        Expanded(child: _count('Cards', cardCount, const [8, 12, 16, 20, 24, 28, 32], (n) => setState(() => cardCount = n))),
        const SizedBox(width: 10),
        Expanded(child: _count('Players', players, const [2, 3, 4], (n) => setState(() => players = n))),
      ]),
      if (session.failure != null) ...[
        const SizedBox(height: 12),
        Text(session.failure!, key: const Key('online-failure'), style: const TextStyle(color: _coral, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: session.submitting ? null : () => _run(session.connect), child: const Text('Retry')),
      ],
      const SizedBox(height: 18),
      _action(Icons.add_circle_outline, 'Create a room', 'Start a private Memory Match', () => _run(() => session.createRoom(maxPlayers: players, cardCount: cardCount))),
      const SizedBox(height: 12),
      _action(Icons.login_rounded, 'Join with a code', 'Enter a friend’s room code', _askCode),
      const SizedBox(height: 12),
      _action(Icons.bolt_rounded, 'Quick Play', 'Find a Memory Match', () => _run(session.quickPlay)),
      const SizedBox(height: 16),
      const Text('Online play is Memory Match. The other games stay on this device.', style: TextStyle(color: _muted, fontSize: 12)),
    ]);
  }

  Widget _field(TextEditingController controller, String label, String hint) => TextField(
    controller: controller,
    decoration: InputDecoration(labelText: label, hintText: hint, filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none)),
  );

  Widget _count(String label, int value, List<int> options, ValueChanged<int> onChanged) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
    child: DropdownButtonHideUnderline(child: DropdownButton<int>(
      isExpanded: true,
      value: value,
      items: options.map((n) => DropdownMenuItem(value: n, child: Text('$label  $n'))).toList(),
      onChanged: (n) { if (n != null) onChanged(n); },
    )),
  );

  Widget _action(IconData icon, String title, String detail, VoidCallback tap) => InkWell(
    onTap: session.submitting ? null : tap,
    borderRadius: BorderRadius.circular(18),
    child: Container(padding: const EdgeInsets.all(17), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Row(children: [
      Icon(icon, color: _green, size: 28),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 4),
        Text(detail, style: const TextStyle(color: _muted, fontSize: 12)),
      ])),
      const Icon(Icons.chevron_right_rounded, color: _muted),
    ])),
  );

  Future<void> _askCode() async {
    final code = TextEditingController();
    final entered = await showDialog<String>(context: context, builder: (c) => AlertDialog(
      title: const Text('Join with a code'),
      content: TextField(controller: code, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(hintText: 'Room code')),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, code.text), child: const Text('Join')),
      ],
    ));
    code.dispose();
    if (entered == null || entered.trim().isEmpty) return;
    await _run(() => session.joinRoom(entered));
  }
}

class OnlineRoomPage extends StatefulWidget {
  final OnlineSession session;
  const OnlineRoomPage({super.key, required this.session});
  @override
  State<OnlineRoomPage> createState() => _OnlineRoomPageState();
}

class _OnlineRoomPageState extends State<OnlineRoomPage> {
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    widget.session.addListener(_onSession);
  }

  void _onSession() { if (mounted) setState(() {}); }

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    await widget.session.leave();
    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    widget.session.removeListener(_onSession);
    if (!_leaving) unawaited(widget.session.leave());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;
    final room = session.room;
    final active = room != null && room.playing && session.result == null;
    return LeaveGameScope(confirm: active, child: Scaffold(
      appBar: AppBar(
        leading: IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back_rounded), onPressed: () => Navigator.maybePop(context)),
        title: Text(room == null ? 'Room' : room.code, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1)),
      ),
      body: SafeArea(child: room == null ? const Center(child: Text('Leaving the room…')) : room.playing && room.gameType == 'memory' ? _memory(session) : room.playing ? _unsupported(room) : _lobby(session, room)),
    ));
  }

  Widget _lobby(OnlineSession session, RoomSnapshot room) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text(room.gameType == 'memory' ? 'Memory Match' : room.gameType, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900)),
      const SizedBox(height: 6),
      Text('Code ${room.code}  ·  ${room.players.length}/${room.maxPlayers}', style: const TextStyle(color: _muted, fontWeight: FontWeight.w700)),
      if (session.failure != null) Padding(padding: const EdgeInsets.only(top: 12), child: Text(session.failure!, style: const TextStyle(color: _coral, fontWeight: FontWeight.w700))),
      const SizedBox(height: 16),
      for (final player in room.players) Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(player.username, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            const SizedBox(height: 3),
            Text('${player.userId == room.hostId ? 'Host' : 'Player'} · ${player.connected ? 'Connected' : 'Disconnected'}', style: const TextStyle(color: _muted, fontSize: 12)),
          ])),
          Text(player.ready ? 'Ready' : 'Not ready', style: TextStyle(fontWeight: FontWeight.w800, color: player.ready ? _green : _muted)),
        ]),
      ),
      if (session.link != OnlineLink.connected) ...[
        const SizedBox(height: 8),
        const Text('The online connection failed.', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        FilledButton(onPressed: session.connect, child: const Text('Retry')),
        TextButton(onPressed: _leave, child: const Text('Return to lobby')),
      ] else if (session.isHost) ...[
        const SizedBox(height: 8),
        FilledButton(onPressed: session.submitting ? null : session.startGame, child: const Text('Start game')),
      ] else ...[
        const SizedBox(height: 8),
        FilledButton(
          onPressed: session.submitting ? null : () => session.setReady(!room.players.any((p) => p.userId == session.userId && p.ready)),
          child: Text(room.players.any((p) => p.userId == session.userId && p.ready) ? 'Not ready' : "I'm ready"),
        ),
      ],
    ]);
  }

  Widget _unsupported(RoomSnapshot room) => Center(child: Padding(padding: const EdgeInsets.all(28), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Text(room.gameType, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
    const SizedBox(height: 10),
    const Text('This room is not playing Memory Match. RivalRooms online currently supports Memory Match.', textAlign: TextAlign.center, style: TextStyle(color: _muted)),
    const SizedBox(height: 16),
    FilledButton(onPressed: _leave, child: const Text('Return to lobby')),
  ])));

  Widget _memory(OnlineSession session) {
    final board = session.memory;
    final room = session.room!;
    if (board == null) return const Center(child: CircularProgressIndicator());
    final mine = board.turn == session.userId;
    final turnPlayers = room.players.where((p) => p.userId == board.turn);
    final name = turnPlayers.isEmpty ? 'the other player' : turnPlayers.first.username;
    return Padding(padding: const EdgeInsets.all(18), child: Column(children: [
      if (session.link != OnlineLink.connected) Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('The online connection failed.', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Row(children: [
            FilledButton(onPressed: session.connect, child: const Text('Retry')),
            const SizedBox(width: 8),
            TextButton(onPressed: _leave, child: const Text('Return to lobby')),
          ]),
        ]),
      ),
      Row(children: [
        Expanded(child: Text(session.result != null ? 'Match finished' : mine && board.phase == 'turn' ? 'Your turn' : 'Waiting for $name', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final player in room.players) Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
          child: Text('${player.username}  ${board.scores[player.userId] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w800)),
        ),
      ]),
      if (session.failure != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(session.failure!, style: const TextStyle(color: _coral, fontWeight: FontWeight.w700))),
      const SizedBox(height: 12),
      Expanded(child: GridView.builder(
        itemCount: board.cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: .78),
        itemBuilder: (context, i) {
          final card = board.cards[i];
          final revealed = card.matched || board.selected.contains(card.id) || card.value != null;
          return InkWell(
            onTap: session.link == OnlineLink.connected && session.result == null ? () => session.flip(card.id) : null,
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              decoration: BoxDecoration(color: revealed ? const Color(0xFFE6E9DE) : _green, borderRadius: BorderRadius.circular(14), border: Border.all(color: card.matched ? _green : Colors.transparent, width: 2)),
              child: Center(child: Text(revealed ? (card.value ?? '✦') : '✦', style: TextStyle(fontSize: revealed ? 30 : 25, color: revealed ? _ink : Colors.white, fontWeight: FontWeight.w900))),
            ),
          );
        },
      )),
      if (session.result != null) _result(session) else const SizedBox(height: 8),
    ]));
  }

  Widget _result(OnlineSession session) {
    final ranking = session.result!['ranking'];
    final lines = ranking is List ? ranking.whereType<Map>().map((r) => '${r['username'] ?? 'Player'} · ${r['score'] ?? 0}').join('\n') : '';
    return Padding(padding: const EdgeInsets.only(top: 8), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(lines, style: const TextStyle(fontWeight: FontWeight.w700)),
      const SizedBox(height: 8),
      if (session.isHost) FilledButton(onPressed: session.submitting ? null : session.rematch, child: const Text('Rematch')),
      TextButton(onPressed: session.isHost ? session.returnToLobby : _leave, child: const Text('Return to lobby')),
    ]));
  }
}
