import 'package:dio/dio.dart';
import 'package:mobx/mobx.dart';
import 'package:visitor_management_app/data/repository.dart';
import 'package:visitor_management_app/models/visitor_detail/visitor_detail_model.dart';
import 'package:visitor_management_app/models/visitors_list/visitors_model.dart';
import 'package:visitor_management_app/stores/error/error_store.dart';
import 'package:visitor_management_app/stores/success/success_store.dart';
import 'package:visitor_management_app/utils/dio/dio_error_util.dart';

part 'visitor_list_store.g.dart';

class VisitorListStore = _VisitorListStore with _$VisitorListStore;

abstract class _VisitorListStore with Store {
  final Repository _repository;
  final ErrorStore errorStore = ErrorStore();
  final SuccessStore successStore = SuccessStore();

  _VisitorListStore(this._repository);

  static ObservableFuture<List<VisitorListModel>?> emptyResponse =
      ObservableFuture.value(null);

  static ObservableFuture<VisitorDetailModel?> emptyDetailResponse =
      ObservableFuture.value(null);

  @observable
  ObservableFuture<List<VisitorListModel>?> fetchVisitorListFuture = emptyResponse;

  @observable
  ObservableFuture<VisitorDetailModel?> fetchVisitorDetailFuture =
      emptyDetailResponse;

  @observable
  List<VisitorListModel> visitorList = [];

  @observable
  List<VisitorListModel> searchVisitorList = [];

  @observable
  List<VisitorListModel> _allVisitors = [];

  @observable
  VisitorDetailModel? visitorDetail;

  @observable
  String searchQuery = '';

  @observable
  String selectedStatusFilter = 'All';

  @observable
  String? selectedTypeFilter;

  // ================= Computed =================

  @computed
  bool get loading => fetchVisitorListFuture.status == FutureStatus.pending;

  @computed
  bool get isDetailLoading =>
      fetchVisitorDetailFuture.status == FutureStatus.pending;

  @computed
  bool get hasVisitors => visitorList.isNotEmpty;

  @computed
  int get totalVisitors => visitorList.length;

  @computed
  int get allVisitorsCount => _allVisitors.length;

  @computed
  int get checkedInVisitors => _allVisitors
      .where((v) {
        final status = v.status.toLowerCase();
        return status == 'checked in' ||
            status.contains('check_in') ||
            status == 'status 1';
      })
      .length;

  @computed
  int get checkedOutVisitors => _allVisitors
      .where((v) {
        final status = v.status.toLowerCase();
        return status == 'checked out' ||
            status.contains('check_out') ||
            status == 'status 2';
      })
      .length;

  // ================= Dashboard Calculative Metrics =================

  bool _isSameDayAsToday(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return false;
    final dt = DateTime.tryParse(dateStr.trim());
    if (dt != null) {
      final local = dt.toLocal();
      final now = DateTime.now();
      return local.year == now.year &&
          local.month == now.month &&
          local.day == now.day;
    }
    return false;
  }

  int get totalVisitorsToday {
    final parsedCount =
        _allVisitors.where((v) => _isSameDayAsToday(v.createdAt.toString())).length;
    if (parsedCount > 0) return parsedCount;
    final hasAnyValidDate =
        _allVisitors.any((v) => DateTime.tryParse(v.createdAt.toString().trim()) != null);
    if (!hasAnyValidDate && _allVisitors.isNotEmpty) {
      return _allVisitors.length;
    }
    return 0;
  }

  int get currentlyCheckedIn => checkedInVisitors;

  int get checkedOutToday {
    final checkedOutList = _allVisitors.where((v) {
      final status = v.status.toLowerCase();
      return status == 'checked out' ||
          status.contains('check_out') ||
          status == 'status 2';
    }).toList();

    final parsedCount =
        checkedOutList.where((v) => _isSameDayAsToday(v.checkOutTime.toString())).length;
    if (parsedCount > 0) return parsedCount;
    final hasAnyValidDate = checkedOutList.any(
      (v) => DateTime.tryParse(v.checkOutTime.toString().trim()) != null,
    );
    if (!hasAnyValidDate && checkedOutList.isNotEmpty) {
      return checkedOutList.length;
    }
    return 0;
  }

  int get registeredVisitorsCount => _allVisitors.where((v) {
        final status = v.status.toLowerCase();
        return status == 'registered' ||
            status.contains('register') ||
            status == 'status 3';
      }).length;

  List<VisitorListModel> get allVisitors => _allVisitors;

  List<VisitorListModel> get recentVisitors {
    if (_allVisitors.isEmpty) return [];
    return _allVisitors.reversed.take(5).toList();
  }

  // ================= Actions =================

  @action
  Future<List<VisitorListModel>> getVisitorList() async {
    final future = _repository.getVisitorList();
    fetchVisitorListFuture = ObservableFuture(future);

    try {
      final list = await future;
      _allVisitors = list;
      _applyFilterAndSearch();
      return list;
    } catch (err) {
      if (err is DioException) {
        errorStore.errorMessage = DioErrorUtil.handleError(err);
      } else {
        errorStore.errorMessage = err.toString();
      }
      rethrow;
    }
  }

  @action
  Future<VisitorDetailModel?> getVisitorDetail(String id) async {
    final future = _repository.getVisitordetail(id);
    fetchVisitorDetailFuture = ObservableFuture(future);

    try {
      final detail = await future;
      visitorDetail = detail;
      return detail;
    } catch (err) {
      if (err is DioException) {
        errorStore.errorMessage = DioErrorUtil.handleError(err);
      } else {
        errorStore.errorMessage = err.toString();
      }
      rethrow;
    }
  }

  @action
  void searchVisitor(String query) {
    searchQuery = query;
    _applyFilterAndSearch();
  }

  @action
  void filterByStatus(String status) {
    selectedStatusFilter = status;
    _applyFilterAndSearch();
  }

  @action
  void filterByType(String? visitorType) {
    selectedTypeFilter = visitorType;
    _applyFilterAndSearch();
  }

  @action
  void resetFilters() {
    searchQuery = '';
    selectedStatusFilter = 'All';
    selectedTypeFilter = null;
    visitorList = List.from(_allVisitors);
    searchVisitorList = List.from(_allVisitors);
  }

  @action
  void setVisitors(List<VisitorListModel> list) {
    _allVisitors = list;
    _applyFilterAndSearch();
  }

  void _applyFilterAndSearch() {
    List<VisitorListModel> result = List.from(_allVisitors);

    // Filter by status
    if (selectedStatusFilter.isNotEmpty &&
        selectedStatusFilter.toLowerCase() != 'all') {
      result = result
          .where(
            (v) =>
                v.status.toLowerCase() == selectedStatusFilter.toLowerCase(),
          )
          .toList();
    }

    // Filter by visitor type
    if (selectedTypeFilter != null &&
        selectedTypeFilter!.isNotEmpty &&
        selectedTypeFilter!.toLowerCase() != 'all') {
      result = result
          .where(
            (v) =>
                v.visitorType.toLowerCase() ==
                selectedTypeFilter!.toLowerCase(),
          )
          .toList();
    }

    // Filter by search query
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      result = result.where((v) {
        final nameMatch = v.name.toLowerCase().contains(q);
        final mobileMatch = v.mobile.toString().contains(q);
        final emailMatch = v.email.toLowerCase().contains(q);
        final projectMatch = v.project.toLowerCase().contains(q);
        final purposeMatch = v.purpose.toLowerCase().contains(q);
        final typeMatch = v.visitorType.toLowerCase().contains(q);
        final statusMatch = v.status.toLowerCase().contains(q);
        return nameMatch ||
            mobileMatch ||
            emailMatch ||
            projectMatch ||
            purposeMatch ||
            typeMatch ||
            statusMatch;
      }).toList();
    }

    visitorList = result;
    searchVisitorList = result;
  }
}
