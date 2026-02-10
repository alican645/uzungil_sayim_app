enum Environment { dev, staging, prod }

class AppConfig {
  static late Environment _environment;

  static void init(Environment env) {
    _environment = env;
  }

  static String get baseUrl {
    switch (_environment) {
      case Environment.dev:
        // Use localhost for iOS simulator, 10.0.2.2 for Android emulator
        // Adjust port if needed
        // return 'http://192.168.10.2:82';
        return 'http://localhost:5149';
      case Environment.staging:
        return 'https://staging-api.example.com';
      case Environment.prod:
        return 'https://api.example.com';
    }
  }

  static bool get isDev => _environment == Environment.dev;
}
