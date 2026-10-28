// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_list_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VisitorListStore on _VisitorListStore, Store {
  Computed<bool>? _$loadingComputed;

  @override
  bool get loading => (_$loadingComputed ??= Computed<bool>(
    () => super.loading,
    name: '_VisitorListStore.loading',
  )).value;
  Computed<bool>? _$isDetailLoadingComputed;

  @override
  bool get isDetailLoading => (_$isDetailLoadingComputed ??= Computed<bool>(
    () => super.isDetailLoading,
    name: '_VisitorListStore.isDetailLoading',
  )).value;
  Computed<bool>? _$isStatusUpdatingComputed;

  @override
  bool get isStatusUpdating => (_$isStatusUpdatingComputed ??= Computed<bool>(
    () => super.isStatusUpdating,
    name: '_VisitorListStore.isStatusUpdating',
  )).value;
  Computed<bool>? _$hasVisitorsComputed;

  @override
  bool get hasVisitors => (_$hasVisitorsComputed ??= Computed<bool>(
    () => super.hasVisitors,
    name: '_VisitorListStore.hasVisitors',
  )).value;
  Computed<int>? _$totalVisitorsComputed;

  @override
  int get totalVisitors => (_$totalVisitorsComputed ??= Computed<int>(
    () => super.totalVisitors,
    name: '_VisitorListStore.totalVisitors',
  )).value;
  Computed<int>? _$allVisitorsCountComputed;

  @override
  int get allVisitorsCount => (_$allVisitorsCountComputed ??= Computed<int>(
    () => super.allVisitorsCount,
    name: '_VisitorListStore.allVisitorsCount',
  )).value;
  Computed<int>? _$checkedInVisitorsComputed;

  @override
  int get checkedInVisitors => (_$checkedInVisitorsComputed ??= Computed<int>(
    () => super.checkedInVisitors,
    name: '_VisitorListStore.checkedInVisitors',
  )).value;
  Computed<int>? _$checkedOutVisitorsComputed;

  @override
  int get checkedOutVisitors => (_$checkedOutVisitorsComputed ??= Computed<int>(
    () => super.checkedOutVisitors,
    name: '_VisitorListStore.checkedOutVisitors',
  )).value;

  late final _$fetchVisitorListFutureAtom = Atom(
    name: '_VisitorListStore.fetchVisitorListFuture',
    context: context,
  );

  @override
  ObservableFuture<List<VisitorListModel>?> get fetchVisitorListFuture {
    _$fetchVisitorListFutureAtom.reportRead();
    return super.fetchVisitorListFuture;
  }

  @override
  set fetchVisitorListFuture(ObservableFuture<List<VisitorListModel>?> value) {
    _$fetchVisitorListFutureAtom.reportWrite(
      value,
      super.fetchVisitorListFuture,
      () {
        super.fetchVisitorListFuture = value;
      },
    );
  }

  late final _$fetchVisitorDetailFutureAtom = Atom(
    name: '_VisitorListStore.fetchVisitorDetailFuture',
    context: context,
  );

  @override
  ObservableFuture<VisitorDetailModel?> get fetchVisitorDetailFuture {
    _$fetchVisitorDetailFutureAtom.reportRead();
    return super.fetchVisitorDetailFuture;
  }

  @override
  set fetchVisitorDetailFuture(ObservableFuture<VisitorDetailModel?> value) {
    _$fetchVisitorDetailFutureAtom.reportWrite(
      value,
      super.fetchVisitorDetailFuture,
      () {
        super.fetchVisitorDetailFuture = value;
      },
    );
  }

  late final _$updateStatusFutureAtom = Atom(
    name: '_VisitorListStore.updateStatusFuture',
    context: context,
  );

  @override
  ObservableFuture<VisitorListModel?> get updateStatusFuture {
    _$updateStatusFutureAtom.reportRead();
    return super.updateStatusFuture;
  }

  @override
  set updateStatusFuture(ObservableFuture<VisitorListModel?> value) {
    _$updateStatusFutureAtom.reportWrite(value, super.updateStatusFuture, () {
      super.updateStatusFuture = value;
    });
  }

  late final _$visitorListAtom = Atom(
    name: '_VisitorListStore.visitorList',
    context: context,
  );

  @override
  List<VisitorListModel> get visitorList {
    _$visitorListAtom.reportRead();
    return super.visitorList;
  }

  @override
  set visitorList(List<VisitorListModel> value) {
    _$visitorListAtom.reportWrite(value, super.visitorList, () {
      super.visitorList = value;
    });
  }

  late final _$searchVisitorListAtom = Atom(
    name: '_VisitorListStore.searchVisitorList',
    context: context,
  );

  @override
  List<VisitorListModel> get searchVisitorList {
    _$searchVisitorListAtom.reportRead();
    return super.searchVisitorList;
  }

  @override
  set searchVisitorList(List<VisitorListModel> value) {
    _$searchVisitorListAtom.reportWrite(value, super.searchVisitorList, () {
      super.searchVisitorList = value;
    });
  }

  late final _$_allVisitorsAtom = Atom(
    name: '_VisitorListStore._allVisitors',
    context: context,
  );

  @override
  List<VisitorListModel> get _allVisitors {
    _$_allVisitorsAtom.reportRead();
    return super._allVisitors;
  }

  @override
  set _allVisitors(List<VisitorListModel> value) {
    _$_allVisitorsAtom.reportWrite(value, super._allVisitors, () {
      super._allVisitors = value;
    });
  }

  late final _$visitorDetailAtom = Atom(
    name: '_VisitorListStore.visitorDetail',
    context: context,
  );

  @override
  VisitorDetailModel? get visitorDetail {
    _$visitorDetailAtom.reportRead();
    return super.visitorDetail;
  }

  @override
  set visitorDetail(VisitorDetailModel? value) {
    _$visitorDetailAtom.reportWrite(value, super.visitorDetail, () {
      super.visitorDetail = value;
    });
  }

  late final _$searchQueryAtom = Atom(
    name: '_VisitorListStore.searchQuery',
    context: context,
  );

  @override
  String get searchQuery {
    _$searchQueryAtom.reportRead();
    return super.searchQuery;
  }

  @override
  set searchQuery(String value) {
    _$searchQueryAtom.reportWrite(value, super.searchQuery, () {
      super.searchQuery = value;
    });
  }

  late final _$selectedStatusFilterAtom = Atom(
    name: '_VisitorListStore.selectedStatusFilter',
    context: context,
  );

  @override
  String get selectedStatusFilter {
    _$selectedStatusFilterAtom.reportRead();
    return super.selectedStatusFilter;
  }

  @override
  set selectedStatusFilter(String value) {
    _$selectedStatusFilterAtom.reportWrite(
      value,
      super.selectedStatusFilter,
      () {
        super.selectedStatusFilter = value;
      },
    );
  }

  late final _$selectedTypeFilterAtom = Atom(
    name: '_VisitorListStore.selectedTypeFilter',
    context: context,
  );

  @override
  String? get selectedTypeFilter {
    _$selectedTypeFilterAtom.reportRead();
    return super.selectedTypeFilter;
  }

  @override
  set selectedTypeFilter(String? value) {
    _$selectedTypeFilterAtom.reportWrite(value, super.selectedTypeFilter, () {
      super.selectedTypeFilter = value;
    });
  }

  late final _$getVisitorListAsyncAction = AsyncAction(
    '_VisitorListStore.getVisitorList',
    context: context,
  );

  @override
  Future<List<VisitorListModel>> getVisitorList() {
    return _$getVisitorListAsyncAction.run(() => super.getVisitorList());
  }

  late final _$getVisitorDetailAsyncAction = AsyncAction(
    '_VisitorListStore.getVisitorDetail',
    context: context,
  );

  @override
  Future<VisitorDetailModel?> getVisitorDetail(String id) {
    return _$getVisitorDetailAsyncAction.run(() => super.getVisitorDetail(id));
  }

  late final _$checkInVisitorAsyncAction = AsyncAction(
    '_VisitorListStore.checkInVisitor',
    context: context,
  );

  @override
  Future<VisitorListModel> checkInVisitor(String id) {
    return _$checkInVisitorAsyncAction.run(() => super.checkInVisitor(id));
  }

  late final _$checkOutVisitorAsyncAction = AsyncAction(
    '_VisitorListStore.checkOutVisitor',
    context: context,
  );

  @override
  Future<VisitorListModel> checkOutVisitor(String id) {
    return _$checkOutVisitorAsyncAction.run(() => super.checkOutVisitor(id));
  }

  late final _$_VisitorListStoreActionController = ActionController(
    name: '_VisitorListStore',
    context: context,
  );

  @override
  void searchVisitor(String query) {
    final _$actionInfo = _$_VisitorListStoreActionController.startAction(
      name: '_VisitorListStore.searchVisitor',
    );
    try {
      return super.searchVisitor(query);
    } finally {
      _$_VisitorListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void filterByStatus(String status) {
    final _$actionInfo = _$_VisitorListStoreActionController.startAction(
      name: '_VisitorListStore.filterByStatus',
    );
    try {
      return super.filterByStatus(status);
    } finally {
      _$_VisitorListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void filterByType(String? visitorType) {
    final _$actionInfo = _$_VisitorListStoreActionController.startAction(
      name: '_VisitorListStore.filterByType',
    );
    try {
      return super.filterByType(visitorType);
    } finally {
      _$_VisitorListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetFilters() {
    final _$actionInfo = _$_VisitorListStoreActionController.startAction(
      name: '_VisitorListStore.resetFilters',
    );
    try {
      return super.resetFilters();
    } finally {
      _$_VisitorListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVisitors(List<VisitorListModel> list) {
    final _$actionInfo = _$_VisitorListStoreActionController.startAction(
      name: '_VisitorListStore.setVisitors',
    );
    try {
      return super.setVisitors(list);
    } finally {
      _$_VisitorListStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
fetchVisitorListFuture: ${fetchVisitorListFuture},
fetchVisitorDetailFuture: ${fetchVisitorDetailFuture},
updateStatusFuture: ${updateStatusFuture},
visitorList: ${visitorList},
searchVisitorList: ${searchVisitorList},
visitorDetail: ${visitorDetail},
searchQuery: ${searchQuery},
selectedStatusFilter: ${selectedStatusFilter},
selectedTypeFilter: ${selectedTypeFilter},
loading: ${loading},
isDetailLoading: ${isDetailLoading},
isStatusUpdating: ${isStatusUpdating},
hasVisitors: ${hasVisitors},
totalVisitors: ${totalVisitors},
allVisitorsCount: ${allVisitorsCount},
checkedInVisitors: ${checkedInVisitors},
checkedOutVisitors: ${checkedOutVisitors}
    ''';
  }
}
