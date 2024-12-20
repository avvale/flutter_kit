import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/auth_mode.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/providers/network_provider.dart';
import 'package:flutter_kit/src/utils/consts.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/toast.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'auth_provider.g.dart';

const _initialState = FkAuthState();

@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  @override
  FkAuthState build() => _initialState;

  /// Comprueba si existe una sesión guardada. Si la hay, la carga en el estado
  /// de la aplicación y lo inicializa. Si no la hay, solo lo inicializa.
  Future<void> initialize({
    required FkAuthMode authMode,
  }) async {
    if (state.isInitialized) {
      return;
    }

    try {
      final secureStorage = await SharedPreferences.getInstance();
      final accessToken = secureStorage.getString(accessTokenKey);
      final refreshToken = secureStorage.getString(refreshTokenKey);

      if (accessToken != null && refreshToken != null) {
        state = state.copyWith(
          isInitialized: true,
          authMode: authMode,
          accessToken: accessToken,
          refreshToken: refreshToken,
        );
      } else {
        state = state.copyWith(isInitialized: true, authMode: authMode);
      }
    } catch (e) {
      if (e is PlatformException && e.code == 'BadPaddingException') {
        (await SharedPreferences.getInstance()).clear();
      }
    }
  }

  Future<void> _setCredentials({
    required String accessToken,
    required String refreshToken,
    bool remember = true,
  }) async {
    if (remember) {
      try {
        final secureStorage = await SharedPreferences.getInstance();
        await secureStorage.setString(accessTokenKey, accessToken);
        await secureStorage.setString(refreshTokenKey, refreshToken);
      } catch (e) {
        Debugger.log('Error saving credentials', e);
      }
    }

    state = state.copyWith(
      accessToken: accessToken,
      refreshToken: refreshToken,
    );
  }

  void changeAuthMode(FkAuthMode authMode) {
    state = state.copyWith(authMode: authMode);
  }

  /// Inicia sesión con las credenciales introducidas. Si se ha iniciado sesión
  /// correctamente, guarda los tokens en el almacenamiento seguro y los carga
  /// en el estado de la aplicación.
  Future<bool> login<T>({
    required T endpoint,
    bool useRefreshToken = false,
    FkAuthMode? authMode,
    String user = '',
    String pass = '',
    bool remember = true,
  }) async {
    EasyLoading.show();

    final Map<String, dynamic> params = {};

    if (useRefreshToken) {
      params['payload'] = {
        'grantType': 'REFRESH_TOKEN',
        'refreshToken': state.refreshToken,
      };
    } else if (authMode != null) {
      switch (authMode) {
        case FkManualAuthMode():
          params['payload'] = {
            'grantType': 'PASSWORD',
            'username': user,
            'password': pass,
          };
          break;
        case FkAutoAuthMode():
          params['payload'] = {
            'grantType': 'CLIENT_CREDENTIALS',
            'username': authMode.user,
            'clientSecret': authMode.pass,
          };
      }
    }

    try {
      final res = await ref.read(networkProvider.notifier).mutate(
            endpoint: endpoint,
            useBasicAuth: true,
            params: params,
          );

      if (res.exception != null) {
        for (var err in res.exception!.graphqlErrors) {
          Debugger.log('Login error (try)', err);
        }

        if (useRefreshToken) return false;

        Toast.show(
          'Las credenciales introducidas no son correctas',
          mode: ToastMode.error,
        );
      } else {
        Map<String, dynamic>? oAuthData = res.data?['oAuthCreateCredentials'];

        if (oAuthData != null) {
          Debugger.log('Login OAuth data', oAuthData);

          _setCredentials(
            accessToken: oAuthData['accessToken'],
            refreshToken: oAuthData['refreshToken'],
            remember: remember,
          );

          return true;
        } else {
          Debugger.log('Login OAuth data is null', res);

          Toast.show(
            'Ha habido un error desconocido',
            mode: ToastMode.error,
          );
        }
      }

      return false;
    } catch (e) {
      Debugger.log('Login error (catch)', e);

      logout();

      rethrow;
    } finally {
      EasyLoading.dismiss();
    }
  }

  /// Simula un login para depuración.
  Future<bool> debugLogin<T>({
    String accessToken = 'accessToken',
    String refreshToken = 'refreshToken',
    bool remember = true,
    Duration delay = const Duration(seconds: 1),
  }) async {
    EasyLoading.show();

    await Future.delayed(delay);

    _setCredentials(
      accessToken: accessToken,
      refreshToken: refreshToken,
      remember: remember,
    );

    EasyLoading.dismiss();

    return true;
  }

  /// Cierra la sesión actual y borra los tokens del almacenamiento seguro.
  Future<void> logout() async {
    Debugger.log('Logout');

    try {
      final secureStorage = await SharedPreferences.getInstance();
      await secureStorage.remove(accessTokenKey);
      await secureStorage.remove(refreshTokenKey);
    } catch (e) {
      Debugger.log('Error deleting credentials', e);
    }

    state = state.copyWith(accessToken: '', refreshToken: '');
  }
}
