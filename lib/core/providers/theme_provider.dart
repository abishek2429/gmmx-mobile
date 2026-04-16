import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Simple theme provider for managing dark/light mode
final themeProvider =
    StateProvider<bool>((ref) => true); // true = dark, false = light
