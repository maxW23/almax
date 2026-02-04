// service_locator.dart
import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lklk/core/services/api_service.dart';
import 'package:lklk/core/services/auth_result.dart';
import 'package:lklk/features/auth/domain/entities/user_entity.dart';
import 'package:lklk/features/auth/domain/use_cases/google_signin_use_case.dart';
import 'package:lklk/features/profile_users/presentaion/manger/user_cubit/user_cubit_cubit.dart';
import 'package:lklk/features/room/data/data_sources/luck_bag_remote_data_source.dart';
import 'package:lklk/features/room/data/repos/luck_bag_repository_impl.dart';
import 'package:lklk/features/room/domain/repos/luck_bag_repository.dart';
import 'package:lklk/features/room/domain/use_cases/get_bag_result_use_case.dart';
import 'package:lklk/features/room/presentation/manger/lucky_bag/luck_bag_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lklk/internal/sdk/livekit/livekit_audio_service.dart';
import 'package:lklk/features/livekit_audio/data/livekit_token_api.dart';
import 'package:lklk/features/livekit_audio/data/livekit_audio_remote.dart';
import 'package:lklk/features/livekit_audio/data/livekit_audio_repository_impl.dart';
import 'package:lklk/features/livekit_audio/domain/repositories/audio_repository.dart';
import 'package:lklk/features/livekit_audio/presentation/cubit/livekit_audio_cubit.dart';

final GetIt sl = GetIt.instance;

Future<void> init() async {
  // Cubits
  sl.registerLazySingleton(() => UserCubit(
        sl<GoogleSignInUseCase>(),
        sl<AuthApiClient>(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GoogleSignInUseCase());

  // Repositories/Api Clients
  sl.registerLazySingleton(() => AuthApiClient());

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Hive Initialization
  await Hive.initFlutter();
  Hive.registerAdapter(UserEntityAdapter());
  await Hive.openBox<UserEntity>('userCacheBox');

  // LuckBagCubit - التسجيل كـ Singleton فقط
  sl.registerLazySingleton<LuckBagCubit>(() => LuckBagCubit(
        getBagResultUseCase: sl(),
        purchaseBagUseCase: sl(),
        sendUltraMessageUseCase: sl(),
        completePurchaseFlowUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetBagResultUseCase(sl()));
  sl.registerLazySingleton(() => PurchaseBagUseCase(sl()));
  sl.registerLazySingleton(() => SendUltraMessageUseCase(sl()));
  sl.registerLazySingleton(() => CompletePurchaseFlowUseCase(
        getBagResultUseCase: sl(),
        purchaseBagUseCase: sl(),
      ));

  // Repository
  sl.registerLazySingleton<LuckBagRepository>(
    () => LuckBagRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LuckBagRemoteDataSource>(
    () => LuckBagRemoteDataSourceImpl(apiService: sl()),
  );

  // External
  // Use a single ApiService instance with request debounce to avoid bursty duplicate calls
  sl.registerLazySingleton(() => ApiService(
        enableRequestDebounce: true,
        requestDebounceDuration: const Duration(seconds: 2),
      ));

  // ================== LiveKit Audio (Clean Architecture) ==================
  // Token API using ApiService baseUrl
  sl.registerLazySingleton<LiveKitTokenApi>(() => LiveKitTokenApiImpl(sl()));
  // Remote facade wrapping LiveKitAudioService singleton
  sl.registerLazySingleton<LiveKitAudioRemote>(
      () => LiveKitAudioRemoteImpl(LiveKitAudioService.instance));
  // Repository
  sl.registerLazySingleton<AudioRepository>(() => LiveKitAudioRepositoryImpl(
        remote: sl(),
        tokenApi: sl(),
      ));
  // Cubit (factory)
  sl.registerFactory<LiveKitAudioCubit>(() => LiveKitAudioCubit(sl()));
}

void resetLuckBagCubit() {
  if (sl.isRegistered<LuckBagCubit>()) {
    // احذف القديم
    sl.unregister<LuckBagCubit>();
  }

  // سجل Cubit جديد
  sl.registerFactory<LuckBagCubit>(() => LuckBagCubit(
        getBagResultUseCase: sl(),
        purchaseBagUseCase: sl(),
        sendUltraMessageUseCase: sl(),
        completePurchaseFlowUseCase: sl(),
      ));
}
