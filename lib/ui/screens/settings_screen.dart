import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:superthai/core/services/theme_service.dart';
import 'package:superthai/core/services/auth_service.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';

import 'package:superthai/ui/screens/login_screen.dart';
import 'package:superthai/ui/screens/edit_profile_screen.dart';
import 'package:superthai/ui/screens/add_admin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final user = AuthService.instance.currentUser;
        final isGuest = user == null;
        final name = user?.displayName;
        final email = user?.email;
        final isAdmin = AuthService.instance.isAdmin;
        final role =
            AuthService.instance.role ?? (isGuest ? "Trial" : "Member");

        return Scaffold(
          appBar: const ThaiAppBar(
            title: "Settings",
            showProfile: false,
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User Profile Section
                  _buildProfileHeader(context, name, email, role, isGuest),
                  const SizedBox(height: 32),

                  // Admin Panel (Only for Admins)
                  if (isAdmin) ...[
                    _buildSectionTitle("Admin Management"),
                    _buildSettingsGroup(context, [
                      _SettingsTile(
                        icon: Icons.admin_panel_settings_rounded,
                        title: "Add New Admin",
                        color: Colors.deepPurple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddAdminScreen(),
                            ),
                          );
                        },
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  // Settings Sections
                  _buildSectionTitle("General"),
                  _buildSettingsGroup(context, [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: "Edit Profile",
                      color: Colors.blue,
                      onTap: isGuest
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const EditProfileScreen(),
                                ),
                              );
                            },
                    ),
                    Consumer<ThemeService>(
                      builder: (context, theme, _) {
                        return _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: "Dark Mode",
                          color: Colors.indigo,
                          isSwitch: true,
                          switchValue: theme.isDarkMode,
                          onSwitchChanged: (val) => theme.toggleTheme(val),
                        );
                      },
                    ),
                  ]),

                  const SizedBox(height: 40),

                  // Logout/Login Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        if (isGuest) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );
                        } else {
                          AuthService.instance.logout();
                        }
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor:
                            (isGuest ? AppTheme.primaryColor : Colors.red)
                                .withValues(alpha: 0.1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      icon: Icon(
                        isGuest ? Icons.login_rounded : Icons.logout_rounded,
                        color: isGuest ? AppTheme.primaryColor : Colors.red,
                      ),
                      label: Text(
                        isGuest ? "Login / Sign Up" : "Logout",
                        style: TextStyle(
                          color: isGuest ? AppTheme.primaryColor : Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      "Version 1.2.0 (Build 45)",
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    String? name,
    String? email,
    String role,
    bool isGuest,
  ) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final isAdmin = role.toLowerCase() == 'admin';
    final hasName = name != null && name.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isAdmin ? Colors.deepPurple : primaryColor,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: isGuest
                  ? AppTheme.accentColor
                  : (isAdmin ? Colors.deepPurple : primaryColor).withValues(
                      alpha: 0.15,
                    ),
              child: Icon(
                isGuest
                    ? Icons.person_outline
                    : (isAdmin ? Icons.shield_rounded : Icons.person_rounded),
                size: 40,
                color: isAdmin ? Colors.deepPurple : primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGuest ? "Welcome!" : "Sawatdee!",
                  style: TextStyle(
                    fontSize: 14,
                    color:
                        theme.textTheme.bodySmall?.color ??
                        AppTheme.lightTextColor,
                  ),
                ),
                Text(
                  hasName ? name : (email ?? "Guest User"),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (isAdmin ? Colors.deepPurple : primaryColor)
                        .withValues(
                          alpha: theme.brightness == Brightness.light
                              ? 0.1
                              : 0.2,
                        ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: TextStyle(
                      color: isAdmin ? Colors.deepPurple : primaryColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(BuildContext context, List<Widget> tiles) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: tiles.asMap().entries.map((entry) {
          final index = entry.key;
          final tile = entry.value;
          final isLast = index == tiles.length - 1;

          return Column(
            children: [
              tile,
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 20,
                  color: theme.dividerColor,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.color,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: isSwitch ? null : (onTap ?? () {}),
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (isSwitch)
              Switch(
                value: switchValue,
                onChanged: onSwitchChanged,
                activeThumbColor: AppTheme.primaryColor,
              ),
            if (!isSwitch) const SizedBox(width: 8),
            if (!isSwitch)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: theme.disabledColor,
              ),
          ],
        ),
      ),
    );
  }
}
