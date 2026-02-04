import 'package:lklk/core/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../domain/entities/user_entity.dart';

class AuthRepository {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<UserEntity?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        log('تم تسجيل الدخول بنجاح: ${googleUser.email}');

        final user = UserEntity.fromGoogleSignIn(googleUser);
        return user;
      } else {
        log('فشل تسجيل الدخول أو تم إلغاؤه من قبل المستخدم.');
        return null;
      }
    } catch (e) {
      log('حدث خطأ أثناء تسجيل الدخول: $e');
      // Rethrow so upper layers can classify and present accurate errors
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();

        log('تم تسجيل الخروج وقطع الاتصال بنجاح.');
      } else {
        log('المستخدم غير متصل بالفعل.');
      }
    } catch (e) {
      log('حدث خطأ أثناء تسجيل الخروج: $e');
    }
  }
}
