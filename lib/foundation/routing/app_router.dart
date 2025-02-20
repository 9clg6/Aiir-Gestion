import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:init/application/providers/initializer.dart';
import 'package:init/domain/entities/order.entity.dart';
import 'package:init/domain/service/auth.service.dart';
import 'package:init/ui/screen/auth/auth.screen.dart';
import 'package:init/ui/screen/clients/clients.screen.dart';
import 'package:init/ui/screen/history/history.screen.dart';
import 'package:init/ui/screen/main/index.screen.dart';
import 'package:init/ui/screen/order_details/order_details.screen.dart';
import 'package:init/ui/screen/planner/planner.screen.dart';
import 'package:init/ui/screen/stats/stats.screen.dart';
import 'package:init/ui/screen/todo/todo.screen.dart';
import 'package:init/ui/widgets/custom_app_bar.dart';
import 'package:init/ui/widgets/custom_side_bar.dart';

final GlobalKey<NavigatorState> rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
    
final GlobalKey<NavigatorState> shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

String? _authRedirect(BuildContext context, GoRouterState state) {
  final bool isAuthenticated = injector<AuthService>().isUserAuthenticated;
  final bool isAuthRoute = state.matchedLocation == '/auth';

  if (!isAuthenticated) {
    if (isAuthRoute) return null;

    return '/auth';
  }

  if (isAuthenticated && isAuthRoute) {
    return '/main';
  }

  return null;
}

final GoRouter appRouter = GoRouter(
  debugLogDiagnostics: true,
  navigatorKey: rootNavigatorKey,
  initialLocation: '/main',
  redirect: _authRedirect,
  routes: [
    // Route d'authentification
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const AuthScreen(),
    ),

    // Routes protégées
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        // Ne pas afficher la barre latérale sur la page d'authentification
        final bool isAuthRoute = state.uri.toString() == '/auth';

        return Scaffold(
          appBar: !isAuthRoute ? const CustomAppBar() : null,
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          body: Row(
            children: [
              if (!isAuthRoute)
                CustomSideBar(
                  navigationShell: navigationShell,
                ),
              Expanded(child: navigationShell),
            ],
          ),
        );
      },
      branches: [
        // Branche 0 - Accueil
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/main',
              name: 'main',
              builder: (context, state) => const MainScreen(),
              routes: [
                GoRoute(
                  path: 'order-details/:orderId',
                  name: 'order-details',
                  builder: (context, state) => OrderDetailsScreen(
                    order: state.extra! as Order,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Branche 1 - Todo
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/todo',
              name: 'todo',
              builder: (context, state) => const TodoScreen(),
            ),
          ],
        ),
        // Branche 2 - Stats
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/stats',
              name: 'stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ],
        ),
        // Branche 3 - Planner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/planner',
              name: 'planner',
              builder: (context, state) => const PlannerScreen(),
            ),
          ],
        ),
        // Branche 4 - Clients
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/clients',
              name: 'clients',
              builder: (context, state) => const ClientsScreen(),
            ),
          ],
        ),
        // Branche 5 - History
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (context, state) => const HistoryScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
