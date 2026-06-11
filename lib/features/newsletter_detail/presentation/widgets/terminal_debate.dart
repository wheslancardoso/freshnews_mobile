import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:fresh_news_mobile/core/theme/fn_colors.dart';
import 'package:fresh_news_mobile/core/theme/fn_theme.dart';
import 'package:fresh_news_mobile/shared/domain/newsletter.entity.dart';

class TerminalDebate extends StatefulWidget {
  final List<DebateMessage> messages;

  const TerminalDebate({
    super.key,
    required this.messages,
  });

  @override
  State<TerminalDebate> createState() => _TerminalDebateState();
}

class _TerminalDebateState extends State<TerminalDebate> {
  int _currentMessageIndex = 0;
  int _currentCharIndex = 0;
  bool _isPlaying = false;
  int _speed = 1; // 1x, 2x, 3x
  Timer? _typingTimer;
  Timer? _cursorTimer;
  bool _cursorVisible = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Blinking cursor timer
    _cursorTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (mounted) {
        setState(() {
          _cursorVisible = !_cursorVisible;
        });
      }
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _cursorTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _play() {
    if (widget.messages.isEmpty) return;
    
    // Se o debate terminou e apertou play de novo, reinicia
    if (_currentMessageIndex >= widget.messages.length - 1 &&
        _currentCharIndex >= widget.messages[_currentMessageIndex].message.length) {
      _reset();
    }

    _isPlaying = true;
    final delays = {1: 30, 2: 15, 3: 5};
    _typingTimer?.cancel();
    _typingTimer = Timer.periodic(
      Duration(milliseconds: delays[_speed]!),
      (_) => _advanceChar(),
    );
    setState(() {});
  }

  void _advanceChar() {
    if (_currentMessageIndex >= widget.messages.length) {
      _pause();
      return;
    }

    final currentMsg = widget.messages[_currentMessageIndex];
    if (_currentCharIndex < currentMsg.message.length) {
      setState(() {
        _currentCharIndex++;
      });
      _scrollToBottom();
    } else {
      if (_currentMessageIndex + 1 < widget.messages.length) {
        setState(() {
          _currentMessageIndex++;
          _currentCharIndex = 0;
        });
        _scrollToBottom();
      } else {
        _pause();
      }
    }
  }

  void _pause() {
    _typingTimer?.cancel();
    _isPlaying = false;
    setState(() {});
  }

  void _reset() {
    _pause();
    setState(() {
      _currentMessageIndex = 0;
      _currentCharIndex = 0;
    });
    _scrollToBottom();
  }

  void _toggleSpeed() {
    setState(() {
      _speed = _speed >= 3 ? 1 : _speed + 1;
    });
    if (_isPlaying) {
      _pause();
      _play();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Color _getRoleColor(String colorHex) {
    try {
      final hex = colorHex.replaceAll('#', '');
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (_) {}
    return FNColors.hackerGreen;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.messages.isEmpty) {
      return Container(
        height: 150,
        decoration: BoxDecoration(
          color: const Color(0xFF0A0A0A),
          border: Border.all(color: const Color(0xFF333333), width: 2),
        ),
        alignment: Alignment.center,
        child: Text(
          'SEM_LOG_DE_DEBATE_DISPONIVEL',
          style: FNTypography.code.copyWith(color: FNColors.textMuted),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        border: Border.all(color: const Color(0xFF333333), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          _buildHeaderBar(),
          // Terminal Console Body
          Container(
            height: 280,
            padding: const EdgeInsets.all(FNSpacing.base),
            child: _buildTerminalContent(),
          ),
          // Divider
          Container(
            height: 1,
            color: const Color(0xFF333333),
          ),
          // Controls Row
          _buildControlsRow(),
        ],
      ),
    );
  }

  Widget _buildHeaderBar() {
    return Container(
      color: const Color(0xFF161616),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          // Simulated window controls
          _buildDot(Colors.red),
          const SizedBox(width: 6),
          _buildDot(Colors.amber),
          const SizedBox(width: 6),
          _buildDot(Colors.green),
          const SizedBox(width: 12),
          Text(
            'FRESH_NEWS // AI_DEBATE',
            style: FNTypography.code.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildTerminalContent() {
    final showStartPrompt = _currentMessageIndex == 0 && _currentCharIndex == 0 && !_isPlaying;

    if (showStartPrompt) {
      return Center(
        child: InkWell(
          onTap: _play,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🤖 DEBATE_LOG: CARREGADO',
                style: FNTypography.code.copyWith(color: FNColors.primaryViolet, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: FNSpacing.base),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: FNColors.primaryViolet.withOpacity(0.5)),
                  color: FNColors.primaryViolet.withOpacity(0.05),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.play, color: Colors.white, size: 14),
                    const SizedBox(width: FNSpacing.sm),
                    Text(
                      'PLAY PARA INICIAR',
                      style: FNTypography.code.copyWith(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _currentMessageIndex + 1,
      itemBuilder: (context, index) {
        final msg = widget.messages[index];
        final isCurrent = index == _currentMessageIndex;
        final messageText = isCurrent 
            ? msg.message.substring(0, _currentCharIndex)
            : msg.message;

        final isTypingFinishedForThisMessage = !isCurrent || _currentCharIndex >= msg.message.length;
        final showCursor = isCurrent && !isTypingFinishedForThisMessage && _cursorVisible;
        final roleColor = _getRoleColor(msg.color);

        return Padding(
          padding: const EdgeInsets.only(bottom: FNSpacing.base),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sender identification row
              Row(
                children: [
                  Text(
                    '${msg.avatar} ${msg.persona}',
                    style: FNTypography.code.copyWith(
                      color: roleColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '[${msg.role}]',
                    style: FNTypography.code.copyWith(
                      color: roleColor.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              // Message text
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: RichText(
                  text: TextSpan(
                    style: FNTypography.code.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFFE4E4E7),
                    ),
                    children: [
                      TextSpan(
                        text: '> ',
                        style: FNTypography.code.copyWith(
                          color: roleColor.withOpacity(0.5),
                        ),
                      ),
                      TextSpan(text: messageText),
                      if (showCursor)
                        TextSpan(
                          text: '▊', // solid block cursor
                          style: FNTypography.code.copyWith(
                            color: roleColor,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  Widget _buildControlsRow() {
    return Container(
      color: const Color(0xFF111111),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Play / Pause Button
          _buildTerminalButton(
            icon: _isPlaying ? LucideIcons.pause : LucideIcons.play,
            label: _isPlaying ? 'PAUSE' : 'PLAY',
            onTap: _isPlaying ? _pause : _play,
          ),
          // Reset Button
          _buildTerminalButton(
            icon: LucideIcons.rotate_ccw,
            label: 'RESET',
            onTap: _reset,
          ),
          // Speed Toggle Button
          _buildTerminalButton(
            icon: LucideIcons.zap,
            label: '${_speed}X SPEED',
            onTap: _toggleSpeed,
          ),
        ],
      ),
    );
  }

  Widget _buildTerminalButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF1C1C1E),
          border: Border.all(color: const Color(0xFF333333)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: FNTypography.code.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
