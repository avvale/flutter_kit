abstract class FkAuthMode {
  final String grantType;

  const FkAuthMode({required this.grantType});
}

class FkDisabledAuthMode extends FkAuthMode {
  const FkDisabledAuthMode() : super(grantType: '');
}

class FkAutoAuthMode extends FkAuthMode {
  final String user;
  final String pass;

  const FkAutoAuthMode({
    required this.user,
    required this.pass,
  }) : super(grantType: 'CLIENT_CREDENTIALS');
}

class FkManualAuthMode extends FkAuthMode {
  const FkManualAuthMode() : super(grantType: 'PASSWORD');
}
