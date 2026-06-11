import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fresh_news_mobile/core/constants/world.dart';
import 'package:fresh_news_mobile/shared/infrastructure/subscriber_repository.dart';
import 'package:fresh_news_mobile/features/archive/application/archive_providers.dart';
import 'package:fresh_news_mobile/shared/domain/subscriber.entity.dart';

enum SubscribeStatus { idle, loading, success, error }

class SubscribeState {
  final SubscribeStatus status;
  final String? errorMessage;
  final List<World> selectedWorlds;
  final List<String> selectedCategories;

  const SubscribeState({
    this.status = SubscribeStatus.idle,
    this.errorMessage,
    this.selectedWorlds = const [],
    this.selectedCategories = const [],
  });

  bool get isLoading => status == SubscribeStatus.loading;
  bool get isSuccess => status == SubscribeStatus.success;

  SubscribeState copyWith({
    SubscribeStatus? status,
    String? errorMessage,
    List<World>? selectedWorlds,
    List<String>? selectedCategories,
  }) {
    return SubscribeState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      selectedWorlds: selectedWorlds ?? this.selectedWorlds,
      selectedCategories: selectedCategories ?? this.selectedCategories,
    );
  }
}

class SubscribeController extends StateNotifier<SubscribeState> {
  final SubscriberRepository _repository;
  final Ref _ref;

  SubscribeController(this._repository, this._ref) : super(const SubscribeState());

  void toggleCategory(String category) {
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  void setActiveWorld(World world) {
    if (!state.selectedWorlds.contains(world)) {
      state = state.copyWith(selectedWorlds: [...state.selectedWorlds, world]);
    }
  }

  Future<bool> subscribe({required String email, required World world}) async {
    state = state.copyWith(status: SubscribeStatus.loading, errorMessage: null);

    try {
      final worlds = state.selectedWorlds.isEmpty ? [world] : state.selectedWorlds;
      final Subscriber subscriber;

      final existing = await _repository.getByEmail(email.trim());
      if (existing != null) {
        await _repository.updatePreferences(existing.id, worlds: worlds, active: true);
        subscriber = existing.copyWith(worlds: worlds, active: true);
      } else {
        subscriber = await _repository.create(email: email.trim(), worlds: worlds);
      }

      await _ref.read(subscriberIdProvider.notifier).setSubscriberId(subscriber.id);

      state = state.copyWith(status: SubscribeStatus.success);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: SubscribeStatus.error,
        errorMessage: 'Erro ao realizar inscrição. Tente novamente.',
      );
      return false;
    }
  }

  void reset() {
    state = const SubscribeState();
  }
}

final subscribeControllerProvider =
    StateNotifierProvider.autoDispose<SubscribeController, SubscribeState>((ref) {
  final repository = ref.read(subscriberRepositoryProvider);
  return SubscribeController(repository, ref);
});
