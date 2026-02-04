import 'package:lklk/core/utils/logger.dart';

import 'package:lklk/features/auth/domain/entities/user_entity.dart';

/// دالة مساعدة لطباعة عناصر القائمة بفاصل بين كل عنصر والآخر
// void logWithSeparator(String context, List<dynamic> data) {
//   if (data.isEmpty) {
//     log("$context: القائمة فارغة");
//     return;
//   }
//   final formattedData = data
//       .map((element) => element.toString())
//       .join('\n---------:::::==::::::-----------\n');
//   log("$context:::::==::::::$formattedData");
// }
/// دالة لطباعة id و name لكل مستخدم بفاصل بين كل عنصر والآخر
void logUserIdsAndNames(String context, List<UserEntity> users) {
  if (users.isEmpty) {
    log("$context: القائمة فارغة");
    return;
  }
  for (var user in users) {
    log("$context:::::==:::::: id: ${user.iduser}, |||========||| name: ${user.name} :::::==::::::----------------:::::==:::::::::::==::::::----------------:::::==:::::::::::==::::::----------------:::::==::::::");
    log(" ---- \n");
  }
  log(" ---- \n");
  log(" ---- \n");
}
