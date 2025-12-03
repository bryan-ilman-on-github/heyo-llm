import 'package:flutter/material.dart';

import '../../../../shared/theme/heyo_theme.dart';

class EmptyChat extends StatefulWidget {
  final Function(String) onSuggestionTap;

  const EmptyChat({super.key, required this.onSuggestionTap});

  @override
  State<EmptyChat> createState() => _EmptyChatState();
}

class _EmptyChatState extends State<EmptyChat> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<_Suggestion> _suggestions = [
    _Suggestion(
      icon: Icons.calculate_rounded,
      text: 'Calculate √189',
      color: HeyoColors.accent,
      prompt: 'What is the square root of 189?',
    ),
    _Suggestion(
      icon: Icons.code_rounded,
      text: 'Write Python code',
      color: HeyoColors.primary,
      prompt: 'Write a Python function to check if a number is prime',
    ),
    _Suggestion(
      icon: Icons.lightbulb_outline_rounded,
      text: 'Explain something',
      color: HeyoColors.success,
      prompt: 'Explain how neural networks work in simple terms',
    ),
    _Suggestion(
      icon: Icons.edit_note_rounded,
      text: 'Help me write',
      color: const Color(0xFFE879F9),
      prompt: 'Help me write a professional email to my manager',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // Greeting section
              _buildGreeting(context),

              const SizedBox(height: 48),

              // Suggestion chips
              _buildSuggestionGrid(context),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context) {
    final isDark = context.isDarkMode;

    return Column(
      children: [
        // Logo with glow - show full logo with white bg
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Colors.white, // Keep white - image has white bg
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: HeyoColors.primary.withValues(alpha: isDark ? 0.25 : 0.15),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                'assets/images/logo_square.jpg',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => Container(
                  decoration: BoxDecoration(
                    gradient: HeyoGradients.primaryButton,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Greeting text
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: [
              Color(0xFF6B9DFC),
              Color(0xFF8B5CF6),
            ],
          ).createShader(bounds),
          child: const Text(
            'Hi there!',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'What can I help you with today?',
          style: TextStyle(
            fontSize: 17,
            color: context.textSecondary,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16),
          child: Text(
            'Try asking',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: context.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: _suggestions.length,
          itemBuilder: (context, index) {
            return _buildSuggestionCard(context, _suggestions[index], index);
          },
        ),
      ],
    );
  }

  Widget _buildSuggestionCard(BuildContext context, _Suggestion suggestion, int index) {
    final isDark = context.isDarkMode;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + index * 100),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => widget.onSuggestionTap(suggestion.prompt),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: suggestion.color.withValues(alpha: isDark ? 0.3 : 0.2),
                width: 1.5,
              ),
              boxShadow: context.softShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: suggestion.color.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    suggestion.icon,
                    size: 20,
                    color: suggestion.color,
                  ),
                ),
                const Spacer(),
                Text(
                  suggestion.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Suggestion {
  final IconData icon;
  final String text;
  final Color color;
  final String prompt;

  const _Suggestion({
    required this.icon,
    required this.text,
    required this.color,
    required this.prompt,
  });
}
