import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';

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

  /// Remove emojis e espaços extras para normalizar a categoria.
  /// Ex: "🤖 IA" → "IA", "🛡️ SEGURANÇA" → "SEGURANÇA"
  String _normalizeCategory(String raw) {
    // Remove tudo que não é letra, número ou espaço ASCII
    final cleaned = raw.replaceAll(RegExp(r'[^\w\sÀ-ÿ]', unicode: true), '').trim();
    return cleaned.toUpperCase();
  }

  /// Envia um sinal de leitura para o banco de dados.
  /// Se o usuário não estiver logado, o sinal é descartado silenciosamente.
  Future<void> sendSignal({
    required String category,
    required String signalType,
    required double weight,
  }) async {
    final normalizedCategory = _normalizeCategory(category);
    
    if (subscriberId == null) {
      print('[TELEMETRY] ⚠️ subscriberId é null — sinal descartado (cat: $normalizedCategory)');
      return;
    }

    if (normalizedCategory.isEmpty) {
      print('[TELEMETRY] ⚠️ categoria vazia após normalização — sinal descartado');
      return;
    }

    try {
      print('[TELEMETRY] 📡 Enviando: user=$subscriberId, cat=$normalizedCategory, tipo=$signalType, peso=$weight');
      await supabase.from('user_reading_signals').insert({
        'user_id': subscriberId,
        'category': normalizedCategory,
        'signal_type': signalType,
        'weight': weight,
      });
      print('[TELEMETRY] ✅ Sinal enviado com sucesso!');
    } catch (e) {
      print('[TELEMETRY] ❌ Falha ao enviar: $e');
    }
  }

  /// Calcula e envia o dwell time baseado no tempo de visibilidade.
  Future<void> recordDwellTime({
    required String category,
    required Duration visibleDuration,
  }) async {
    final seconds = visibleDuration.inSeconds;
    print('[TELEMETRY] ⏱️ Dwell time para "$category": ${seconds}s');

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
      weight: 3.0,
    );
  }
}
