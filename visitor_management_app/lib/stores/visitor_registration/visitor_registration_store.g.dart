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

  late final _$nameAtom = Atom(
    name: '_VisitorRegistrationStore.name',
    context: context,
  );

  @override
  String get name {
    _$nameAtom.reportRead();
    return super.name;
  }

  @override
  set name(String value) {
    _$nameAtom.reportWrite(value, super.name, () {
      super.name = value;
    });
  }

  late final _$mobileAtom = Atom(
    name: '_VisitorRegistrationStore.mobile',
    context: context,
  );

  @override
  String get mobile {
    _$mobileAtom.reportRead();
    return super.mobile;
  }

  @override
  set mobile(String value) {
    _$mobileAtom.reportWrite(value, super.mobile, () {
      super.mobile = value;
    });
  }

  late final _$emailAtom = Atom(
    name: '_VisitorRegistrationStore.email',
    context: context,
  );

  @override
  String get email {
    _$emailAtom.reportRead();
    return super.email;
  }

  @override
  set email(String value) {
    _$emailAtom.reportWrite(value, super.email, () {
      super.email = value;
    });
  }

  late final _$projectAtom = Atom(
    name: '_VisitorRegistrationStore.project',
    context: context,
  );

  @override
  String get project {
    _$projectAtom.reportRead();
    return super.project;
  }

  @override
  set project(String value) {
    _$projectAtom.reportWrite(value, super.project, () {
      super.project = value;
    });
  }

  late final _$purposeAtom = Atom(
    name: '_VisitorRegistrationStore.purpose',
    context: context,
  );

  @override
  String get purpose {
    _$purposeAtom.reportRead();
    return super.purpose;
  }

  @override
  set purpose(String value) {
    _$purposeAtom.reportWrite(value, super.purpose, () {
      super.purpose = value;
    });
  }

  late final _$selectedVisitorTypeAtom = Atom(
    name: '_VisitorRegistrationStore.selectedVisitorType',
    context: context,
  );

  @override
  String get selectedVisitorType {
    _$selectedVisitorTypeAtom.reportRead();
    return super.selectedVisitorType;
  }

  @override
  set selectedVisitorType(String value) {
    _$selectedVisitorTypeAtom.reportWrite(value, super.selectedVisitorType, () {
      super.selectedVisitorType = value;
    });
  }

  late final _$statusAtom = Atom(
    name: '_VisitorRegistrationStore.status',
    context: context,
  );

  @override
  String get status {
    _$statusAtom.reportRead();
    return super.status;
  }

  @override
  set status(String value) {
    _$statusAtom.reportWrite(value, super.status, () {
      super.status = value;
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

  late final _$submitFormAsyncAction = AsyncAction(
    '_VisitorRegistrationStore.submitForm',
    context: context,
  );

  @override
  Future<VisitorListModel> submitForm({
    required bool isEditing,
    String? existingId,
    String? existingCreatedAt,
    required List<VisitorListModel> existingVisitors,
  }) {
    return _$submitFormAsyncAction.run(() => super.submitForm(
          isEditing: isEditing,
          existingId: existingId,
          existingCreatedAt: existingCreatedAt,
          existingVisitors: existingVisitors,
        ));
  }

  late final _$_VisitorRegistrationStoreActionController = ActionController(
    name: '_VisitorRegistrationStore',
    context: context,
  );

  @override
  void setName(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setName');
    try {
      return super.setName(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setMobile(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setMobile');
    try {
      return super.setMobile(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setEmail(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setEmail');
    try {
      return super.setEmail(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setProject(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setProject');
    try {
      return super.setProject(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setPurpose(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setPurpose');
    try {
      return super.setPurpose(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setVisitorType(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setVisitorType');
    try {
      return super.setVisitorType(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void setStatus(String val) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.setStatus');
    try {
      return super.setStatus(val);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void initForm({VisitorListModel? visitor}) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.initForm');
    try {
      return super.initForm(visitor: visitor);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void resetForm() {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.resetForm');
    try {
      return super.resetForm();
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String generateUniqueVisitorId(List<VisitorListModel> existingVisitors) {
    final _$actionInfo = _$_VisitorRegistrationStoreActionController
        .startAction(name: '_VisitorRegistrationStore.generateUniqueVisitorId');
    try {
      return super.generateUniqueVisitorId(existingVisitors);
    } finally {
      _$_VisitorRegistrationStoreActionController.endAction(_$actionInfo);
    }
  }

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
name: ${name},
mobile: ${mobile},
email: ${email},
project: ${project},
purpose: ${purpose},
selectedVisitorType: ${selectedVisitorType},
status: ${status},
loading: ${loading}
    ''';
  }
}
