import 'package:flutter/material.dart';
import 'package:superthai/ui/screens/settings_screen.dart';

class ThaiAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final double? leadingWidth;
  final bool showProfile;
  final bool? centerTitle;

  const ThaiAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.leadingWidth,
    this.showProfile = true,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      toolbarHeight: 65,
      backgroundColor: theme.scaffoldBackgroundColor,
      surfaceTintColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      centerTitle: centerTitle ?? false,
      title:
          titleWidget ??
          Text(
            title ?? "",
            style:
                theme.appBarTheme.titleTextStyle?.copyWith(fontSize: 18) ??
                const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
          ),
      actions: [
        ...?actions,
        if (showProfile)
          IconButton(
            icon: Icon(
              Icons.person_outline_rounded,
              color: theme.colorScheme.primary,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        const SizedBox(width: 8),
      ],
      leading: leading,
      leadingWidth: leadingWidth,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(65);
}

class ThaiButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isLoading;

  const ThaiButton({
    super.key,
    required this.text,
    this.onPressed,
    this.color,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: color != null
          ? ElevatedButton.styleFrom(backgroundColor: color)
          : null,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : Text(text),
    );
  }
}

class ThaiTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData? icon;
  final bool isPassword;
  final int? maxLines;

  const ThaiTextField({
    super.key,
    required this.controller,
    required this.label,
    this.icon,
    this.isPassword = false,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        maxLines: isPassword ? 1 : maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null
              ? Icon(icon, color: Theme.of(context).primaryColor)
              : null,
        ),
      ),
    );
  }
}

class ThaiCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;

  const ThaiCard({super.key, required this.child, this.onTap, this.padding});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
