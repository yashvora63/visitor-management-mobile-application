import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import '../../data/repository.dart';
import '../module/network_module.dart';
import '../../data/network/dio_client.dart';
import '../../data/network/rest_client.dart';
import '../../stores/theme/theme_store.dart';
import '../../stores/error/error_store.dart';
import '../../stores/success/success_store.dart';
import '../../stores/language/language_store.dart';
import '../../stores/navigation/navigation_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/sharedpref/shared_preference_helper.dart';
import 'package:visitor_management_app/di/module/local_module.dart';

final getIt = GetIt.instance;

Future<void> setupLocator() async {
  // factories:-----------------------------------------------------------------
  getIt.registerFactory(() => ErrorStore());
  getIt.registerFactory(() => SuccessStore());

  // async singletons:----------------------------------------------------------
  getIt.registerSingletonAsync<SharedPreferences>(
    () => LocalModule.provideSharedPreferences(),
  );

  // singletons:----------------------------------------------------------------
  getIt.registerSingleton(
    SharedPreferenceHelper(await getIt.getAsync<SharedPreferences>()),
  );
  getIt.registerSingleton<Dio>(
    NetworkModule.provideDio(getIt<SharedPreferenceHelper>()),
  );
  getIt.registerSingleton(DioClient(getIt<Dio>()));
  getIt.registerSingleton(RestClient());

  // repository:----------------------------------------------------------------
  getIt.registerSingleton(Repository(getIt<SharedPreferenceHelper>()));

  // stores:--------------------------------------------------------------------
  getIt.registerSingleton(LanguageStore(getIt<Repository>()));
  getIt.registerSingleton(ThemeStore(getIt<Repository>()));
  getIt.registerSingleton(NavigationStore(getIt<Repository>()));
}
