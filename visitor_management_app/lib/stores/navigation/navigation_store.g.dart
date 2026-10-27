// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'navigation_store.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$NavigationStore on _NavigationStore, Store {
  Computed<String?>? _$screenNameComputed;

  @override
  String? get screenName => (_$screenNameComputed ??= Computed<String?>(
    () => super.screenName,
    name: '_NavigationStore.screenName',
  )).value;

  late final _$_screenNameAtom = Atom(
    name: '_NavigationStore._screenName',
    context: context,
  );

  @override
  String? get _screenName {
    _$_screenNameAtom.reportRead();
    return super._screenName;
  }

  @override
  set _screenName(String? value) {
    _$_screenNameAtom.reportWrite(value, super._screenName, () {
      super._screenName = value;
    });
  }

  late final _$saveNavigationResAsyncAction = AsyncAction(
    '_NavigationStore.saveNavigationRes',
    context: context,
  );

  @override
  Future<dynamic> saveNavigationRes({String? screenName}) {
    return _$saveNavigationResAsyncAction.run(
      () => super.saveNavigationRes(screenName: screenName),
    );
  }

  late final _$getScreenNavigationTextAsyncAction = AsyncAction(
    '_NavigationStore.getScreenNavigationText',
    context: context,
  );

  @override
  Future<dynamic> getScreenNavigationText() {
    return _$getScreenNavigationTextAsyncAction.run(
      () => super.getScreenNavigationText(),
    );
  }

  @override
  String toString() {
    return '''
screenName: ${screenName}
    ''';
  }
}
