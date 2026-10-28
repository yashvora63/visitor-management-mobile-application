import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:visitor_management_app/data/repository.dart';
import 'package:visitor_management_app/widgets/app_toast.dart';
import 'package:visitor_management_app/constants/strings.dart';
import 'package:visitor_management_app/stores/error/error_store.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';
import 'package:visitor_management_app/stores/success/success_store.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';

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

  // Form Field Observables
  @observable
  String name = '';

  @observable
  String mobile = '';

  @observable
  String email = '';

  @observable
  String project = '';

  @observable
  String purpose = '';

  @observable
  String selectedVisitorType = 'Customer';

  @observable
  String status = Strings.statusRegistered;

  // Static options
  final List<String> visitorTypes = const ['Customer', 'Vendor', 'Other'];

  final List<String> projects = const ['Project A', 'Project B', 'Project C'];

  final List<String> commonPurposes = const [
    'Site Visit',
    'Meeting',
    'Delivery',
    'Maintenance',
    'Interview',
    'Client Discussion',
  ];

  @computed
  bool get loading =>
      isLoading || registerVisitorFuture.status == FutureStatus.pending;

  @action
  void setName(String val) => name = val;

  @action
  void setMobile(String val) => mobile = val;

  @action
  void setEmail(String val) => email = val;

  @action
  void setProject(String val) => project = val;

  @action
  void setPurpose(String val) => purpose = val;

  @action
  void setVisitorType(String val) {
    if (visitorTypes.contains(val)) {
      selectedVisitorType = val;
    }
  }

  @action
  void setStatus(String val) => status = val;

  @action
  void initForm({VisitorListModel? visitor}) {
    if (visitor != null) {
      name = visitor.name;
      mobile = visitor.mobile;
      email = visitor.email;
      project = visitor.project.isNotEmpty ? visitor.project : 'Project A';
      purpose = visitor.purpose;
      if (visitorTypes.contains(visitor.visitorType)) {
        selectedVisitorType = visitor.visitorType;
      }
      status = visitor.status.isNotEmpty
          ? visitor.status
          : Strings.statusRegistered;
    } else {
      resetForm();
    }
  }

  @action
  void resetForm() {
    name = '';
    mobile = '';
    email = '';
    project = 'Project A';
    purpose = '';
    selectedVisitorType = 'Customer';
    status = Strings.statusRegistered;
    reset();
  }

  @action
  String generateUniqueVisitorId(List<VisitorListModel> existingVisitors) {
    final existingIds = existingVisitors
        .map((v) => v.id.trim().toUpperCase())
        .toSet();

    // 1. Find highest existing sequential number under 10000 (e.g. VIS001 -> 1, VIS002 -> 2)
    // Avoid large legacy timestamps by limiting to up to 4 digits
    int maxNum = 0;
    for (final v in existingVisitors) {
      final raw = v.id.trim().toUpperCase();
      final match = RegExp(r'^VIS-?0*([1-9]\d{0,3})$').firstMatch(raw);
      if (match != null) {
        final val = int.tryParse(match.group(1) ?? '0') ?? 0;
        if (val > maxNum) {
          maxNum = val;
        }
      }
    }

    // 2. Start from maxNum + 1 (or 1 if no existing sequential IDs)
    int candidateNum = maxNum > 0 ? maxNum + 1 : 1;

    // 3. Increment sequentially until an unused VIS001, VIS002, ... ID is found
    while (true) {
      final candidate = 'VIS${candidateNum.toString().padLeft(3, '0')}';
      if (!existingIds.contains(candidate)) {
        return candidate;
      }
      candidateNum++;
    }
  }

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
  Future<VisitorListModel> submitForm({
    required bool isEditing,
    String? existingId,
    String? existingCreatedAt,
    required List<VisitorListModel> existingVisitors,
  }) async {
    final createdAt = isEditing && existingCreatedAt != null
        ? existingCreatedAt
        : DateTime.now().toIso8601String();

    final uniqueId = isEditing && existingId != null && existingId.isNotEmpty
        ? existingId
        : generateUniqueVisitorId(existingVisitors);

    final currentStatus = isEditing ? status : Strings.statusRegistered;

    final payload = <String, dynamic>{
      'id': uniqueId,
      'name': name.trim(),
      'mobile': mobile.trim(),
      'email': email.trim(),
      'visitor_type': selectedVisitorType,
      'project': project.trim(),
      'purpose': purpose.trim(),
      'status': currentStatus,
      'created_at': createdAt,
      'check_in_time': null,
      'check_out_time': null,
    };

    VisitorListModel? result;
    if (isEditing && existingId != null) {
      result = await updateVisitor(existingId, payload);
    } else {
      result = await registerVisitor(payload);
    }

    return result ??
        VisitorListModel(
          id: payload['id'],
          name: payload['name'],
          mobile: payload['mobile'],
          email: payload['email'],
          visitorType: payload['visitor_type'],
          project: payload['project'],
          purpose: payload['purpose'],
          status: payload['status'],
          createdAt: DateTime.tryParse(createdAt),
          checkInTime: null,
          checkOutTime: null,
        );
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
