import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fresh_news_mobile/core/network/dio_client.dart';
import 'package:fresh_news_mobile/features/auth/domain/auth_state.dart';
import 'package:fresh_news_mobile/features/world_selector/application/world_controller.dart';
import 'package:fresh_news_mobile/core/constants/app_constants.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final SharedPreferences _prefs;
  final Dio _dio;

  AuthNotifier(this._prefs, this._dio) : super(const AuthState()) {
    _loadSession();
  }

  static const _sessionKey = 'admin_session';
  static const _sessionExpiryKey = 'admin_session_expiry';

  void _loadSession() {
    final session = _prefs.getBool(_sessionKey) ?? false;
    final expiryStr = _prefs.getString(_sessionExpiryKey);

    if (session && expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isBefore(expiry)) {
        state = const AuthState(status: AuthStatus.authenticated);
        return;
      }
    }

    _prefs.remove(_sessionKey);
    _prefs.remove(_sessionExpiryKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  Future<bool> sendMagicLink(String email) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email.trim(),
        emailRedirectTo: 'freshnews://login-callback',
      );
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erro ao enviar link de login: $e',
      );
      return false;
    }
  }

  Future<bool> login(String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);

    try {
      // Pequeno delay para simular validação e manter o loading de UX
      await Future.delayed(const Duration(milliseconds: 500));

      if (password == AppConstants.adminPassword) {
        final expiry = DateTime.now().add(const Duration(days: 7));
        await _prefs.setBool(_sessionKey, true);
        await _prefs.setString(_sessionExpiryKey, expiry.toIso8601String());

        state = const AuthState(status: AuthStatus.authenticated);
        return true;
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          errorMessage: 'Senha incorreta',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Erro ao processar autenticação.',
      );
      return false;
    }
  }

  Future<void> logout() async {
    await _prefs.remove(_sessionKey);
    await _prefs.remove(_sessionExpiryKey);
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final dio = ref.watch(dioClientProvider);
  return AuthNotifier(prefs, dio);
});
