import 'package:dio/dio.dart';
import 'package:visitor_management_app/data/network/dio_client.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';
import 'package:visitor_management_app/data/network/constants/endpoints.dart';

class VisitorRegistrationApi {
  final DioClient _dioClient;

  VisitorRegistrationApi(this._dioClient);

  Future<VisitorListModel> registerVisitor(Map<String, dynamic> data) async {
    try {
      final url = Endpoints.visitors;
      final res = await _dioClient.post(url, data: data);
      if (res is Map<String, dynamic>) {
        return VisitorListModel.fromJson(res);
      }
      throw 'Invalid response format from server';
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }

  Future<VisitorListModel> updateVisitor(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = "${Endpoints.visitors}/$id";
      final res = await _dioClient.put(url, data: data);
      if (res is Map<String, dynamic>) {
        return VisitorListModel.fromJson(res);
      }
      throw 'Invalid response format from server';
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }

  Future<VisitorListModel> patchVisitor(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = "${Endpoints.visitors}/$id";
      final res = await _dioClient.patch(url, data: data);
      if (res is Map<String, dynamic>) {
        return VisitorListModel.fromJson(res);
      }
      throw 'Invalid response format from server';
    } on DioException catch (err) {
      try {
        final url = "${Endpoints.visitors}/$id";
        final res = await _dioClient.put(url, data: data);
        if (res is Map<String, dynamic>) {
          return VisitorListModel.fromJson(res);
        }
      } catch (_) {}
      throw DioErrorUtil.handleError(err);
    }
  }

  Future<bool> addVisitorRegistration() async {
    try {
      final url = Endpoints.visitors;
      final res = await _dioClient.post(url);
      if (res is List) {
        return true;
      } else if (res is Map<String, dynamic> && res['data'] is List) {
        return true;
      }
      return false;
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }
}

