import 'package:lklk/core/utils/logger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ComprehensiveBlocObserver extends BlocObserver {
  /// يتم استدعاؤه عند إنشاء أي Bloc/Cubit لأول مرة
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    _log('🟢 Created', '${bloc.runtimeType}',
        details: 'HashCode: ${bloc.hashCode}');
  }

  /// يتم استدعاؤه عند إغلاق أي Bloc/Cubit
  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    _log('🔴 Closed', '${bloc.runtimeType}',
        details: 'HashCode: ${bloc.hashCode}');
  }

  /// لتتبع تغييرات الحالة في الـ Cubit
  // @override
  // void onChange(BlocBase bloc, Change change) {
  //   super.onChange(bloc, change);
  //   _log(
  //     '🟡 Cubit State Change',
  //     '${bloc.runtimeType}',
  //     details: 'Current: ${change.currentState}\nNext: ${change.nextState}',
  //   );
  // }

  // /// لتتبع الأحداث والتحولات في الـ Bloc
  // @override
  // void onEvent(Bloc bloc, Object? event) {
  //   super.onEvent(bloc, event);
  //   _log(
  //     '🔵 Event Added',
  //     '${bloc.runtimeType}',
  //     details: 'Event: $event',
  //   );
  // }

  // /// لتتبع التحولات الكاملة في الـ Bloc (Event → State)
  // @override
  // void onTransition(Bloc bloc, Transition transition) {
  //   super.onTransition(bloc, transition);
  //   _log(
  //     '🔄 Transition',
  //     '${bloc.runtimeType}',
  //     details: 'Event: ${transition.event}\n'
  //         'Current: ${transition.currentState}\n'
  //         'Next: ${transition.nextState}',
  //   );
  // }

  /// لتتبع الأخطاء في أي Bloc/Cubit
  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    _log(
      '⛔ Error',
      '${bloc.runtimeType}',
      details: 'Error: $error\n'
          'State: ${bloc.state}\n'
          'StackTrace: $stackTrace',
      isError: true,
    );
  }

  /// دالة مساعدة لتنظيم شكل الرسائل
  void _log(String title, String blocType,
      {String? details, bool isError = false}) {
    final time = DateTime.now().toIso8601String();
    final message = '''
    ==========================================================
    $title ➤ $blocType
    Time: $time
    ${details != null ? 'Details:\n$details' : ''}
    ==========================================================''';

    if (isError) {
      log(message, name: 'BLOC OBSERVER', error: details);
    } else {
      log(message, name: 'BLOC OBSERVER');
    }
  }
}
