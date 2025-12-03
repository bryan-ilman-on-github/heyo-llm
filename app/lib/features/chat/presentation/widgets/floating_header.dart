import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/theme/heyo_theme.dart';

class FloatingHeader extends StatelessWidget {
  final VoidCallback? onClear;

  const FloatingHeader({super.key, this.onClear});

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: context.glassColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: context.glassBorder,
                width: 1,
              ),
              boxShadow: context.glassShadow,
            ),
            child: Row(
              children: [
                // Logo - clean gradient avatar
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: HeyoGradients.primaryButton,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: context.softShadow,
                  ),
                  child: const Center(
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Heyo',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: context.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: HeyoColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Online',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.textTertiary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                if (onClear != null)
                  _buildActionButton(
                    context: context,
                    icon: Icons.delete_outline_rounded,
                    onTap: onClear!,
                  ),

                const SizedBox(width: 8),
                _MenuButton(isDark: isDark),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: context.textTertiary),
        ),
      ),
    );
  }
}

class _MenuButton extends StatefulWidget {
  final bool isDark;

  const _MenuButton({required this.isDark});

  @override
  State<_MenuButton> createState() => _MenuButtonState();
}

class _MenuButtonState extends State<_MenuButton> {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.surfaceVariant.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.more_horiz_rounded,
            size: 20,
            color: context.textTertiary,
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) {
    final themeProvider = context.read<ThemeProvider>();
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: context.surface,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      items: [
        _buildMenuItem(
          context: context,
          icon: Icons.add_rounded,
          title: 'New Chat',
          value: 'new_chat',
        ),
        _buildDivider(context),
        _buildThemeMenuItem(context, themeProvider),
        _buildDivider(context),
        _buildMenuItem(
          context: context,
          icon: Icons.settings_rounded,
          title: 'Settings',
          value: 'settings',
        ),
        _buildMenuItem(
          context: context,
          icon: Icons.info_outline_rounded,
          title: 'About',
          value: 'about',
        ),
      ],
    ).then((value) {
      if (value == null) return;
      if (!context.mounted) return;

      switch (value) {
        case 'new_chat':
          // TODO: Implement new chat
          break;
        case 'settings':
          // TODO: Implement settings
          break;
        case 'about':
          _showAboutDialog(context);
          break;
      }
    });
  }

  PopupMenuEntry<String> _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
    Color? iconColor,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 48,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor ?? context.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: context.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildThemeMenuItem(BuildContext context, ThemeProvider themeProvider) {
    final isDark = context.isDarkMode;

    return PopupMenuItem<String>(
      enabled: false,
      height: 56,
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(colors: [Color(0xFF1E293B), Color(0xFF334155)])
                  : const LinearGradient(colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              size: 18,
              color: isDark ? Colors.white : const Color(0xFFF59E0B),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Dark Mode',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: context.textPrimary,
              ),
            ),
          ),
          // Custom animated toggle
          _ThemeToggle(
            isDark: isDark,
            onToggle: () {
              Navigator.pop(context); // Close first so menu doesn't flash
              themeProvider.toggleTheme(); // Then transition screen
            },
          ),
        ],
      ),
    );
  }

  PopupMenuEntry<String> _buildDivider(BuildContext context) {
    return PopupMenuDivider(height: 1);
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: context.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: HeyoGradients.primaryButton,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: HeyoShadows.glow(HeyoColors.primary),
                ),
                child: const Center(
                  child: Text(
                    'H',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Heyo',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: context.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Version 1.0.0',
                style: TextStyle(
                  fontSize: 14,
                  color: context.textTertiary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your intelligent AI assistant\npowered by local LLMs.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: context.surfaceVariant,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Close',
                    style: TextStyle(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggle;

  const _ThemeToggle({
    required this.isDark,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 52,
        height: 28,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isDark
              ? HeyoGradients.primaryButton
              : const LinearGradient(
                  colors: [Color(0xFFE5E7EB), Color(0xFFD1D5DB)],
                ),
          boxShadow: [
            BoxShadow(
              color: (isDark ? HeyoColors.primary : Colors.black).withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Icons background
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      Icons.light_mode_rounded,
                      size: 14,
                      color: isDark ? Colors.white.withValues(alpha: 0.3) : Colors.transparent,
                    ),
                    Icon(
                      Icons.dark_mode_rounded,
                      size: 14,
                      color: isDark ? Colors.transparent : context.textTertiary.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            // Thumb
            AnimatedPositioned(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              left: isDark ? 26 : 2,
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
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    size: 14,
                    color: isDark ? HeyoColors.primary : const Color(0xFFF59E0B),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
