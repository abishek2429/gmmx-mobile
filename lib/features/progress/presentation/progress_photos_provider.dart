import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';

final progressPhotosProvider = StateNotifierProvider<ProgressPhotosNotifier, List<File>>((ref) {
  return ProgressPhotosNotifier();
});

class ProgressPhotosNotifier extends StateNotifier<List<File>> {
  ProgressPhotosNotifier() : super([]);

  void addPhoto(File file) {
    state = [...state, file];
  }

  void removePhoto(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i],
    ];
  }
}
