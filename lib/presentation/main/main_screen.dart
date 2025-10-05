// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:verify_clone/core/base/home_scafold/base_home_scafold.dart';
// import 'package:verify_clone/core/config/resources/color.dart';

// import 'package:verify_clone/presentation/achievements_page/achievements_screen.dart';
// import 'package:verify_clone/presentation/home_page/home_page.dart';
// import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
// import 'package:verify_clone/presentation/main/widget/CustomBottomBar.dart';

// import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';
// import 'package:verify_clone/presentation/main/widget/drawer.dart';
// import 'package:verify_clone/presentation/second_page/second_page.dart';
// import 'package:verify_clone/presentation/seedlings_page/seedlings_screen.dart';
// import 'package:verify_clone/presentation/tree_page/tree_screen.dart';

// class Main extends StatelessWidget {
//   const Main({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MainScreen();
//   }
// }

// class MainScreen extends ConsumerStatefulWidget {
//   const MainScreen({super.key});

//   @override
//   ConsumerState<MainScreen> createState() => _MainScreenState();
// }

// class _MainScreenState extends ConsumerState<MainScreen> {
//   final _pageController = PageController();

//   @override
//   void didUpdateWidget(covariant MainScreen oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     final currentPage = ref.read(mainProvider).currentPageType;
//     _pageController.jumpToPage(currentPage.pageIndex);
//   }

//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(mainProvider);
//     return AppHomeScaffold(
//       showBackButton: false,
//       onDrawerChanged: (isOpen) {
//         ref.read(drawerOpenProvider.notifier).state = isOpen;
//       },
//       backgroundColor: colorMediumHex.withOpacity(0.72),
//       drawer: Drawer(
//         width: double.infinity,
//         child: DrawerCommon(
//           currentPage: ref.watch(drawerPageProvider),
//           onSelected: (EnumDrawer selected) {
//             ref.read(drawerPageProvider.notifier).setPage(selected);
//           },
//         ),
//       ),
//       body: PageView(
//         controller: _pageController,
//         physics: const NeverScrollableScrollPhysics(),
//         children: const [
//           HomePage(),
//           TreeScreen(),
//           SecondPage(),
//           SeedlingsScreen(),
//           AchievementsScreen(),
//         ],
//       ),
//       bottomNavigationBar: ref.watch(drawerOpenProvider)
//           ? const SizedBox.shrink()
//           : CustomBottomBar(
//               currentPage: state.currentPageType,
//               onPageSelected: (page) {
//                 ref.read(mainProvider.notifier).changePage(page);
//                 _pageController.jumpToPage(page.pageIndex);
//               },
//             ),
//     );
//   }
// }
