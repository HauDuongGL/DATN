import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:verify_clone/core/base/base.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/data/services/tree/tree_type_service.dart';
import 'package:verify_clone/domain/entities/model.dart';

import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/presentation/main/common/enum_drawer.dart';
import 'package:verify_clone/presentation/main/riverpod/main_riverpod.dart';
import 'package:verify_clone/presentation/main/widget/drawer.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/presentation/widgets/loading/loading_img.dart';
import 'package:verify_clone/utils/common.dart';
import 'package:verify_clone/utils/constants/location_helper.dart';
import 'package:verify_clone/utils/overlay/overlay_api.dart';
import 'package:verify_clone/utils/style_utils.dart';

import 'riverpod/riverpod.dart';
import 'widget/widget.dart';

class PlantTrees extends ConsumerStatefulWidget {
  const PlantTrees({super.key});

  @override
  ConsumerState<PlantTrees> createState() => _PlantTreesState();
}

class _PlantTreesState extends ConsumerState<PlantTrees>
    with WidgetsBindingObserver {
  int? userId;
  late final Future<(List<TreeTypeModel>, List<PlanterModel>)> _futureAllData;
  final api = OverlayApi();
  bool hasPerm = false;
  bool isStarting = false;

  @override
  void initState() {
    super.initState();
    _futureAllData = _loadAllData();
    WidgetsBinding.instance.addObserver(this);
    _refreshPerm();

    Future.microtask(() async {
      await _loadUserId();
      if (userId == null) return;

      final prefs = await SharedPreferences.getInstance();
      final should = prefs.getBool('shouldResetPlantForm') ?? false;
      if (should) {
        await ref
            .read(treeListProvider(userId!).notifier)
            .resetAndCreateFresh();
        await prefs.remove('shouldResetPlantForm');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      await _refreshPerm();
      if (hasPerm) {
        await _startOverlay();
      }
    }
  }

  Future<void> _refreshPerm() async {
    try {
      hasPerm = await api.canDraw();
      if (mounted) setState(() {});
    } catch (e) {
      _showSnack('Cannot check overlay permission: $e');
    }
  }

  Future<void> _startOverlay() async {
    if (isStarting) return;
    setState(() => isStarting = true);
    try {
      final ok = await api.start();
      if (ok != true) {
        _showSnack('Failed to start overlay');
      }
    } catch (e) {
      _showSnack('Overlay start error: $e');
    } finally {
      if (mounted) setState(() => isStarting = false);
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  Future<void> _ensureStart() async {
    if (!hasPerm) {
      try {
        await api.requestPermission();
      } catch (e) {
        _showSnack('Failed to open overlay settings: $e');
      }
      return;
    }
    await _startOverlay();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('usrId');
    if (!mounted) return;
    if (id != null) setState(() => userId = id);
  }

  Future<(List<TreeTypeModel>, List<PlanterModel>)> _loadAllData() async {
    final trees = await TreeTypeService.instance.getAllTrees();
    final planters = await TreeTypeService.instance.getAllPlanter();
    return (trees, planters);
  }

  // ---------- Helpers ----------
  String _formatTime(String? iso, {String locale = 'en_US'}) {
    if (iso == null) return '';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '';
    return DateFormat('dd/MM/yy h:mma', locale).format(dt);
  }

  void _onPlanterChanged(String? value, List<TreeModel> treeList) {
    if (value == null || treeList.isEmpty || userId == null) return;
    ref.read(hashChangeProvider.notifier).state = true;
    ref.read(treeListProvider(userId!).notifier).updateTree(
          0,
          treeList[0].copyWith(planter: value),
        );
  }

  Future<void> _takeAndSavePhoto({
    required int treeId,
    required String kind,
  }) async {
    final path = await context.pushNamed<String>(RoutesName.camera.name);
    if (path == null) return;

    final pos = await LocationHelper.getPosition();
    if (pos == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Unable to get location. Please enable GPS & permission.')),
        );
      }
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    await ref.read(photoServiceProvider).insertPhotoWithLocation(
          treeId: treeId,
          kind: kind,
          path: path,
          takenAt: now,
          lat: pos.latitude,
          lng: pos.longitude,
          accuracy: pos.accuracy,
          source: 'gps',
        );

    ref.invalidate(photosByTreeProvider(userId!));

    final attempted = ref.read(submitAttemptedProvider);
    if (attempted) {
      final trees = ref.read(treeListProvider(userId!));
      final photosMap = await ref.read(photosByTreeProvider(userId!).future);
      onSubmitAllTrees(ref, trees, photosMap);
    }
  }

  bool _isTreeCompleteByValidation(
          TreeModel t, Map<int, TreeValidationState> map) =>
      (map[t.treeId]?.isValid ?? false);

  bool _isSubmitEnabledByValidation(
      List<TreeModel> trees, Map<int, TreeValidationState> map) {
    if (trees.isEmpty) return false;
    final firstOk = _isTreeCompleteByValidation(trees.first, map);
    return firstOk;
  }

  // -----------------------------

  Future<void> takeImage(Function(String path) onImageTaken) async {
    final result = await context.pushNamed<String>(RoutesName.camera.name);
    if (result != null) onImageTaken(result);
  }

  Future<void> onSaveAndExit(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getInt('usrId');
      if (id == null) {
        debugPrint('Missing userId');
        return;
      }

      final trees = ref.read(treeListProvider(id));
      await ref.read(treeListProvider(id).notifier).saveAllTrees(trees);
      await ref.read(markAllDraftsSubmittedProvider).markAllDraftsSubmitted(id);

      ref.invalidate(treeValidationMapProvider);
      ref.invalidate(treeListProvider(id));

      if (!context.mounted) return;
      await _ensureStart();
      GoRouter.of(context).goNamed(RoutesName.home.name);
    } catch (e) {
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('$e'),
          actions: [
            TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK')),
          ],
        ),
      );
    }
  }

  void _openLeave() {
    final container = ProviderScope.containerOf(context);

    context.goNamed(
      RoutesName.leave.name,
      extra: (BuildContext ctx) async {
        final prefs = await SharedPreferences.getInstance();
        final id = prefs.getInt('usrId');
        if (id == null) return;

        final trees = container.read(treeListProvider(id));
        await container.read(treeListProvider(id).notifier).saveAllTrees(trees);
        await container
            .read(markAllDraftsSubmittedProvider)
            .markAllDraftsSubmitted(id);

        container.invalidate(treeValidationMapProvider);
        container.invalidate(treeListProvider(id));

        if (ctx.mounted) GoRouter.of(ctx).goNamed(RoutesName.home.name);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final treesNotifier = ref.read(treeListProvider(userId!).notifier);
    final treeList = ref.watch(treeListProvider(userId!));
    final isCheck = ref.watch(permissionCheckProvider);
    final validationMap = ref.watch(treeValidationMapProvider);

    final hasAny = treeList.isNotEmpty;
    bool _hasKind(List<Photo> list, String k) =>
        list.any((p) => (p.kind).toLowerCase() == k);

    final canAddMore = treeList.length < 10;

    final photosByTreeAsync = ref.watch(photosByTreeProvider(userId!));
    final photosMap = photosByTreeAsync.maybeWhen(
      data: (m) => m,
      orElse: () => const <int, List<Photo>>{},
    );

    final first = hasAny ? treeList.first : null;
    final typeOk = first?.type?.trim().isNotEmpty ?? false;
    final firstPhotos = hasAny
        ? (photosMap[first!.treeId] ?? const <Photo>[])
        : const <Photo>[];
    final hasBefore = _hasKind(firstPhotos, 'before');
    final hasAfter = _hasKind(firstPhotos, 'after');

    final isFirstComplete = hasAny && typeOk && hasBefore && hasAfter;

    final hasIncompleteAfterFirst = isFirstComplete &&
        treeList.skip(1).any(
              (t) => !_isTreeCompleteByValidation(t, validationMap),
            );

    final attempted = ref.watch(submitAttemptedProvider);
    final Color submitBtnColor = !isFirstComplete
        ? colorNeutralGray
        : (hasIncompleteAfterFirst ? colorBlue : colorDarkOliveGreen);

    return AppHomeScaffold(
      showInternet: true,
      preferredSize: Dimens.d95,
      logoColor: colorBlack,
      backgroundColor: colorMediumHex.withOpacity(0.72),
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
      customBackAction: !isFirstComplete
          ? () {
              context.goNamed(RoutesName.popUp.name);
            }
          : () {
              _openLeave();
            },
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
              horizontal: Dimens.d20.w, vertical: Dimens.d16.h),
          child: FutureBuilder<(List<TreeTypeModel>, List<PlanterModel>)>(
            future: _futureAllData,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done ||
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final (allTreeTypes, planters) = snapshot.data!;
              final planterNames = planters.map((p) => p.planter).toList();

              final submitEnabled =
                  _isSubmitEnabledByValidation(treeList, validationMap);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --------- Header: Planter dropdown ----------
                  Row(
                    children: [
                      Text(
                        'Planting for',
                        style: AppTextStyle.interMediumText.copyWith(
                          fontSize: Dimens.d14,
                          color: colorBlack,
                        ),
                      ),
                      spaceW12,
                      Expanded(
                        child: CustomDropdown<String>(
                          hintText: 'Select',
                          items: planterNames,
                          decoration: CustomDropdownDecoration(
                            closedFillColor: colorWhite,
                            closedBorder: Border.all(color: colorNeutralGray),
                            closedBorderRadius:
                                BorderRadius.circular(Dimens.d24.r),
                            closedSuffixIcon: const Icon(
                                CupertinoIcons.chevron_down,
                                size: Dimens.d18),
                            prefixIcon: const Icon(CupertinoIcons.person,
                                color: colorDarkOlive, size: Dimens.d18),
                            hintStyle: AppTextStyle.interText.copyWith(
                              fontSize: Dimens.d14.sp,
                              color: colorDarkGrayBlue,
                            ),
                            listItemStyle: AppTextStyle.interText.copyWith(
                              fontSize: Dimens.d14.sp,
                              color: colorDarkGrayBlue,
                            ),
                          ),
                          onChanged: (value) =>
                              _onPlanterChanged(value, treeList),
                        ),
                      ),
                    ],
                  ),
                  spaceH24,
                  const Divider(),
                  spaceH24,

                  // --------- Title & note ----------
                  Text(
                    'Plant Trees',
                    style: AppTextStyle.interBoldText.copyWith(
                      fontSize: Dimens.d24.sp,
                    ),
                  ),
                  spaceH16,
                  Text(
                    'You can plant and document up to 10 trees in each batch.',
                    style: AppTextStyle.interText.copyWith(
                        fontSize: Dimens.d16.sp, color: colorDarkGrayBlue),
                  ),

                  // --------- Permission checkbox ----------
                  CheckBoxCommon(
                    permissionText:
                        'I have permission to plant trees on this property.',
                    onChanged: (value) => ref
                        .read(permissionCheckProvider.notifier)
                        .state = value ?? false,
                    isCheck: isCheck,
                    ref: ref,
                  ),
                  spaceH8,

                  // --------- Tree cards ----------
                  ...List.generate(treeList.length, (index) {
                    final tree = treeList[index];
                    final stepBeforeKey =
                        (treeId: tree.treeId!, kind: 'before');
                    final stepAfterKey = (treeId: tree.treeId!, kind: 'after');
                    final isAfterLoading = ref.watch(
                      loadingMapProvider.select(
                        (m) => m[stepAfterKey] == true,
                      ),
                    );

                    final isBeforeLoading = ref.watch(
                      loadingMapProvider.select(
                        (m) => m[stepBeforeKey] == true,
                      ),
                    );
                    final photosByTreeAsync =
                        ref.watch(photosByTreeProvider(userId!));
                    final photosMap = photosByTreeAsync.maybeWhen(
                      data: (m) => m,
                      orElse: () => const <int, List<Photo>>{},
                    );

                    final v = validationMap[tree.treeId];
                    final missingBefore =
                        attempted && (v?.missingBefore ?? false);
                    final missingAfter =
                        attempted && (v?.missingAfter ?? false);

                    Photo? firstOfKind(List<Photo> list, String k) {
                      try {
                        return list
                            .firstWhere((p) => p.kind.toLowerCase() == k);
                      } catch (_) {
                        return null;
                      }
                    }

                    final list = photosMap[tree.treeId] ?? const <Photo>[];
                    final before = firstOfKind(list, 'before');
                    final after = firstOfKind(list, 'after');

                    // ---- STEP 1 ----
                    final Widget step1 = (before != null)
                        ? PhotoStepCommon(
                            step: 'STEP 1',
                            subtitle: 'Seedling photo before planting',
                            meg: '(Next to hole)',
                            loading: isBeforeLoading,
                            onTap: isBeforeLoading
                                ? null
                                : () =>
                                    ref.read(loadingMapProvider.notifier).run(
                                          stepBeforeKey,
                                          () => _takeAndSavePhoto(
                                              treeId: tree.treeId!,
                                              kind: 'before'),
                                        ),
                            borderSideColor:
                                missingBefore ? errorColor : colorBlue,
                            containerCustom: ImageScreen(
                                ontap: isBeforeLoading
                                    ? null
                                    : () => ref
                                        .read(loadingMapProvider.notifier)
                                        .run(
                                          stepBeforeKey,
                                          () => _takeAndSavePhoto(
                                              treeId: tree.treeId!,
                                              kind: 'before'),
                                        ),
                                titleBtn: 'Retake',
                                title: 'Seedling',
                                timer: _formatTime(
                                  DateTime.fromMillisecondsSinceEpoch(
                                          before.takenAt)
                                      .toIso8601String(),
                                ),
                                image: LoadingImg(
                                  imgProvider: FileImage(File(before.path)),
                                  fit: BoxFit.cover,
                                  borderRadius:
                                      BorderRadius.circular(Dimens.d8.r),
                                )),
                          )
                        : PhotoStepCommon(
                            step: 'STEP 1',
                            subtitle: 'Seedling photo before planting',
                            meg: '(Next to hole)',
                            borderSideColor:
                                missingBefore ? errorColor : colorBlue,
                            onTap: isBeforeLoading
                                ? null
                                : () =>
                                    ref.read(loadingMapProvider.notifier).run(
                                          stepBeforeKey,
                                          () => _takeAndSavePhoto(
                                            treeId: tree.treeId!,
                                            kind: 'before',
                                          ),
                                        ),
                          );

                    // ---- STEP 2 ----
                    final Widget step2 = (before != null)
                        ? (after != null
                            ? PhotoStepCommon(
                                step: 'STEP 2',
                                subtitle: 'Photo after planting',
                                meg: '(Seedling planted in the hole)',
                                borderSideColor: missingAfter
                                    ? errorColor
                                    : colorNeutralGray,
                                containerCustom: ImageScreen(
                                  backgroundColor: missingAfter
                                      ? colorPastelPink
                                      : colorWhite,
                                  ontap: isAfterLoading
                                      ? null
                                      : () => ref
                                          .read(loadingMapProvider.notifier)
                                          .run(
                                            stepAfterKey,
                                            () => _takeAndSavePhoto(
                                                treeId: tree.treeId!,
                                                kind: 'after'),
                                          ),
                                  title: 'Planted',
                                  timer: _formatTime(
                                    DateTime.fromMillisecondsSinceEpoch(
                                            after.takenAt)
                                        .toIso8601String(),
                                  ),
                                  titleBtn: 'Retake',
                                  image: ClipRRect(
                                    borderRadius:
                                        BorderRadius.circular(Dimens.d8.r),
                                    child: Image.file(File(after.path),
                                        fit: BoxFit.cover),
                                  ),
                                ),
                              )
                            : PhotoStepCommon(
                                step: 'STEP 2',
                                subtitle: 'Photo after planting',
                                meg: '(Seedling planted in the hole)',
                                borderSideColor: missingAfter
                                    ? errorColor
                                    : colorNeutralGray,
                                containerCustom: ImageScreen(
                                  ontap: isAfterLoading
                                      ? null
                                      : () => ref
                                          .read(loadingMapProvider.notifier)
                                          .run(
                                            stepAfterKey,
                                            () => _takeAndSavePhoto(
                                                treeId: tree.treeId!,
                                                kind: 'after'),
                                          ),
                                  titleBtn: 'Take Photo',
                                  textColor: colorWhite,
                                  backgroundColor: colorBlue,
                                  iconColor: colorWhite,
                                  border: Border.all(
                                      color: missingAfter
                                          ? errorColor
                                          : colorBlue),
                                  title: 'Planted',
                                  colorBg:
                                      missingAfter ? colorPastelPink : null,
                                  image: Container(
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(Dimens.d8.r),
                                      color: colorNeutralGray,
                                    ),
                                    child: Center(
                                      child: Text(
                                        'No Photo Yet',
                                        style: AppTextStyle.interText.copyWith(
                                          fontSize: Dimens.d12.sp,
                                          color: colorDisabled,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ))
                        : const PhotoStepCommon(
                            step: 'STEP 2',
                            subtitle: 'Seedling photo before planting',
                            borderSideColor: colorNeutralGray,
                            meg: '(Next to hole)',
                            backgroundBtn: colorNeutralGray,
                            iconColor: colorDisabled,
                            textColor: colorDisabled,
                            onTap: null,
                          );

                    return TreeItemCard(
                      index: index,
                      tree: tree,
                      allTrees: allTreeTypes,
                      onDelete: () {
                        ref.read(hashChangeProvider.notifier).state = true;
                        treesNotifier.removeTree(index);
                        ref.invalidate(photosByTreeProvider(userId!));
                      },
                      onUpdate: () {
                        ref.read(hashChangeProvider.notifier).state = true;
                        treesNotifier.updateTree(index, tree);
                      },
                      onNameChanged: (value) {
                        ref.read(hashChangeProvider.notifier).state = true;
                        treesNotifier.updateTree(
                            index, tree.copyWith(name: value));
                      },
                      onTypeChanged: (value) {
                        ref.read(hashChangeProvider.notifier).state = true;
                        treesNotifier.updateTree(
                            index, tree.copyWith(type: value));
                      },
                      photoStepFirst: isBeforeLoading
                          ? const SizedBox(
                              height: 160,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            )
                          : step1,
                      photoStepSecond: isAfterLoading
                          ? const SizedBox(
                              height: 160,
                              child: Center(
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)),
                            )
                          : step2,
                    );
                  }),

                  // --------- Add tree ----------
                  Visibility(
                    visible: canAddMore,
                    child: Column(
                      children: [
                        spaceH32,
                        const Divider(),
                        spaceH32,
                        AppButton(
                          width: double.infinity,
                          borderRadius: Dimens.d24.r,
                          title: 'Add Another Tree',
                          onTap: treeList.length >= 10
                              ? null
                              : () {
                                  ref.read(hashChangeProvider.notifier).state =
                                      true;
                                  treesNotifier.addTree();
                                },
                          iconRight: Icon(CupertinoIcons.add,
                              size: Dimens.d18.sp, color: colorWhite),
                          color: colorBlue,
                          style: AppTextStyle.interMediumText.copyWith(
                              fontSize: Dimens.d16.sp, color: colorWhite),
                        ),
                      ],
                    ),
                  ),

                  spaceH32,
                  const Divider(),
                  spaceH32,

                  // --------- Submit ----------
                  AppButton(
                    width: double.infinity,
                    borderRadius: Dimens.d24.r,
                    title: 'Submit →',
                    onTap: !isFirstComplete
                        ? null
                        : () async {
                            final latestPhotosMap = await ref
                                .read(photosByTreeProvider(userId!).future);
                            onSubmitAllTrees(ref, treeList, latestPhotosMap);

                            ref.read(submitAttemptedProvider.notifier).state =
                                true;

                            final vMap = ref.read(treeValidationMapProvider);
                            final allValid = treeList
                                .every((t) => vMap[t.treeId]?.isValid ?? false);

                            if (!allValid) {
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Incomplete details'),
                                    content: const Text(
                                        'Please complete required fields and photos (before & after) for each tree.'),
                                    actions: [
                                      TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('OK')),
                                    ],
                                  ),
                                );
                              }
                              ref.read(submitSuccessProvider.notifier).state =
                                  false;
                              return;
                            }

                            showDialogConfirm(
                              title: 'Submit ${treeList.length} Tree(s)',
                              text: 'By clicking ',
                              subText1: 'confirm, ',
                              subText2:
                                  'you verify that this tree is authentic and appropriately planted.',
                              cancel: 'Check again',
                              confirm: 'Confirm',
                              onShowdialog: () async {
                                onSubmitAllTrees(
                                    ref, treeList, latestPhotosMap);
                                ref.read(submitSuccessProvider.notifier).state =
                                    true;
                              },
                              colorConfirm: colorBlue,
                            );
                          },
                    color: submitBtnColor,
                    style: AppTextStyle.interMediumText.copyWith(
                      fontSize: Dimens.d16.sp,
                      color: submitEnabled ? colorWhite : colorDarkGrayBlue,
                    ),
                  ),

                  spaceH16,

                  // --------- Save & Exit ----------
                  AppButton(
                    width: double.infinity,
                    borderRadius: Dimens.d24.r,
                    title: 'Save & Exit',
                    iconRight: Assets.icons.icSave.svg(
                      width: Dimens.d18.w,
                      height: Dimens.d18.h,
                      colorFilter:
                          const ColorFilter.mode(colorBlue, BlendMode.srcIn),
                    ),
                    onTap: () {
                      showDialogConfirms(
                        title: 'Finished Planting?',
                        text: 'By clicking ',
                        subText1: 'confirm ',
                        subText2:
                            'you verify that this tree is authentic and appropriately planted.',
                        cancel: 'Check again',
                        confirm: 'Confirm',
                        onShowdialog: () async {
                          await onSaveAndExit(context);
                        },
                        colorConfirm: colorBlue,
                      );
                    },
                    border: Border.all(color: colorBlue),
                    style: AppTextStyle.interMediumText
                        .copyWith(fontSize: Dimens.d16.sp, color: colorBlue),
                  ),

                  spaceH32,
                  const Divider(),
                  Center(
                    child: TextButton(
                      onPressed: _openLeave,
                      child: Text(
                        'Discard this batch',
                        style: AppTextStyle.interText.copyWith(
                            fontSize: Dimens.d16.sp, color: colorDarkGrayBlue),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
