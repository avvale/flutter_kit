import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_kit/models/state/l10n_state.dart';
import 'package:flutter_kit/services/auth_service.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:rxdart/rxdart.dart';

const initialState = FkL10nState();

/// Servicio de idioma
class FkL10nService {
  static final FkL10nService _instance = FkL10nService._internal();

  final _dataFetcher = BehaviorSubject<FkL10nState>()..startWith(initialState);

  FkL10nState get value =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<FkL10nState> get stream => _dataFetcher.stream;

  factory FkL10nService() {
    return _instance;
  }

  FkL10nService._internal();

  Future<void> initialize({String? defaultLang}) async {
    _dataFetcher.add(
      value.copyWith(
        isInitialized: true,
        currentLocale:
            existsNotEmpty(defaultLang) ? Locale(defaultLang!) : null,
      ),
    );
  }

  Future<void> changeLang(String? lang, BuildContext context) async {
    Debugger.log('Change language', lang);

    // Si el idioma es el mismo que el actual, no se hacen cambios
    if (lang == value.currentLocale?.languageCode) {
      return;
    }

    // Si el idioma no existe, se usa el idioma por defecto si se ha definido;
    // si no se ha definido, se usa el idioma del dispositivo
    final locale = existsNotEmpty(lang)
        ? Locale(lang!)
        : (context.fallbackLocale ?? context.deviceLocale);

    // Se actualiza el idioma
    await context.setLocale(locale);
    _dataFetcher.sink.add(value.copyWith(currentLocale: locale));

    // Se recarga el token de autenticación para que se actualice el idioma
    final String accessToken = FkAuthService().value.accessToken;
    await FkNetworkService().setToken(accessToken);
  }
}
