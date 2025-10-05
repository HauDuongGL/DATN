import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/config/router/root_shell/root_shell.dart';

import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/core/network/module.dart';
import 'package:verify_clone/domain/entities/tree_items.dart';
import 'package:verify_clone/domain/locals/prefs_service.dart';
import 'package:verify_clone/presentation/achievements_page/achievements_screen.dart';
import 'package:verify_clone/presentation/cameras/camera_screen.dart';
import 'package:verify_clone/presentation/enable_location_page/enable_location_screen.dart';

import 'package:verify_clone/presentation/get_selling/get_selling.dart';
import 'package:verify_clone/presentation/group/group.dart';
import 'package:verify_clone/presentation/helper_center/helper_center_page.dart';
import 'package:verify_clone/presentation/home_page/home_page.dart';
import 'package:verify_clone/presentation/leave_page/leave_screen.dart';

import 'package:verify_clone/presentation/plant_page/plant_screen.dart';
import 'package:verify_clone/presentation/pop_up_page/pop_up_page.dart';
import 'package:verify_clone/presentation/protect_trees/protect_trees.dart';
import 'package:verify_clone/presentation/second_page/second_page.dart';
import 'package:verify_clone/presentation/seedlings_page/seedlings_screen.dart';
import 'package:verify_clone/presentation/sign_in_page/sign_in_screen.dart';
import 'package:verify_clone/presentation/tree_detail_screen/tree_detail_screen.dart';
import 'package:verify_clone/presentation/tree_page/tree_screen.dart';
import 'package:verify_clone/presentation/view_all_tree_page/view_all_tree_screen.dart';

// final getIt = GetIt.instance;

GoRoute _defaultGorouter({
  required RoutesGen router,
  required Widget Function(BuildContext context, GoRouterState state) builder,
  List<GoRoute> goRouters = const [],
}) =>
    GoRoute(
      path: router.path,
      name: router.name,
      routes: goRouters,
      builder: builder,
    );

GoRoute _transitionRouter({
  required RoutesGen router,
  required Widget page,
  List<GoRoute> goRoutes = const [],
}) =>
    GoRoute(
      path: router.path,
      name: router.name.isNotEmpty ? router.name : null,
      routes: goRoutes,
      redirect: (BuildContext context, GoRouterState state) {
        return RoutesName.login.path;
      },
      pageBuilder: (BuildContext context, GoRouterState state) {
        return CustomTransitionPage(
          key: state.pageKey,
          child: page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity:
                  CurveTween(curve: Curves.easeInOutCirc).animate(animation),
              child: child,
            );
          },
        );
      },
    );

final GoRouter appRouterConfig = GoRouter(
  navigatorKey: getIt.get<GlobalKey<NavigatorState>>(),
  initialLocation: (PrefsService.getToken().isEmpty)
      ? RoutesName.login.path
      : RoutesName.home.path,
  onException: (context, state, router) {
    // Handle reCAPTCHA or unknown routes
    print('Unknown route: ${state.uri}');
    // if (state.uri.toString().contains('recaptcha')) {
    //   router.go(RoutesName.verify.path);
    // } else {
    //   router.go(RoutesName.login.path);
    // }
  },
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navShell) =>
          RootShell(navigationShell: navShell),
      branches: [
        StatefulShellBranch(
          routes: [
            _defaultGorouter(
              router: RoutesName.home,
              builder: (context, state) => const HomePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            StatefulShellRoute.indexedStack(
              builder: (context, state, appbar) => AppBarYourTree(
                navigationShell: appbar,
              ),
              branches: [
                StatefulShellBranch(
                  routes: [
                    _defaultGorouter(
                      router: RoutesName.treeView,
                      builder: (context, state) => const TreeScreen(),
                      goRouters: [
                        GoRoute(
                          name: RoutesName.treeDetail.name,
                          path: '/tree/:id',
                          builder: (context, state) {
                            final id = int.tryParse(
                                    state.pathParameters['id'] ?? '') ??
                                0;

                            final preload = state.extra is TreeItem
                                ? state.extra as TreeItem
                                : null;
                            final safeItem =
                                (preload != null && preload.id == id)
                                    ? preload
                                    : null;

                            return TreeDetailScreen(
                              key: ValueKey('tree-$id'),
                              treeId: id,
                              item: safeItem,
                            );
                          },
                        ),
                        GoRoute(
                          name: RoutesName.viewTree.name,
                          path: '/treeView/:id',
                          builder: (context, state) {
                            final id = int.tryParse(
                                    state.pathParameters['id'] ?? '') ??
                                0;

                            return ViewAllTreeScreen(
                              key: ValueKey('tree-$id'),
                              treeId: id,
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _defaultGorouter(
              router: RoutesName.second,
              builder: (context, state) => const SecondPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _defaultGorouter(
              router: RoutesName.seedlingScreen,
              builder: (context, state) => const SeedlingsScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            _defaultGorouter(
              router: RoutesName.achievements,
              builder: (context, state) => const AchievementsScreen(),
            ),
          ],
        ),
      ],
    ),
    _defaultGorouter(
      router: RoutesName.login,
      builder: (context, state) => const SignInScreen(),
    ),
    _defaultGorouter(
      router: RoutesName.popUp,
      builder: (context, state) => const PopUpPage(),
    ),
    _defaultGorouter(
      router: RoutesName.getSelling,
      builder: (context, state) => const GetSelling(),
    ),
    _defaultGorouter(
      router: RoutesName.plantTrees,
      builder: (context, state) => const PlantTrees(),
    ),
    _defaultGorouter(
      router: RoutesName.protectTrees,
      builder: (context, state) => const ProtectTrees(),
    ),
    _defaultGorouter(
      router: RoutesName.group,
      builder: (context, state) => const Group(),
    ),
    _defaultGorouter(
      router: RoutesName.helpCenter,
      builder: (context, state) => const HelperCenterPage(),
    ),
    _defaultGorouter(
      router: RoutesName.camera,
      builder: (context, state) => const CameraScreen(),
    ),
    _defaultGorouter(
      router: RoutesName.leave,
      builder: (context, state) {
        final cb = state.extra as Future<void> Function(BuildContext)?;
        return LeaveScreen(onSaveAndExit: cb ?? (_) async {});
      },
    ),
    _defaultGorouter(
      router: RoutesName.enableLocation,
      builder: (context, state) => const EnableLocationScreen(),
    )
  ],
);
