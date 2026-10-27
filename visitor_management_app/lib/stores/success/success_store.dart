import 'package:mobx/mobx.dart';

part 'success_store.g.dart';

class SuccessStore = _SuccessStore with _$SuccessStore;

abstract class _SuccessStore with Store {
  // disposers
  late List<ReactionDisposer> _disposers;

  // constructor:---------------------------------------------------------------
  _SuccessStore() {
    _disposers = [reaction((_) => successMessage, reset, delay: 200)];
  }

  // store variables:-----------------------------------------------------------
  @observable
  String successMessage = '';

  // actions:-------------------------------------------------------------------
  @action
  void setErrorMessage(String message) {
    successMessage = message;
  }

  @action
  void reset(String value) {
    successMessage = '';
  }

  // dispose:-------------------------------------------------------------------
  @action
  void dispose() {
    for (final d in _disposers) {
      d();
    }
  }
}
