import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/features/auth/application/auth_notifier.dart';

final telemetryRepositoryProvider = Provider<TelemetryRepository>((ref) {
  final subscriberId = ref.watch(subscriberIdProvider);
  return TelemetryRepository(
    supabase: Supabase.instance.client,
    subscriberId: subscriberId,
  );
});

class TelemetryRepository {
  final SupabaseClient supabase;
  final String? subscriberId;

  TelemetryRepository({
    required this.supabase,
    required this.subscriberId,
  });

  /// Envia um sinal de leitura para o banco de dados.
  /// Se o usuário não estiver logado, o sinal é descartado silenciosamente.
  Future<void> sendSignal({
    required String category,
    required String signalType,
    required double weight,
  }) async {
    if (subscriberId == null) return;

    try {
      await supabase.from('user_reading_signals').insert({
        'user_id': subscriberId,
        'category': category.toUpperCase(),
        'signal_type': signalType,
        'weight': weight,
      });
      // O banco recalculará o affinity_vector via trigger
    } catch (e) {
      // Falhas em telemetria não devem quebrar o aplicativo
      // Em produção real usaríamos Sentry/Crashlytics aqui
      print('Falha ao enviar telemetria: $e');
    }
  }

  /// Calcula e envia o dwell time baseado no tempo de visibilidade.
  Future<void> recordDwellTime({
    required String category,
    required Duration visibleDuration,
  }) async {
    final seconds = visibleDuration.inSeconds;

    // Menos de 5 segundos é só scroll rápido, ignora
    if (seconds < 5) return;

    double weight = 0.5; // leitura superficial (5s a 15s)
    if (seconds >= 40) {
      weight = 1.5; // interesse alto (mais de 40s)
    } else if (seconds >= 15) {
      weight = 1.0; // leitura normal (15s a 40s)
    }

    await sendSignal(
      category: category,
      signalType: 'dwell_time',
      weight: weight,
    );
  }

  /// Registra quando o usuário clica num artigo para ler mais.
  Future<void> recordLinkClick({required String category}) async {
    await sendSignal(
      category: category,
      signalType: 'link_click',
      weight: 3.0, // cliques são sinais explícitos muito fortes
    );
  }
}
