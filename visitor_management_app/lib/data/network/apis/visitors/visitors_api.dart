import 'package:dio/dio.dart';
import 'package:visitor_management_app/data/network/constants/endpoints.dart';
import 'package:visitor_management_app/data/network/dio_client.dart';
import 'package:visitor_management_app/models/visitor_detail/visitor_detail_model.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';

class VisitorListApi {
  final DioClient _dioClient;

  VisitorListApi(this._dioClient);

  Future<List<VisitorListModel>> getVisitorList() async {
    try {
      final url = Endpoints.visitors;
      final res = await _dioClient.get(url);
      if (res is List) {
        return res
            .map((e) => VisitorListModel.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res is Map<String, dynamic> && res['data'] is List) {
        return (res['data'] as List)
            .map((e) => VisitorListModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }

  Future<VisitorDetailModel> getVisitordetail(String id) async {
    try {
      final url = "${Endpoints.visitors}/$id";
      final res = await _dioClient.get(url);
      return VisitorDetailModel.fromJson(res);
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }

  Future<bool> deleteVisitor(String id) async {
    try {
      final url = "${Endpoints.visitors}/$id";
      await _dioClient.delete(url);
      return true;
    } on DioException catch (err) {
      throw DioErrorUtil.handleError(err);
    }
  }
}
