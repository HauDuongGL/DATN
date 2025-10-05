import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlantCheckNotifier extends StateNotifier<bool> {
  PlantCheckNotifier() : super(false);

  void setCheck(bool? value) {
    state = value ?? false;
  }
}

final plantCheckProvider = StateNotifierProvider<PlantCheckNotifier, bool>(
  (ref) => PlantCheckNotifier(),
);

final hashChangeProvider = StateProvider<bool>((ref) => false);
final permissionCheckProvider = StateProvider<bool>((ref) => false);
final isValidationTriggeredProvider = StateProvider<bool>((ref) => false);
final submitAttemptedProvider = StateProvider<bool>((_) => false);
final submitSuccessProvider = StateProvider<bool>((_) => false);

class LoadingMap extends StateNotifier<Map<Object, bool>> {
  LoadingMap() : super(const {});

  bool isBusy(Object key) => state[key] == true;

  Future<T> run<T>(Object key, Future<T> Function() task) async {
    state = {...state, key: true};
    try {
      return await task();
    } finally {
      state = {...state, key: false};
    }
  }
}

final loadingMapProvider =
    StateNotifierProvider<LoadingMap, Map<Object, bool>>((ref) => LoadingMap());
