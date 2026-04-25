import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/plan_model.dart';
import '../../services/session_service.dart';
import '../../features/auth/presentation/auth_controller.dart';
import 'theme_provider.dart';

/// Reads the current gym plan from the logged-in user session.
/// Defaults to FREE if not set.
final currentPlanProvider = Provider<GymPlan>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final session = SessionService(prefs);
  final user = session.getLoggedInUser();
  
  // Parse plan from user role/metadata
  // For now we read a stored plan string — defaults to free
  final planString = prefs.getString('gym_plan') ?? 'free';
  switch (planString) {
    case 'starter': return GymPlan.starter;
    case 'growth':  return GymPlan.growth;
    case 'pro':     return GymPlan.pro;
    default:        return GymPlan.free;
  }
});

/// Checks whether a given feature is accessible on the current plan
final canAccessFeatureProvider = Provider.family<bool, GatedFeature>((ref, feature) {
  final plan = ref.watch(currentPlanProvider);
  return plan.isAtLeast(feature.requiredPlan);
});
