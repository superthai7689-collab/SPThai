import 'package:superthai/core/models/models.dart';
import 'package:superthai/core/services/data_service.dart';

class TempMigrationService {
  static Future<void> markAsMeaning(LessonPlan plan, int stepIndex) async {
    if (stepIndex < 0 || stepIndex >= plan.steps.length) return;
    
    plan.steps[stepIndex].type = "Meaning";
    
    await DataService.instance.addLessonPlan(plan);
  }

  static String normalizeType(String type, Function(bool) onMigrated) {
    if (type == "Fill Blank" || type == "fillBlank") {
      onMigrated(true);
      return "Complete Sentence";
    }
    if (type == "English Meaning" || type == "englishMeaning") {
      onMigrated(true);
      return "Meaning";
    }
    return type;
  }
}
