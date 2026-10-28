// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'visitor_registration_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$VisitorRegistrationStore on _VisitorRegistrationStore, Store {
  Computed<bool>? _$loadingComputed;

  @override
  bool get loading => (_$loadingComputed ??= Computed<bool>(
    () => super.loading,
    name: '_VisitorRegistrationStore.loading',
  )).value;

  late final _$registerVisitorFutureAtom = Atom(
    name: '_VisitorRegistrationStore.registerVisitorFuture',
    context: context,
  );

  @override
  ObservableFuture<VisitorListModel?> get registerVisitorFuture {
    _$registerVisitorFutureAtom.reportRead();
    return super.registerVisitorFuture;
  }

  @override
  set registerVisitorFuture(ObservableFuture<VisitorListModel?> value) {
    _$registerVisitorFutureAtom.reportWrite(
      value,
      super.registerVisitorFuture,
      () {
        super.registerVisitorFuture = value;
      },
    );
  }

  late final _$isLoadingAtom = Atom(
    name: '_VisitorRegistrationStore.isLoading',
    context: context,
  );

  @override
  bool get isLoading {
    _$isLoadingAtom.reportRead();
    return super.isLoading;
  }

  @override
  set isLoading(bool value) {
    _$isLoadingAtom.reportWrite(value, super.isLoading, () {
      super.isLoading = value;
    });
  }

  late final _$isSuccessAtom = Atom(
    name: '_VisitorRegistrationStore.isSuccess',
    context: context,
  );

  @override
  bool get isSuccess {
    _$isSuccessAtom.reportRead();
    return super.isSuccess;
  }

  @override
  set isSuccess(bool value) {
    _$isSuccessAtom.reportWrite(value, super.isSuccess, () {
      super.isSuccess = value;
    });
  }

  late final _$createdVisitorAtom = Atom(
    name: '_VisitorRegistrationStore.createdVisitor',
    context: context,
  );

  @override
  VisitorListModel? get createdVisitor {
    _$createdVisitorAtom.reportRead();
    return super.createdVisitor;
  }

  @override
  set createdVisitor(VisitorListModel? value) {
    _$createdVisitorAtom.reportWrite(value, super.createdVisitor, () {
      super.createdVisitor = value;
    });
  }

  late final _$registerVisitorAsyncAction = AsyncAction(
    '_VisitorRegistrationStore.registerVisitor',
    context: context,
  );

  @override
  Future<VisitorListModel?> registerVisitor(Map<String, dynamic> data) {
    return _$registerVisitorAsyncAction.run(() => super.registerVisitor(data));
  }

  late final _$updateVisitorAsyncAction = AsyncAction(
    '_VisitorRegistrationStore.updateVisitor',
    context: context,
  );

  @override
  Future<VisitorListModel?> updateVisitor(
    String id,
    Map<String, dynamic> data,
  ) {
    return _$updateVisitorAsyncAction.run(() => super.updateVisitor(id, data));
  }

  late final _$_VisitorRegistrationStoreActionController = ActionController(
    name: '_VisitorRegistrationStore',
    context: context,
  );

  @override
  void showSuccessToast(String message) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.showSuccessToast');
    try {
      return super.showSuccessToast(message);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showErrorToast(String message) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.showErrorToast');
    try {
      return super.showErrorToast(message);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void showWarningToast(String message) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.showWarningToast');
    try {
      return super.showWarningToast(message);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset() {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.reset');
    try {
      return super.reset();
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
registerVisitorFuture: ${registerVisitorFuture},
isLoading: ${isLoading},
isSuccess: ${isSuccess},
createdVisitor: ${createdVisitor},
loading: ${loading}
    ''';
  }
}
