import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/models/auth_mode/auth_mode.dart';
import 'package:flutter_kit/models/auth_mode/auto_auth_mode.dart';
import 'package:flutter_kit/models/auth_mode/manual_auth_mode.dart';
import 'package:flutter_kit/models/state/auth_state.dart';
import 'package:flutter_kit/services/network_service.dart';
import 'package:flutter_kit/utils/debugger.dart';
import 'package:flutter_kit/utils/toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

const initialState = AuthState();

/// Servicio de autenticación
class AuthService {
  static final AuthService _instance = AuthService._internal();

  final _dataFetcher = BehaviorSubject<AuthState>()..startWith(initialState);

  AuthState get value =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<AuthState> get stream => _dataFetcher.stream;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Guarda los tokens en el almacenamiento seguro, los carga en el estado de
  /// la aplicación y establece el token de la API.
  Future<AuthState?> _setAuthCredentials(AuthState user) async {
    Debugger.log('Set auth credentials', user);

    await NetworkService().setToken(user.accessToken);

    _dataFetcher.sink.add(user);

    return user;
  }

  /// Comprueba si existe una sesión guardada. Si la hay, la carga en el estado
  /// de la aplicación y lo inicializa. Si no la hay, solo lo inicializa.
  Future<bool> initialize() async {
    final secureValues = await _secureStorage.readAll();

    if (secureValues['fk_accessToken'] != null &&
        secureValues['fk_refreshToken'] != null) {
      await _setAuthCredentials(
        value.copyWith(
          isInitialized: true,
          accessToken: secureValues['fk_accessToken'],
          refreshToken: secureValues['fk_refreshToken'],
        ),
      );

      return true;
    } else {
      await _setAuthCredentials(value.copyWith(isInitialized: true));

      return false;
    }
  }

  /// Inicia sesión con las credenciales introducidas. Si se ha iniciado sesión
  /// correctamente, guarda los tokens en el almacenamiento seguro y los carga
  /// en el estado de la aplicación.
  Future<bool> login<T>({
    required T endpoint,
    bool useRefreshToken = false,
    AuthMode? authMode,
    user = '',
    pass = '',
  }) async {
    EasyLoading.show();

    final Map<String, dynamic> params = {};

    if (useRefreshToken) {
      params['payload'] = {
        'grantType': 'REFRESH_TOKEN',
        'refreshToken': value.refreshToken,
      };
    } else if (authMode != null) {
      switch (authMode) {
        case ManualAuthMode():
          params['payload'] = {
            'grantType': 'PASSWORD',
            'username': user,
            'password': pass,
          };
          break;
        case AutoAuthMode():
          params['payload'] = {
            'grantType': 'CLIENT_CREDENTIALS',
            'email': authMode.user,
            'clientSecret': authMode.pass,
          };
      }
    }

    try {
      final res = await NetworkService().mutate(
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

          await _secureStorage.write(
            key: 'fk_accessToken',
            value: oAuthData['accessToken'],
          );
          await _secureStorage.write(
            key: 'fk_refreshToken',
            value: oAuthData['refreshToken'],
          );

          await _setAuthCredentials(
            value.copyWith(
              accessToken: oAuthData['accessToken'],
              refreshToken: oAuthData['refreshToken'],
            ),
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

  /// Cierra la sesión actual y borra los tokens del almacenamiento seguro.
  Future<void> logout() async {
    Debugger.log('Logout');

    await _secureStorage.delete(key: 'fk_accessToken');
    await _secureStorage.delete(key: 'fk_refreshToken');

    await _setAuthCredentials(
      value.copyWith(accessToken: '', refreshToken: ''),
    );
  }

  void dispose() {
    _dataFetcher.close();
  }
}
