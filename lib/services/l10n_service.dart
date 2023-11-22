import 'package:flutter/widgets.dart';
import 'package:flutter_kit/models/state/l10n_state.dart';
import 'package:flutter_kit/services/auth_service.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';

final initialState = L10nState(
  isInitialized: false,
);

/// Servicio de idioma
class L10nService {
  static final L10nService _instance = L10nService._internal();

  final _dataFetcher = BehaviorSubject<L10nState>()..startWith(initialState);

  L10nState get value =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<L10nState> get stream => _dataFetcher.stream;

  factory L10nService() {
    return _instance;
  }

  L10nService._internal();

  Future<void> initialize({
    required String defaultLang,
    Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates,
    Iterable<Locale>? supportedLocales,
    String? forceLang,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final String lang = forceLang ?? prefs.getString('fk_lang') ?? defaultLang;

    _dataFetcher.add(
      value.copyWith(
        isInitialized: true,
        currentLocale: Locale(lang),
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
      ),
    );

    prefs.setString('fk_lang', lang);
  }

  Future<void> updateLang(String? lang) async {
    Debugger.log('Update language', lang);

    if (!existsNotEmpty(lang) || lang == value.currentLocale?.languageCode) {
      return;
    }

    _dataFetcher.sink.add(value.copyWith(currentLocale: Locale(lang!)));

    final prefs = await SharedPreferences.getInstance();

    prefs.setString('fk_lang', lang);

    final String accessToken = AuthService().value.accessToken;

    await NetworkService().setToken(accessToken);
  }
}
