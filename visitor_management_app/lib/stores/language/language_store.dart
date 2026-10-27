import 'package:mobx/mobx.dart';
import '../error/error_store.dart';
import '../../data/repository.dart';
import '../../models/language/language_file.dart';

part 'language_store.g.dart';

class LanguageStore = _LanguageStore with _$LanguageStore;

abstract class _LanguageStore with Store {
  // static const String TAG = "LanguageStore";

  // repository instance
  final Repository _repository;

  // store for handling errors
  final ErrorStore errorStore = ErrorStore();

  // supported languages
  List<Language> supportedLanguages = [
    Language(code: 'US', locale: 'en', language: 'English'),
    Language(code: 'IN', locale: 'hi', language: 'हिन्दी'),
    Language(code: 'IN', locale: 'gu', language: 'ગુજરાતી'),
  ];

  // constructor:---------------------------------------------------------------
  _LanguageStore(Repository repository) : _repository = repository {
    init();
  }

  // store variables:-----------------------------------------------------------
  @observable
  String _locale = "en";

  @computed
  String get locale => _locale;

  // actions:-------------------------------------------------------------------
  @action
  void changeLanguage(String value) {
    _locale = value;
    _repository.changeLanguage(value).then((_) {
      // write additional logic here
    });
  }

  @action
  String getCode() {
    String code = "US";

    if (_locale == 'en') {
      code = "US";
    } else if (_locale == 'hi' || _locale == 'gu') {
      code = "IN";
    }

    return code;
  }

  @action
  String? getLanguage() {
    return supportedLanguages[supportedLanguages.indexWhere(
          (language) => language.locale == _locale,
        )]
        .language;
  }

  // general:-------------------------------------------------------------------
  void init() async {
    // getting current language from shared preference
    if (_repository.currentLanguage != null) {
      _locale = _repository.currentLanguage!;
    }
  }

  // dispose:-------------------------------------------------------------------
  // @override
  // dispose() {}
}
