import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final bool showAppBar;
  final String title;
  final Widget body;
  final Widget? bottomNavigationBar;
  final VoidCallback? customBackAction;
  final bool showBackButton;
  final List<Widget>? appbarAction;
  final FloatingActionButton? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final bool extendBody;
  final Color? backgroundColor;
  final double? toolBarHeight;
  const AppScaffold({
    super.key,
    this.showAppBar = true,
    this.title = '',
    required this.body,
    this.bottomNavigationBar,
    this.customBackAction,
    this.showBackButton = true,
    this.appbarAction,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.extendBody = false,
    this.backgroundColor,
    this.toolBarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      extendBody: extendBody,
      appBar: showAppBar
          ? AppBar(
              leading: showBackButton
                  ? IconButton(
                      onPressed: customBackAction ??
                          () {
                            context.pop();
                          },
                      icon: Icon(
                        CupertinoIcons.back,
                        color: AppTheme.getInstance().formColor,
                      ),
                    )
                  : null,
              title: Text(
                title,
                style: AppTextStyle.boldText.copyWith(
                  color: AppTheme.getInstance().formColor,
                ),
              ),
              centerTitle: false,
              toolbarHeight: toolBarHeight,
              backgroundColor:
                  backgroundColor ?? AppTheme.getInstance().primaryColor,
              actions: appbarAction,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
