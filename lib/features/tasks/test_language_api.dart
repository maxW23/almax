// ملف تجريبي لاختبار إرسال بارامتر اللغة إلى API المهام
// يمكن استخدامه للتأكد من أن النظام يعمل بشكل صحيح

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/features/home/presentation/manger/language/language_cubit.dart';
import 'data/datasources/tasks_api_service.dart';

class TestLanguageApiPage extends StatelessWidget {
  const TestLanguageApiPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Language API'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BlocBuilder<LanguageCubit, Locale>(
              builder: (context, locale) {
                return Text(
                  'Current Language: ${locale.languageCode}',
                  style: const TextStyle(fontSize: 18),
                );
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final languageCubit = context.read<LanguageCubit>();
                final currentLanguage = languageCubit.state.languageCode;

                final apiService = TasksApiService(ApiService());

                try {
                  final response = await apiService.getUserMissions(
                    languageCode: currentLanguage,
                  );

                  // ignore: avoid_print
                  print(
                      'API Response with language $currentLanguage: ${response.data}');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('API called with language: $currentLanguage'),
                      ),
                    );
                  }
                } catch (e) {
                  // ignore: avoid_print
                  print('API Error: $e');

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('API Error: $e'),
                        backgroundColor: const Color(0xFFFF0000),
                      ),
                    );
                  }
                }
              },
              child: const Text('Test API with Current Language'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final languageCubit = context.read<LanguageCubit>();
                final currentLang = languageCubit.state.languageCode;
                final newLang = currentLang == 'ar' ? 'en' : 'ar';
                languageCubit.switchLanguage(newLang);
              },
              child: const Text('Switch Language'),
            ),
          ],
        ),
      ),
    );
  }
}

/*
استخدام هذا الملف:

1. أضف هذه الصفحة إلى التطبيق للاختبار
2. اضغط على "Test API with Current Language" لاختبار إرسال اللغة الحالية
3. اضغط على "Switch Language" لتغيير اللغة ثم اختبر مرة أخرى
4. تحقق من console logs لرؤية الطلبات المرسلة:
   - GET https://lklklive.com/api/user/mession?ln=ar (للعربية)
   - GET https://lklklive.com/api/user/mession?ln=en (للإنجليزية)

مثال على الطلب المرسل:
GET https://lklklive.com/api/user/mession?ln=ar
Headers: {
  "Authorization": "Bearer YOUR_TOKEN"
}
*/
