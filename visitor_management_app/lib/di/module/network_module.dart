import 'package:dio/dio.dart';

import '../../data/network/constants/endpoints.dart';
import '../../data/sharedpref/shared_preference_helper.dart';

abstract class NetworkModule {
  /// A singleton dio provider.
  ///
  /// Calling it multiple times will return the same instance.
  static Dio provideDio(SharedPreferenceHelper sharedPrefHelper) {
    final dio = Dio();
    final tokenDio = Dio();

    final baseOptions = BaseOptions(
      baseUrl: Endpoints.baseUrl,
      connectTimeout: Duration(milliseconds: Endpoints.connectionTimeout),
      receiveTimeout: Duration(milliseconds: Endpoints.receiveTimeout),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
    );

    dio.options = baseOptions;
    tokenDio.options = baseOptions;

    tokenDio.interceptors.add(
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ),
    );

    dio.interceptors.addAll([
      LogInterceptor(
        request: true,
        responseBody: true,
        requestBody: true,
        requestHeader: true,
      ),
    ]);

    return dio;
  }
}
