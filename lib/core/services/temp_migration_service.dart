import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';

/// [TEMPORARY] Legacy Migration Service
/// This service handles migration from old question types like "Fill Blank" to new types.
/// It can be safely removed once all data is migrated.
class TempMigrationService {
  
  /// Migrates a single step from "Complete Sentense" to "Meaning"
  /// and saves the entire plan back to Firestore.
  static Future<void> markAsMeaning(LessonPlan plan, int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= plan.steps.length) return;
    
    // Change type in memory
    plan.steps[stepIndex].type = "Meaning";
    
    // Save to Firebase
    await DataService.instance.addLessonPlan(plan);
  }

  /// [TEMPORARY] Normalize legacy types during data loading.
  /// Used in models.dart
  static String normalizeType(String type, Function(bool) onMigrated) {
    if (type == "Fill Blank" || type == "fillBlank") {
      onMigrated(true);
      return "Complete Sentense";
    }
    if (type == "English Meaning" || type == "englishMeaning") {
      onMigrated(true);
      return "Meaning";
    }
    return type;
  }
}
