import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/settings_provider.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/theme/heyo_theme.dart';

/// Minimal floating controls - hamburger menu and Whisper mode toggle
class ChatControls extends StatelessWidget {
  final VoidCallback onMenuTap;
  final bool isWhisperMode;
  final VoidCallback onWhisperToggle;

  const ChatControls({
    super.key,
    required this.onMenuTap,
    required this.isWhisperMode,
    required this.onWhisperToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Hamburger menu button
          _GlassButton(
            icon: Icons.menu_rounded,
            onTap: onMenuTap,
          ),
          // Whisper mode toggle
          _WhisperToggle(
            isActive: isWhisperMode,
            onToggle: onWhisperToggle,
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.glassColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: context.glassBorder,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 22,
                color: context.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WhisperToggle extends StatelessWidget {
  final bool isActive;
  final VoidCallback onToggle;

  const _WhisperToggle({
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(20),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          HeyoColors.primary.withValues(alpha: 0.8),
                          HeyoColors.primaryDark.withValues(alpha: 0.8),
                        ],
                      )
                    : null,
                color: isActive ? null : context.glassColor.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive
                      ? HeyoColors.primary.withValues(alpha: 0.5)
                      : context.glassBorder,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Filled/empty circle indicator
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Colors.white : Colors.transparent,
                      border: Border.all(
                        color: isActive ? Colors.white : context.textSecondary,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Whisper',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isActive ? Colors.white : context.textSecondary,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Slide-out menu drawer with smooth animations
class ChatMenuDrawer extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onNewChat;
  final VoidCallback onClearChat;
  final VoidCallback onSettings;
  final VoidCallback onAbout;
  final bool hasMessages;
  final Animation<double> animation;

  const ChatMenuDrawer({
    super.key,
    required this.onClose,
    required this.onNewChat,
    required this.onClearChat,
    required this.onSettings,
    required this.onAbout,
    required this.hasMessages,
    required this.animation,
  });

  static const double _drawerWidth = 280;

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final isDark = context.isDarkMode;

    // Curved animations for different elements
    // Scrim uses easeOut for both directions - slows down as it fades out
    final scrimOpacity = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeOutCubic,
    );

    final drawerSlide = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Scrim overlay - smooth fade
            GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.5 * scrimOpacity.value),
              ),
            ),

            // Drawer panel - slide from left
            Positioned(
              left: -_drawerWidth * (1 - drawerSlide.value),
              top: 0,
              bottom: 0,
              width: _drawerWidth,
              child: GestureDetector(
                onTap: () {}, // Prevent tap through
                onHorizontalDragUpdate: (details) {
                  // Allow swipe to close
                  if (details.primaryDelta != null && details.primaryDelta! < -10) {
                    onClose();
                  }
                },
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.glassColor.withValues(alpha: 0.92),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(24),
                          bottomRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15 * drawerSlide.value),
                            blurRadius: 30,
                            offset: const Offset(10, 0),
                          ),
                        ],
                        border: Border(
                          right: BorderSide(
                            color: context.glassBorder,
                            width: 1,
                          ),
                        ),
                      ),
                      child: SafeArea(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        // Header with logo
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: HeyoGradients.primaryButton,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: HeyoShadows.glow(HeyoColors.primary),
                                ),
                                child: const Center(
                                  child: Text(
                                    'H',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Heyo',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                      color: context.textPrimary,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                  Text(
                                    'AI Assistant',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: context.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              IconButton(
                                onPressed: onClose,
                                icon: Icon(
                                  Icons.close_rounded,
                                  color: context.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        Divider(color: context.glassBorder, height: 1),
                        const SizedBox(height: 12),
                        // Menu items
                        _MenuItem(
                          icon: Icons.add_rounded,
                          title: 'New Chat',
                          onTap: () {
                            onClose();
                            onNewChat();
                          },
                        ),
                        if (hasMessages)
                          _MenuItem(
                            icon: Icons.delete_outline_rounded,
                            title: 'Clear Chat',
                            onTap: () {
                              onClose();
                              onClearChat();
                            },
                            color: HeyoColors.error,
                          ),
                        const SizedBox(height: 8),
                        Divider(color: context.glassBorder, height: 1),
                        const SizedBox(height: 8),
                        // Theme toggle
                        _ThemeMenuItem(
                          isDark: isDark,
                          onToggle: () {
                            themeProvider.toggleTheme();
                          },
                        ),
                        // Branch coloring toggle
                        Consumer<SettingsProvider>(
                          builder: (context, settings, _) => _BranchColorMenuItem(
                            isEnabled: settings.branchColoringEnabled,
                            onToggle: () {
                              settings.toggleBranchColoring();
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Divider(color: context.glassBorder, height: 1),
                        const SizedBox(height: 8),
                        _MenuItem(
                          icon: Icons.settings_rounded,
                          title: 'Settings',
                          onTap: () {
                            onClose();
                            onSettings();
                          },
                        ),
                        _MenuItem(
                          icon: Icons.info_outline_rounded,
                          title: 'About',
                          onTap: () {
                            onClose();
                            onAbout();
                          },
                        ),
                        const Spacer(),
                        // Version
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Version 1.0.0',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textTertiary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
          ],
        );
      },
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final itemColor = color ?? context.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: itemColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: itemColor),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: color ?? context.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeMenuItem extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeMenuItem({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)])
                      : const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  size: 20,
                  color: isDark ? Colors.white : const Color(0xFFF59E0B),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Dark Mode',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
              ),
              // Toggle switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isDark ? HeyoGradients.primaryButton : null,
                  color: isDark ? null : context.surfaceVariant,
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isDark ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BranchColorMenuItem extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onToggle;

  const _BranchColorMenuItem({
    required this.isEnabled,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onToggle,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF6B9DFC), Color(0xFFA78BFA), Color(0xFFF472B6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: isEnabled ? null : context.surfaceVariant,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.palette_rounded,
                  size: 20,
                  color: isEnabled ? Colors.white : context.textTertiary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'Branch Colors',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: context.textPrimary,
                  ),
                ),
              ),
              // Toggle switch
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 48,
                height: 28,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  gradient: isEnabled
                      ? const LinearGradient(
                          colors: [Color(0xFF6B9DFC), Color(0xFFA78BFA)],
                        )
                      : null,
                  color: isEnabled ? null : context.surfaceVariant,
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      left: isEnabled ? 22 : 2,
                      top: 2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
