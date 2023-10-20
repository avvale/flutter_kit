import 'package:flutter_kit/models/auth_mode/auth_mode.dart';

class DisabledAuthMode extends AuthMode {
  const DisabledAuthMode() : super(grantType: '');
}
