import 'package:mobx/mobx.dart';
import '../error/error_store.dart';
import '../../data/repository.dart';

part 'navigation_store.g.dart';

class NavigationStore = _NavigationStore with _$NavigationStore;

abstract class _NavigationStore with Store {
  // repository instance
  late final Repository _repository;

  // store for handling errors
  final ErrorStore errorStore = ErrorStore();

  // constructor:---------------------------------------------------------------
  _NavigationStore(Repository repository) : _repository = repository {
    /// TODO: set isLogin code.
  }

  // store variables:-----------------------------------------------------------
  @observable
  String? _screenName;

  @computed
  String? get screenName => _screenName;

  // actions:-------------------------------------------------------------------
  @action
  Future saveNavigationRes({String? screenName}) async {
    _repository.saveScreenNavigation(screenName ?? '');
  }

  @action
  Future getScreenNavigationText() async {
    _screenName = _repository.getScreenNavigation;
  }
}
