import 'package:flutter_kit/models/auth_mode/auth_mode.dart';

class AutoAuthMode extends AuthMode {
  final String user;
  final String pass;

  const AutoAuthMode({
    required this.user,
    required this.pass,
  }) : super(grantType: 'CLIENT_CREDENTIALS');
}
