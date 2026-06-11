class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://vgsjpuxymtkkiaissrky.supabase.co';
  static const String supabaseAnonKey = 'sb_publishable_6D8ptLACddu7D5r2SN0LTQ_RQMtS15q';
  static const String baseApiUrl = 'http://localhost:3000';

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;

  static const String prefsActiveWorldKey = 'active_world';
  static const String prefsThemeModeKey = 'theme_mode';
  static const String prefsAdminSessionKey = 'admin_session';
}
