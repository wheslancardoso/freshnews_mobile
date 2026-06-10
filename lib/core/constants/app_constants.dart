class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'SUA_SUPABASE_URL';
  static const String supabaseAnonKey = 'SUA_ANON_KEY';

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;

  static const String prefsActiveWorldKey = 'active_world';
  static const String prefsThemeModeKey = 'theme_mode';
  static const String prefsAdminSessionKey = 'admin_session';
}
