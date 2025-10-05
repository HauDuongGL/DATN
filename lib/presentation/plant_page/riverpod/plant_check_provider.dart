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
