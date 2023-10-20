import 'package:flutter_kit/models/auth_mode/auth_mode.dart';

class ManualAuthMode extends AuthMode {
  const ManualAuthMode() : super(grantType: 'PASSWORD');
}
