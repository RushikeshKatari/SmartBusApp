/// Application-wide environment configuration.
/// 
/// Values can be injected at build time using Flutter's `--dart-define` flag:
/// ```bash
/// flutter build web --release \
///   --dart-define=API_BASE_URL=https://smartbus-backend.onrender.com \
///   --dart-define=SUPABASE_URL=https://your-project.supabase.co \
///   --dart-define=SUPABASE_ANON_KEY=your-anon-key
/// ```
class AppConfig {
  /// Base URL for the SmartBus backend API.
  /// In development, defaults to 'http://localhost:8080'.
  /// In production, inject via `--dart-define=API_BASE_URL=https://your-render-app.onrender.com`.
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );

  /// Supabase project URL (optional client-side direct access if configured)
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: '',
  );

  /// Supabase public anonymous key (safe to include in web client)
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: '',
  );

  /// Helper to build full backend endpoints safely without trailing slash issues.
  static String endpoint(String path) {
    final cleanBase = apiBaseUrl.endsWith('/')
        ? apiBaseUrl.substring(0, apiBaseUrl.length - 1)
        : apiBaseUrl;
    final cleanPath = path.startsWith('/') ? path : '/$path';
    return '$cleanBase$cleanPath';
  }

  /// Whether running against a real production backend URL (https)
  static bool get isProduction => apiBaseUrl.startsWith('https://');
}
