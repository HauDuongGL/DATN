import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/base/view_your_tree/base_view_your_tree.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';

import 'package:verify_clone/presentation/main/widget/CustomBottomBar.dart';
import 'package:verify_clone/presentation/main/common/enum.dart';
import 'package:verify_clone/presentation/main/widget/drawer.dart';

class RootShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;
  const RootShell({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    final currentIndex = navigationShell.currentIndex;
    final currentPage = PageType.values[currentIndex];

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: CustomBottomBar(
        currentPage: currentPage,
        onPageSelected: (page) {
          navigationShell.goBranch(
            page.pageIndex,
          );
        },
      ),
    );
  }
}

class AppBarYourTree extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppBarYourTree({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ViewYourTreeScaffold(
      showInternet: true,
      preferredSize: Dimens.d159,
      appBarBackgroundImage: Assets.images.viewPlantBg.provider(),
      logoColor: null,
      drawer: Drawer(
        width: double.infinity,
        child: DrawerCommon(
          currentPage: ref.watch(drawerPageProvider),
          onSelected: (EnumDrawer selected) {
            ref.read(drawerPageProvider.notifier).setPage(selected);
          },
        ),
      ),
      showAppBar: true,
      customBackAction: () {},
      body: navigationShell,
    );
  }
}
