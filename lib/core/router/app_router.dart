import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/screens/gym_lookup_screen.dart';
import '../../features/auth/providers/gym_provider.dart';

import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/role_dashboards/owner_dashboard.dart';
import '../../features/dashboard/presentation/role_dashboards/trainer_dashboard.dart';
import '../../features/dashboard/presentation/role_dashboards/client_dashboard.dart';
import '../../features/dashboard/presentation/shells/owner_shell.dart';
import '../../features/dashboard/presentation/shells/trainer_shell.dart';
import '../../features/dashboard/presentation/shells/client_shell.dart';
import '../../features/dashboard/presentation/screens/placeholder_screen.dart';
import '../../features/client/presentation/client_list_page.dart';
import '../../features/trainer/presentation/trainer_list_page.dart';
import '../../features/client/presentation/client_creation_page.dart';
import '../../features/trainer/presentation/trainer_creation_page.dart';
import '../../features/plans/presentation/plans_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/workout/presentation/workout_plan_page.dart';
import '../../features/qr_attendance/presentation/attendance_history_page.dart';
import '../../features/progress/presentation/progress_page.dart';
import '../../features/qr_attendance/presentation/qr_scanner_page.dart';
import '../../features/trainer/presentation/trainer_clients_page.dart';
import '../../features/trainer/presentation/trainer_workout_plans_page.dart';
import '../../features/payments/presentation/payments_page.dart';
import '../../services/session_service.dart';
import '../../features/auth/presentation/auth_controller.dart';
import '../../models/user_model.dart';
import '../providers/theme_provider.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _ownerHomeKey = GlobalKey<NavigatorState>(debugLabel: 'ownerHome');
final _ownerMembersKey = GlobalKey<NavigatorState>(debugLabel: 'ownerMembers');
final _ownerTrainersKey = GlobalKey<NavigatorState>(debugLabel: 'ownerTrainers');
final _ownerPlansKey = GlobalKey<NavigatorState>(debugLabel: 'ownerPlans');
final _ownerProfileKey = GlobalKey<NavigatorState>(debugLabel: 'ownerProfile');

final _trainerHomeKey = GlobalKey<NavigatorState>(debugLabel: 'trainerHome');
final _trainerClientsKey = GlobalKey<NavigatorState>(debugLabel: 'trainerClients');
final _trainerPlansKey = GlobalKey<NavigatorState>(debugLabel: 'trainerPlans');
final _trainerAttendanceKey = GlobalKey<NavigatorState>(debugLabel: 'trainerAttendance');
final _trainerProfileKey = GlobalKey<NavigatorState>(debugLabel: 'trainerProfile');

final _clientHomeKey = GlobalKey<NavigatorState>(debugLabel: 'clientHome');
final _clientWorkoutKey = GlobalKey<NavigatorState>(debugLabel: 'clientWorkout');
final _clientHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'clientHistory');
final _clientProgressKey = GlobalKey<NavigatorState>(debugLabel: 'clientProgress');
final _clientProfileKey = GlobalKey<NavigatorState>(debugLabel: 'clientProfile');

final userProvider = Provider<UserModel?>((ref) {
  final authUser = ref.watch(authControllerProvider.select((s) => s.user));
  if (authUser != null) return authUser;
  return ref.read(sessionServiceProvider).getLoggedInUser();
});

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;
  RouterNotifier(this._ref) {
    _ref.listen(userProvider, (_, __) => notifyListeners());
    _ref.listen(gymProvider, (_, __) => notifyListeners());
  }
}

final routerNotifierProvider = Provider((ref) => RouterNotifier(ref));

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    refreshListenable: notifier,
    redirect: (context, state) {
      final user = ref.read(userProvider);
      final gymState = ref.read(gymProvider);
      final isLoggedIn = user != null;
      final currentPath = state.uri.path;
      final hasGym = gymState.hasValue && gymState.value != null;

      // 1. Logged in users: Always force them to their role-based dashboard if on public pages
      if (isLoggedIn && user != null) {
        final slug = gymState.value?.subdomain ?? 'dashboard';
        final homePath = '/$slug/${user.normalizedRole}';
        if (currentPath == '/' || currentPath == '/login' || currentPath == '/gym-lookup') {
          return homePath;
        }
      }

      // 2. Unauthenticated users:
      if (!isLoggedIn) {
        // If they try to access a protected route, send them to welcome
        if (currentPath.startsWith('/owner') ||
            currentPath.startsWith('/trainer') ||
            currentPath.startsWith('/client')) {
          return '/';
        }

        // If they are on welcome/login but don't have a gym yet, send to lookup
        // But don't redirect if we are currently loading the gym
        if (currentPath == '/login' && !hasGym && !gymState.isLoading) {
          return '/gym-lookup';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/gym-lookup',
        name: 'gym-lookup',
        builder: (context, state) => const GymLookupScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'welcome',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            final tween = Tween(begin: begin, end: end)
                .chain(CurveTween(curve: Curves.easeOutCubic));
            return SlideTransition(
              position: animation.drive(tween),
              child: child,
            );
          },
        ),
      ),

      // ─── ROLE-BASED DASHBOARDS (Multi-tenant) ──────────────────────
      GoRoute(
        path: '/:slug',
        routes: [
          // ─── OWNER SHELL ───────────────────────────────────────────────
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return OwnerShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _ownerHomeKey,
                routes: [
                  GoRoute(
                    path: 'owner',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: OwnerDashboard()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _ownerMembersKey,
                routes: [
                  GoRoute(
                    path: 'owner/members',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ClientListPage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _ownerTrainersKey,
                routes: [
                  GoRoute(
                    path: 'owner/trainers',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: TrainerListPage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _ownerPlansKey,
                routes: [
                  GoRoute(
                    path: 'owner/plans',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: PaymentsPage()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _ownerProfileKey,
                routes: [
                  GoRoute(
                    path: 'owner/profile',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ProfilePage()),
                  ),
                ],
              ),
            ],
          ),

          // ─── TRAINER SHELL ─────────────────────────────────────────────
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return TrainerShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _trainerHomeKey,
                routes: [
                  GoRoute(
                    path: 'trainer',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: TrainerDashboard()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _trainerClientsKey,
                routes: [
                  GoRoute(
                    path: 'trainer/clients',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: TrainerClientsPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _trainerPlansKey,
                routes: [
                  GoRoute(
                    path: 'trainer/plans',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: TrainerWorkoutPlansPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _trainerAttendanceKey,
                routes: [
                  GoRoute(
                    path: 'trainer/attendance',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: QrScannerPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _trainerProfileKey,
                routes: [
                  GoRoute(
                    path: 'trainer/profile',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ProfilePage()),
                  ),
                ],
              ),
            ],
          ),

          // ─── CLIENT SHELL ──────────────────────────────────────────────
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ClientShell(navigationShell: navigationShell);
            },
            branches: [
              StatefulShellBranch(
                navigatorKey: _clientHomeKey,
                routes: [
                  GoRoute(
                    path: 'client',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ClientDashboard()),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _clientWorkoutKey,
                routes: [
                  GoRoute(
                    path: 'client/workout',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: WorkoutPlanPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _clientHistoryKey,
                routes: [
                  GoRoute(
                    path: 'client/history',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: AttendanceHistoryPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _clientProgressKey,
                routes: [
                  GoRoute(
                    path: 'client/progress',
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: ProgressPage(),
                    ),
                  ),
                ],
              ),
              StatefulShellBranch(
                navigatorKey: _clientProfileKey,
                routes: [
                  GoRoute(
                    path: 'client/profile',
                    pageBuilder: (context, state) =>
                        const NoTransitionPage(child: ProfilePage()),
                  ),
                ],
              ),
            ],
      ),

      // ─── Full-screen routes (outside shell — no bottom nav) ────────
      GoRoute(
        path: '/:slug/owner/members/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ClientCreationPage(),
      ),
      GoRoute(
        path: '/:slug/owner/trainers/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const TrainerCreationPage(),
      ),
      GoRoute(
        path: '/scanner',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QrScannerPage(),
      ),
    ],
  );
});
