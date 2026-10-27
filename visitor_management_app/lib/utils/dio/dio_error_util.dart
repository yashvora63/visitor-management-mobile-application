import 'package:dio/dio.dart';

class DioErrorUtil {
  // general methods:------------------------------------------------------------
  static String handleError(dynamic error) {
    if (error is String) return error;
    String errorDescription = "";
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          errorDescription = "Request to API server was cancelled";
          break;
        case DioExceptionType.connectionTimeout:
          errorDescription = "Connection timeout with API server";
          break;
        case DioExceptionType.sendTimeout:
          errorDescription = "Send timeout in connection with API server";
          break;
        case DioExceptionType.receiveTimeout:
          errorDescription = "Receive timeout in connection with API server";
          break;
        case DioExceptionType.badResponse:
          errorDescription =
              "${error.response?.data['detail'] ?? "Bad Request"}";
          break;
        case DioExceptionType.badCertificate:
          errorDescription = "Bad certificate in connection with API server";
          break;
        case DioExceptionType.connectionError:
          errorDescription =
              "No internet connection. Please check your network and try again.";
          break;
        case DioExceptionType.unknown:
        default:
          errorDescription =
              "Connection to API server failed due to internet connection";
          break;
      }
    } else {
      errorDescription = "Unexpected error occurred: $error";
    }
    return errorDescription;
  }
}
