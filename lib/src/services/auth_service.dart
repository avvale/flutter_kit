import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_kit/src/models/state/auth_state.dart';
import 'package:flutter_kit/src/services/network_service.dart';
import 'package:flutter_kit/src/utils/debugger.dart';
import 'package:flutter_kit/src/utils/toast.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rxdart/rxdart.dart';

const initialState = AuthState(
  isInitialized: false,
  accessToken: '',
  refreshToken: '',
);

/// Servicio de autenticación
class AuthService {
  static final AuthService _instance = AuthService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _dataFetcher = BehaviorSubject<AuthState>()..startWith(initialState);

  AuthState get authStateSync =>
      _dataFetcher.hasValue ? _dataFetcher.value : initialState;
  Stream<AuthState> get authState => _dataFetcher.stream;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Guarda los tokens en el almacenamiento seguro, los carga en el estado de
  /// la aplicación y establece el token de la API.
  Future<AuthState?> _setUser(AuthState user) async {
    Debugger.log('setUser', user);

    await NetworkService().setToken(user.accessToken);
    _dataFetcher.sink.add(user);
    return user;
  }

  /// Comprueba si existe una sesión guardada. Si la hay, la carga en el estado
  /// de la aplicación y lo inicializa. Si no la hay, solo lo inicializa.
  Future<bool> checkSession() {
    return _secureStorage.readAll().then((values) async {
      if (values['accessToken'] != null && values['refreshToken'] != null) {
        await _setUser(
          authStateSync.copyWith(
            isInitialized: true,
            accessToken: values['accessToken'],
            refreshToken: values['refreshToken'],
          ),
        );

        return true;
      } else {
        await _setUser(authStateSync.copyWith(isInitialized: true));

        return false;
      }
    });
  }

  /// Inicia sesión con las credenciales introducidas. Si se ha iniciado sesión
  /// correctamente, guarda los tokens en el almacenamiento seguro y los carga
  /// en el estado de la aplicación.
  Future<bool> login<T>({
    required T endpoint,
    email = '',
    password = '',
    bool useRefreshToken = false,
  }) {
    EasyLoading.show();

    return NetworkService()
        .mutate(
      endpoint: endpoint,
      useBasicAuth: true,
      params: useRefreshToken
          ? {
              'payload': {
                'grantType': 'REFRESH_TOKEN',
                'refreshToken': authStateSync.refreshToken,
              },
            }
          : {
              'payload': {
                'grantType': 'PASSWORD',
                'username': email,
                'password': password,
              },
            },
    )
        .then((res) async {
      if (res.exception != null) {
        for (var err in res.exception!.graphqlErrors) {
          Debugger.log('Login error (then)', err);
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
            key: 'accessToken',
            value: oAuthData['accessToken'],
          );
          await _secureStorage.write(
            key: 'refreshToken',
            value: oAuthData['refreshToken'],
          );

          _setUser(
            authStateSync.copyWith(
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
    }).catchError((e) {
      Debugger.log('Login error (catch)', e);

      logout();

      return e;
    }).whenComplete(() => EasyLoading.dismiss());
  }

  /// Cierra la sesión actual y borra los tokens del almacenamiento seguro.
  void logout() {
    Debugger.log('Logout');

    _secureStorage.delete(key: 'accessToken');
    _secureStorage.delete(key: 'refreshToken');

    _setUser(authStateSync.copyWith(accessToken: '', refreshToken: ''));
  }

  void dispose() {
    _dataFetcher.close();
  }
}
