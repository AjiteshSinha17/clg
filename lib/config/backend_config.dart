class BackendConfig {
  /// Set this at build time, for example:
  /// `--dart-define=CLGJONE_SERVER_URL=https://<your-render-service>.onrender.com`
  static const String baseUrl =
      String.fromEnvironment('CLGJONE_SERVER_URL', defaultValue: '');
}

