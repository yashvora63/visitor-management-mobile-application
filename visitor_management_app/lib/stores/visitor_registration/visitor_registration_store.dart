import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:visitor_management_app/data/repository.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/error/error_store.dart';
import 'package:visitor_management_app/stores/success/success_store.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';
import 'package:visitor_management_app/widgets/app_toast.dart';

part 'visitor_registration_store.g.dart';

class VisitorRegistrationStore = _VisitorRegistrationStore
    with _$VisitorRegistrationStore;

abstract class _VisitorRegistrationStore with Store {
  final Repository _repository;
  final ErrorStore errorStore = ErrorStore();
  final SuccessStore successStore = SuccessStore();

  _VisitorRegistrationStore(this._repository);

  static ObservableFuture<VisitorListModel?> emptyResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<VisitorListModel?> registerVisitorFuture = emptyResponse;

  @observable
  bool isLoading = false;

  @observable
  bool isSuccess = false;

  @observable
  VisitorListModel? createdVisitor;

  @computed
  bool get loading =>
      isLoading || registerVisitorFuture.status == FutureStatus.pending;

  @action
  Future<VisitorListModel?> registerVisitor(Map<String, dynamic> data) async {
    isLoading = true;
    isSuccess = false;
    errorStore.errorMessage = '';

    try {
      final future = _repository.registerVisitor(data);
      registerVisitorFuture = ObservableFuture(future);
      final visitor = await future;
      createdVisitor = visitor;
      isSuccess = true;
      successStore.setErrorMessage('Visitor registered successfully!');
      AppToast.showSuccess(message: 'Visitor registered successfully!');
      return visitor;
    } catch (err) {
      isSuccess = false;
      if (err is DioException) {
        errorStore.errorMessage = DioErrorUtil.handleError(err);
      } else {
        errorStore.errorMessage = err.toString();
      }
      AppToast.showError(message: errorStore.errorMessage);
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  Future<VisitorListModel?> updateVisitor(
    String id,
    Map<String, dynamic> data,
  ) async {
    isLoading = true;
    isSuccess = false;
    errorStore.errorMessage = '';

    try {
      final future = _repository.updateVisitor(id, data);
      registerVisitorFuture = ObservableFuture(future);
      final visitor = await future;
      createdVisitor = visitor;
      isSuccess = true;
      successStore.setErrorMessage('Visitor updated successfully!');
      AppToast.showSuccess(message: 'Visitor updated successfully!');
      return visitor;
    } catch (err) {
      isSuccess = false;
      if (err is DioException) {
        errorStore.errorMessage = DioErrorUtil.handleError(err);
      } else {
        errorStore.errorMessage = err.toString();
      }
      AppToast.showError(message: errorStore.errorMessage);
      rethrow;
    } finally {
      isLoading = false;
    }
  }

  @action
  void showSuccessToast(String message) {
    AppToast.showSuccess(message: message);
  }

  @action
  void showErrorToast(String message) {
    AppToast.showError(message: message);
  }

  @action
  void showWarningToast(String message) {
    AppToast.showWarning(message: message);
  }

  @action
  void reset() {
    isLoading = false;
    isSuccess = false;
    createdVisitor = null;
    errorStore.errorMessage = '';
    successStore.successMessage = '';
    registerVisitorFuture = emptyResponse;
  }
}
