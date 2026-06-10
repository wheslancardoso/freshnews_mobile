import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/world.dart';

const _kActiveWorldKey = 'active_world';

class WorldState {
  final World activeWorld;
  final bool isLoading;

  const WorldState({
    this.activeWorld = World.tech,
    this.isLoading = true,
  });

  WorldState copyWith({World? activeWorld, bool? isLoading}) {
    return WorldState(
      activeWorld: activeWorld ?? this.activeWorld,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class WorldController extends StateNotifier<WorldState> {
  final SharedPreferences _prefs;

  WorldController(this._prefs) : super(const WorldState()) {
    _loadPersistedWorld();
  }

  void _loadPersistedWorld() {
    final saved = _prefs.getString(_kActiveWorldKey);
    final world = saved != null ? WorldRegistry.fromString(saved) : World.tech;
    state = WorldState(activeWorld: world, isLoading: false);
  }

  Future<void> setWorld(World world) async {
    await _prefs.setString(_kActiveWorldKey, world.name);
    state = state.copyWith(activeWorld: world);
  }

  WorldMeta get activeMeta => WorldRegistry.get(state.activeWorld);
}

// Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final worldControllerProvider =
    StateNotifierProvider<WorldController, WorldState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WorldController(prefs);
});

final activeWorldProvider = Provider<World>((ref) {
  return ref.watch(worldControllerProvider).activeWorld;
});

final activeWorldMetaProvider = Provider<WorldMeta>((ref) {
  final world = ref.watch(activeWorldProvider);
  return WorldRegistry.get(world);
});
