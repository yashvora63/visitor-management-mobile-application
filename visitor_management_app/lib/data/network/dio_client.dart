import 'package:dio/dio.dart';
import 'package:visitor_management_app/widgets/app_toast.dart';
import 'package:visitor_management_app/stores/error/error_store.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';
import 'package:visitor_management_app/di/components/service_locator.dart';

class DioClient {
  final Dio _dio;
  late final ErrorStore errorStore = getIt<ErrorStore>();
  DioClient(this._dio);
  // ================= GET ================= //
  Future<dynamic> get(
    String uri, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.get(
        uri,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        AppToast.showError(message: DioErrorUtil.handleError(e));
      }
      rethrow;
    }
  }

  // ================= POST ================= //
  Future<dynamic> post(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.post(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        AppToast.showError(message: DioErrorUtil.handleError(e));
      }
      rethrow;
    }
  }

  // ================= PUT ================= //
  Future<dynamic> put(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.put(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        AppToast.showError(message: DioErrorUtil.handleError(e));
      }
      rethrow;
    }
  }

  // ================= PATCH ================= //
  Future<dynamic> patch(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final Response response = await _dio.patch(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );

      return response.data;
    } catch (e) {
      if (e is DioException) {
        AppToast.showError(message: DioErrorUtil.handleError(e));
      }
      rethrow;
    }
  }

  // ================= DELETE ================= //
  Future<dynamic> delete(
    String uri, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final Response response = await _dio.delete(
        uri,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response.data;
    } catch (e) {
      if (e is DioException) {
        AppToast.showError(message: DioErrorUtil.handleError(e));
      }
      rethrow;
    }
  }
}
