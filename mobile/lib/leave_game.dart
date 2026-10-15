import 'package:flutter/material.dart';

/// Confirms leaving an in-progress game for both the Back button and system Back.
class LeaveGameScope extends StatefulWidget {
  const LeaveGameScope({super.key, required this.confirm, required this.child});

  final bool confirm;
  final Widget child;

  @override
  State<LeaveGameScope> createState() => _LeaveGameScopeState();
}

class _LeaveGameScopeState extends State<LeaveGameScope> {
  bool _bypass = false;
  bool _asking = false;

  Future<void> _ask() async {
    if (_asking || !mounted) return;
    _asking = true;
    final leave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave this game?'),
        content: const Text('This game is still in progress. Leave and lose the current progress?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Resume')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Exit game')),
        ],
      ),
    );
    _asking = false;
    if (leave == true && mounted) {
      setState(() => _bypass = true);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) Navigator.of(context).pop();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _bypass || !widget.confirm,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !widget.confirm) return;
        _ask();
      },
      child: widget.child,
    );
  }
}
