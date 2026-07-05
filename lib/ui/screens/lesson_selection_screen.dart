import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/auth_service.dart';
import 'package:superthai/core/services/data_service.dart';
import 'package:superthai/core/services/progress_service.dart';
import 'package:superthai/ui/screens/lesson_screen.dart';
import 'package:superthai/ui/screens/main_container.dart';
import 'package:superthai/ui/widgets/shared_widgets.dart';
import 'package:superthai/ui/widgets/lesson_map_widgets.dart';
import 'package:superthai/ui/screens/login_screen.dart';

class LessonSelectionScreen extends StatefulWidget {
  const LessonSelectionScreen({super.key});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  late Future<List<LessonPlan>> _plansFuture;

  @override
  void initState() {
    super.initState();
    _refreshCategories();
  }

  void _refreshCategories() {
    if (!mounted) return;
    setState(() {
      _plansFuture = DataService.instance.getAllLessonPlans();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ThaiAppBar(
        title: "Lesson",
        actions: [
          Consumer<ProgressService>(
            builder: (context, progress, _) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "${progress.streakCount}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<LessonPlan>>(
        future: _plansFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          final allPlans = snapshot.data ?? [];

          return RefreshIndicator(
            onRefresh: () async => _refreshCategories(),
            child: allPlans.isEmpty
                ? SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.7,
                      child: _buildEmptyState(),
                    ),
                  )
                : Consumer<ProgressService>(
                    builder: (context, progress, _) {
                      return _LessonMap(
                        plans: allPlans,
                        progress: progress,
                        onReturn: _refreshCategories,
                      );
                    },
                  ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            "No lessons available yet!",
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            "Please check back later for new content.",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _LessonMap extends StatelessWidget {
  final List<LessonPlan> plans;
  final ProgressService progress;
  final VoidCallback onReturn;

  static const List<String> _thaiConsonants = [
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
    '?',
  ];

  const _LessonMap({
    required this.plans,
    required this.progress,
    required this.onReturn,
  });

  void _showDeleteConfirmation(BuildContext context, LessonPlan plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Lesson?"),
        content: Text("Are you sure you want to delete '${plan.title}'?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ProgressService.instance.resetProgress(plan.id);
              await DataService.instance.deleteLessonPlan(plan.id);
              onReturn();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  void _showOptions(BuildContext context, LessonPlan plan) {
    final currentUser = AuthService.instance.currentUser;
    // อนุญาตให้แก้ไขได้ถ้า: 1. เป็นเจ้าของ 2. บทเรียนนั้นไม่มีเจ้าของ (เพื่อให้ dev แก้ไขบทเรียนระบบได้)
    final isLessonOwner =
        currentUser != null &&
        (plan.creatorId == currentUser.uid ||
            plan.creatorId == null ||
            plan.creatorId!.isEmpty);

    // เก็บ Context ของหน้าหลักไว้เรียกใช้ใน BottomSheet
    final screenContext = context;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(plan.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            ListTile(
              leading: const SizedBox(
                width: 40,
                child: Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              title: const Text(
                "Start Lesson",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  screenContext,
                  MaterialPageRoute(
                    builder: (_) => LessonScreen(
                      category: plan.category,
                      lessonId: plan.id,
                    ),
                  ),
                ).then((_) => onReturn());
              },
            ),
            if (isLessonOwner) ...[
              ListTile(
                leading: const SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.edit_rounded,
                    color: Colors.orange,
                    size: 24,
                  ),
                ),
                title: const Text(
                  "Edit Lesson",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  MainContainer.of(screenContext)?.switchToCreate(plan);
                },
              ),
              ListTile(
                leading: const SizedBox(
                  width: 40,
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.red,
                    size: 24,
                  ),
                ),
                title: const Text(
                  "Delete Lesson",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteConfirmation(screenContext, plan);
                },
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showSignupPrompt(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Trial Limit Reached! 🚀"),
        content: const Text(
          "You've tried 3 lessons. Please create an account or login to continue learning and save your progress to the cloud!",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Maybe Later"),
          ),
          ThaiButton(
            text: "Login / Sign Up",
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<LessonPlan>> plansByCategory = {};
    for (var plan in plans) {
      plansByCategory.putIfAbsent(plan.category, () => []).add(plan);
    }

    final categoryNames = plansByCategory.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.only(top: 20, bottom: 120),
      itemCount: categoryNames.length,
      scrollCacheExtent: const ScrollCacheExtent.pixels(1000.0),
      addAutomaticKeepAlives: true,
      itemBuilder: (context, categoryIndex) {
        final categoryName = categoryNames[categoryIndex];
        final categoryPlans = plansByCategory[categoryName]!;

        return Consumer<ProgressService>(
          builder: (context, progress, _) {
            int completedStepCount = 0;
            int totalStepCount = 0;
            for (var lessonPlan in categoryPlans) {
              completedStepCount += progress.getCompleted(lessonPlan.id);
              totalStepCount += lessonPlan.steps.length;
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final double width = constraints.maxWidth;
                const List<double> alignments = [0.0, -0.5, 0.0, 0.5];
                const double nodeWidth = 80.0;
                const double rowHeight = 120.0;
                final List<Offset> points = [];

                for (int i = 0; i < categoryPlans.length; i++) {
                  final align = alignments[i % alignments.length];
                  final double x =
                      (width / 2) + (align * (width - nodeWidth) / 2);
                  final double y = (i * rowHeight) + 40;
                  points.add(Offset(x, y));
                }

                return Column(
                  children: [
                    UnitHeaderCard(
                      title: categoryName,
                      emoji: categoryPlans.isNotEmpty
                          ? categoryPlans.first.categoryEmoji
                          : '??',
                      completed: completedStepCount,
                      total: totalStepCount,
                    ),
                    const SizedBox(height: 30),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Background Thai Characters
                        ...List.generate(categoryPlans.length, (index) {
                          if (index % 2 == 0) return const SizedBox.shrink();

                          int consonantIndex = 0;
                          for (int i = 0; i < categoryIndex; i++) {
                            consonantIndex +=
                                (plansByCategory[categoryNames[i]]!.length / 2)
                                    .floor();
                          }
                          consonantIndex += (index ~/ 2);

                          final char =
                              _thaiConsonants[consonantIndex %
                                  _thaiConsonants.length];
                          final nodeAlign =
                              alignments[index % alignments.length];
                          final charAlign = nodeAlign < 0 ? 0.8 : -0.8;

                          return Positioned(
                            top: (index * rowHeight) - 20,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Align(
                                alignment: Alignment(charAlign, 0),
                                child: Text(
                                  char,
                                  style: TextStyle(
                                    fontSize: 110,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.color
                                        ?.withValues(alpha: 0.08),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                        // Path - RepaintBoundary for performance
                        RepaintBoundary(
                          child: IgnorePointer(
                            child: CustomPaint(
                              size: Size(
                                width,
                                categoryPlans.length * rowHeight,
                              ),
                              painter: MapPathPainter(
                                points: points,
                                color: Colors.blueGrey.withValues(alpha: 0.15),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: List.generate(categoryPlans.length, (
                            index,
                          ) {
                            final plan = categoryPlans[index];
                            final completed = progress.getCompleted(plan.id);
                            final total = plan.steps.length;
                            final align = alignments[index % alignments.length];

                            return SizedBox(
                              height: rowHeight,
                              child: MapNode(
                                plan: plan,
                                completed: completed,
                                total: total,
                                alignment: align,
                                onLongPress: () => _showOptions(context, plan),
                                onTap: () async {
                                  if (progress.canTryLesson(plan.id)) {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => LessonScreen(
                                          category: plan.category,
                                          lessonId: plan.id,
                                        ),
                                      ),
                                    );
                                    onReturn();
                                  } else {
                                    _showSignupPrompt(context);
                                  }
                                },
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
