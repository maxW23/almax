import 'package:lklk/generated/l10n.dart';

// Adapter extension to reuse existing keys for Weekly Event labels
extension WeeklyEventL10n on S {
  // Maps to existing 'weekly' key in ARB
  String get thisWeekLabel => weekly;
  // There is no explicit 'bonus' key; reuse 'gifts' to avoid hardcoded text
  String get bounsLabel => gifts;
}
