// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'success_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$SuccessStore on _SuccessStore, Store {
  late final _$successMessageAtom = Atom(
    name: '_SuccessStore.successMessage',
    context: context,
  );

  @override
  String get successMessage {
    _$successMessageAtom.reportRead();
    return super.successMessage;
  }

  @override
  set successMessage(String value) {
    _$successMessageAtom.reportWrite(value, super.successMessage, () {
      super.successMessage = value;
    });
  }

  late final _$_SuccessStoreActionController = ActionController(
    name: '_SuccessStore',
    context: context,
  );

  @override
  void setErrorMessage(String message) {
    final _$actionInfo = _$_SuccessStoreActionController.startAction(
      name: '_SuccessStore.setErrorMessage',
    );
    try {
      return super.setErrorMessage(message);
    } finally {
      _$_SuccessStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void reset(String value) {
    final _$actionInfo = _$_SuccessStoreActionController.startAction(
      name: '_SuccessStore.reset',
    );
    try {
      return super.reset(value);
    } finally {
      _$_SuccessStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  void dispose() {
    final _$actionInfo = _$_SuccessStoreActionController.startAction(
      name: '_SuccessStore.dispose',
    );
    try {
      return super.dispose();
    } finally {
      _$_SuccessStoreActionController.endAction(_$actionInfo);
    }
  }

  @override
  String toString() {
    return '''
successMessage: ${successMessage}
    ''';
  }
}
