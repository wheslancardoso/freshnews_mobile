class AppConstants {
  AppConstants._();

  static const String supabaseUrl = 'https://wddebrieixjcxurtggmb.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndkZGVicmllaXhqY3h1cnRnZ21iIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjkzNjAzOTQsImV4cCI6MjA4NDkzNjM5NH0.Sd5kIKX0iZNaFNL2d6s2TMRQcxljw9s2V2KN-dcAykA';
  static const String baseApiUrl = 'http://localhost:3000';

  static const Duration defaultTimeout = Duration(seconds: 30);
  static const int defaultPageSize = 20;

  static const String prefsActiveWorldKey = 'active_world';
  static const String prefsThemeModeKey = 'theme_mode';
  static const String prefsAdminSessionKey = 'admin_session';
}
