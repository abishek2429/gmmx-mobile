import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/role_dashboards/owner_dashboard.dart';
import '../../features/dashboard/presentation/role_dashboards/trainer_dashboard.dart';
import '../../features/dashboard/presentation/role_dashboards/client_dashboard.dart';
import '../../features/dashboard/presentation/shells/owner_shell.dart';
import '../../features/dashboard/presentation/shells/trainer_shell.dart';
import '../../features/dashboard/presentation/shells/client_shell.dart';
import '../../features/dashboard/presentation/screens/placeholder_screen.dart';
import '../../services/session_service.dart';
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

final appRouterProvider = Provider<GoRouter>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final sessionService = SessionService(prefs);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = sessionService.isLoggedIn;
      final user = sessionService.getLoggedInUser();
      final currentPath = state.uri.path;

      // If logged in and on auth pages, redirect to dashboard
      if (isLoggedIn && user != null) {
        if (currentPath == '/' || currentPath == '/login') {
          return '/${user.normalizedRole}/home';
        }
      }

      // If not logged in and trying to access dashboard routes, redirect to welcome
      if (!isLoggedIn && (currentPath.startsWith('/owner') || currentPath.startsWith('/trainer') || currentPath.startsWith('/client'))) {
        return '/';
      }

      return null;
    },
    routes: [
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

      // ----------------------------------------------------
      // OWNER SHELL
      // ----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return OwnerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _ownerHomeKey,
            routes: [
              GoRoute(
                path: '/owner/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: OwnerDashboard(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ownerMembersKey,
            routes: [
              GoRoute(
                path: '/owner/members',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Members',
                    icon: Icons.people_alt_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ownerTrainersKey,
            routes: [
              GoRoute(
                path: '/owner/trainers',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Trainers',
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ownerPlansKey,
            routes: [
              GoRoute(
                path: '/owner/plans',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Plans & Payments',
                    icon: Icons.payments_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _ownerProfileKey,
            routes: [
              GoRoute(
                path: '/owner/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Profile & Settings',
                    icon: Icons.settings_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ----------------------------------------------------
      // TRAINER SHELL
      // ----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return TrainerShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _trainerHomeKey,
            routes: [
              GoRoute(
                path: '/trainer/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: TrainerDashboard(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trainerClientsKey,
            routes: [
              GoRoute(
                path: '/trainer/clients',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Assigned Clients',
                    icon: Icons.people_alt_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trainerPlansKey,
            routes: [
              GoRoute(
                path: '/trainer/plans',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Workout Plans',
                    icon: Icons.assignment_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trainerAttendanceKey,
            routes: [
              GoRoute(
                path: '/trainer/attendance',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Attendance',
                    icon: Icons.qr_code_scanner_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _trainerProfileKey,
            routes: [
              GoRoute(
                path: '/trainer/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Profile',
                    icon: Icons.person_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // ----------------------------------------------------
      // CLIENT SHELL
      // ----------------------------------------------------
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ClientShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _clientHomeKey,
            routes: [
              GoRoute(
                path: '/client/home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ClientDashboard(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientWorkoutKey,
            routes: [
              GoRoute(
                path: '/client/workout',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Workout Plan',
                    icon: Icons.fitness_center_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientHistoryKey,
            routes: [
              GoRoute(
                path: '/client/history',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Attendance History',
                    icon: Icons.calendar_month_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientProgressKey,
            routes: [
              GoRoute(
                path: '/client/progress',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Progress Tracking',
                    icon: Icons.trending_up_rounded,
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _clientProfileKey,
            routes: [
              GoRoute(
                path: '/client/profile',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: PlaceholderScreen(
                    title: 'Profile & Trainer',
                    icon: Icons.person_rounded,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
