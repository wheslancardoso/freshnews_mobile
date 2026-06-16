import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';
import 'package:fresh_news_mobile/core/services/notification_service.dart';

class PreferencesState {
  final Subscriber? subscriber;
  final Set<String> selectedPreferences;
  final Set<World> selectedWorlds;
  final String phone;
  final bool notifyEmail;
  final bool notifyWhatsapp;
  final bool isLoading;
  final bool isSaving;
  final String? message;

  const PreferencesState({
    this.subscriber,
    this.selectedPreferences = const {},
    this.selectedWorlds = const {},
    this.phone = '',
    this.notifyEmail = true,
    this.notifyWhatsapp = false,
    this.isLoading = true,
    this.isSaving = false,
    this.message,
  });

  PreferencesState copyWith({
    Subscriber? subscriber,
    Set<String>? selectedPreferences,
    Set<World>? selectedWorlds,
    String? phone,
    bool? notifyEmail,
    bool? notifyWhatsapp,
    bool? isLoading,
    bool? isSaving,
    String? message,
  }) {
    return PreferencesState(
      subscriber: subscriber ?? this.subscriber,
      selectedPreferences: selectedPreferences ?? this.selectedPreferences,
      selectedWorlds: selectedWorlds ?? this.selectedWorlds,
      phone: phone ?? this.phone,
      notifyEmail: notifyEmail ?? this.notifyEmail,
      notifyWhatsapp: notifyWhatsapp ?? this.notifyWhatsapp,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      message: message,
    );
  }
}

class PreferencesNotifier extends StateNotifier<PreferencesState> {
  final SubscriberRepository _repository;
  final String _subscriberId;
  final NotificationService _notificationService;

  PreferencesNotifier(this._repository, this._subscriberId, this._notificationService) : super(const PreferencesState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final subscriber = await _repository.getById(_subscriberId);
    if (subscriber != null) {
      state = PreferencesState(
        subscriber: subscriber,
        selectedPreferences: subscriber.preferences.toSet(),
        selectedWorlds: subscriber.worlds.toSet(),
        phone: subscriber.phone ?? '',
        notifyEmail: subscriber.notifyEmail,
        notifyWhatsapp: subscriber.notifyWhatsapp,
        isLoading: false,
      );
      await _notificationService.syncTopicSubscriptions(subscriber.worlds);
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void togglePreference(String category) {
    final current = Set<String>.from(state.selectedPreferences);
    Map<String, double> updatedAffinity = Map.from(state.subscriber?.affinityVector ?? {});
    final isAiSuggested = !current.contains(category) && (updatedAffinity[category.toUpperCase()] ?? 0.0) >= 0.3;

    if (current.contains(category)) {
      // Já estava explicitamente selecionado. O usuário desmarcou.
      current.remove(category);
      updatedAffinity[category.toUpperCase()] = 0.0;
    } else if (isAiSuggested) {
      // Estava selecionado apenas pela IA (tinha cor de fundo mas com estrelinha).
      // Se o usuário clicou, é porque ele quer DESMARCAR essa sugestão.
      updatedAffinity[category.toUpperCase()] = 0.0;
    } else {
      // Estava totalmente desmarcado. O usuário quer marcar explicitamente.
      current.add(category);
    }

    final updatedSubscriber = state.subscriber?.copyWith(affinityVector: updatedAffinity);

    state = state.copyWith(
      selectedPreferences: current,
      subscriber: updatedSubscriber,
    );
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void toggleNotifyEmail() {
    state = state.copyWith(notifyEmail: !state.notifyEmail);
  }

  void toggleNotifyWhatsapp() {
    state = state.copyWith(notifyWhatsapp: !state.notifyWhatsapp);
  }

  void toggleWorld(World world) {
    final current = Set<World>.from(state.selectedWorlds);
    if (current.contains(world)) {
      // Pelo menos 1 mundo deve estar ativo
      if (current.length > 1) {
        current.remove(world);
      }
    } else {
      current.add(world);
    }
    state = state.copyWith(selectedWorlds: current);
  }

  Future<void> save() async {
    state = state.copyWith(isSaving: true, message: null);

    try {
      await _repository.updatePreferences(
        _subscriberId,
        worlds: state.selectedWorlds.toList(),
        preferences: state.selectedPreferences.toList(),
        phone: state.phone.isEmpty ? null : state.phone,
        notifyEmail: state.notifyEmail,
        notifyWhatsapp: state.notifyWhatsapp,
        affinityVector: state.subscriber?.affinityVector,
      );

      await _notificationService.syncTopicSubscriptions(state.selectedWorlds.toList());

      final updatedSubscriber = state.subscriber?.copyWith(
        worlds: state.selectedWorlds.toList(),
        preferences: state.selectedPreferences.toList(),
        phone: state.phone.isEmpty ? null : state.phone,
        notifyEmail: state.notifyEmail,
        notifyWhatsapp: state.notifyWhatsapp,
      );

      state = state.copyWith(
        subscriber: updatedSubscriber,
        isSaving: false,
        message: 'Preferências salvas com sucesso! 🎯',
      );
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        message: 'Erro ao salvar preferências: $e',
      );
    }
  }

  Future<bool> unsubscribe() async {
    state = state.copyWith(isSaving: true, message: null);
    try {
      if (state.subscriber != null) {
        // Encontra o unsubscribe token ou usa id para desinscrever.
        // Como o unsubscribe_token é uuid na tabela e não exposto diretamente,
        // no mobile o cancelamento também pode ser feito alterando o status
        // e active no subscribers diretamente.
        await _repository.updatePreferences(
          _subscriberId,
          active: false,
        );
        state = state.copyWith(
          subscriber: state.subscriber?.copyWith(active: false),
          isSaving: false,
          message: 'Inscrição cancelada com sucesso.',
        );
        return true;
      }
      state = state.copyWith(isSaving: false);
      return false;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        message: 'Erro ao cancelar inscrição: $e',
      );
      return false;
    }
  }
}

final preferencesProvider = StateNotifierProvider.autoDispose
    .family<PreferencesNotifier, PreferencesState, String>((ref, subscriberId) {
  final repository = ref.read(subscriberRepositoryProvider);
  final notificationService = ref.read(notificationServiceProvider);
  return PreferencesNotifier(repository, subscriberId, notificationService);
});
