import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_kit/models/state/l10n_state.dart';
import 'package:flutter_kit/providers/auth_provider.dart';
import 'package:flutter_kit/providers/network_provider.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/helpers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'l10n_provider.g.dart';

const _initialState = FkL10nState();

@riverpod
class L10n extends _$L10n {
  @override
  FkL10nState build() {
    return _initialState;
  }

  Future<void> initialize({String? defaultLang}) async {
    state = state.copyWith(
      isInitialized: true,
      currentLocale: existsNotEmpty(defaultLang) ? Locale(defaultLang!) : null,
    );
  }

  Future<void> changeLang(String? lang, BuildContext context) async {
    Debugger.log('Change app language', {
      'New lang': lang,
      'Current lang': state.currentLocale?.languageCode,
    });

    // Si el idioma es el mismo que el actual, no se hacen cambios
    if (lang == state.currentLocale?.languageCode) {
      return;
    }

    // Si el idioma no existe, se usa el idioma por defecto si se ha definido;
    // si no se ha definido, se usa el idioma del dispositivo
    final locale = existsNotEmpty(lang)
        ? Locale(lang!)
        : (context.fallbackLocale ?? context.deviceLocale);

    // Se actualiza el idioma
    await context.setLocale(locale);
    state = state.copyWith(currentLocale: locale);

    // Se recarga el token de autenticación para que se actualice el idioma
    final String accessToken = ref.read(authProvider).accessToken;
    await ref.read(networkProvider.notifier).setToken(accessToken);
  }
}