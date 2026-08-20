/// Centralised app configuration.
abstract final class AppConfig {
  AppConfig._();

  static const metadataPageSize = 20;

  static const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  static String get supabaseUrl =>
      _requireBuildValue('SUPABASE_URL', _supabaseUrl);

  static String get supabaseAnonKey =>
      _requireBuildValue('SUPABASE_ANON_KEY', _supabaseAnonKey);

  static const String cdnBaseUrl = String.fromEnvironment('CDN_BASE_URL');

  static const String cdnPresignUrl = String.fromEnvironment('CDN_PRESIGN_URL');

  static String _requireBuildValue(String key, String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      throw StateError('Missing required --dart-define: $key');
    }
    return trimmed;
  }
}
