import 'package:flutter/material.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/ui/screens/lesson_selection_screen.dart';
import 'package:superthai/ui/screens/create_screen.dart';
import 'package:superthai/ui/screens/favorites_screen.dart';
import 'package:superthai/ui/screens/discover_screen.dart';
import 'package:superthai/ui/theme/app_theme.dart';
import 'package:superthai/core/services/auth_service.dart';

class MainContainer extends StatefulWidget {
  const MainContainer({super.key});

  static MainContainerState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainContainerState>();

  @override
  State<MainContainer> createState() => MainContainerState();
}

class MainContainerState extends State<MainContainer> {
  int _selectedIndex = 0;
  LessonPlan? _editingPlan;

  // Track loaded pages to avoid heavy initialization
  final List<bool> _loadedPages = [true, false, false, false];

  void switchToCreate([LessonPlan? plan]) {
    setState(() {
      _editingPlan = plan;
      _selectedIndex = 3;
      _loadedPages[3] = true;
    });
  }

  void switchToLesson() {
    setState(() {
      _editingPlan = null;
      _selectedIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final isAdmin = AuthService.instance.isAdmin;

        return Scaffold(
          body: IndexedStack(
            index: _selectedIndex,
            children: [
              const LessonSelectionScreen(),
              _buildLazyPage(1, () => const FavoritesScreen()),
              _buildLazyPage(2, () => const DiscoverScreen()),
              _buildLazyPage(3, () => CreateScreen(existingPlan: _editingPlan)),
            ],
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) {
                if (index == 3 && !isAdmin) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Only Admins can access the Create section. 🛡️",
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  return;
                }
                setState(() {
                  _selectedIndex = index;
                  _loadedPages[index] = true;
                });
              },
              backgroundColor: Theme.of(context).cardColor,
              indicatorColor: Colors.transparent,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.menu_book_outlined),
                  selectedIcon: Icon(
                    Icons.menu_book_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  label: 'Lesson',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.translate_rounded),
                  selectedIcon: Icon(
                    Icons.translate_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  label: 'Vocabulary',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.explore_outlined),
                  selectedIcon: Icon(
                    Icons.explore_rounded,
                    color: AppTheme.primaryColor,
                  ),
                  label: 'Discover',
                ),
                if (isAdmin)
                  const NavigationDestination(
                    icon: Icon(Icons.add_circle_outline_rounded),
                    selectedIcon: Icon(
                      Icons.add_circle_rounded,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'Create',
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLazyPage(int index, Widget Function() builder) {
    if (_loadedPages[index]) {
      return builder();
    } else {
      return const SizedBox.shrink();
    }
  }
}
