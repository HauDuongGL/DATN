import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/domain/entities/tree_model.dart';
import 'package:verify_clone/domain/entities/tree_type_model.dart';
import 'package:verify_clone/presentation/plant_page/riverpod/riverpod.dart';
import 'package:verify_clone/presentation/plant_page/widget/dropdown_common.dart';
import 'package:verify_clone/utils/common.dart';
import 'package:verify_clone/utils/style_utils.dart';

class TreeItemCard extends ConsumerStatefulWidget {
  final int index;
  final TreeModel tree;
  final List<TreeTypeModel> allTrees;
  final VoidCallback onUpdate;
  final VoidCallback onDelete;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onTypeChanged;
  final VoidCallback? onTapFirstCamera;
  final VoidCallback? onTapSecondCamera;
  final Widget? photoStepFirst;
  final Widget? photoStepSecond;

  const TreeItemCard({
    super.key,
    required this.index,
    required this.tree,
    required this.allTrees,
    required this.onUpdate,
    required this.onDelete,
    required this.onNameChanged,
    required this.onTypeChanged,
    this.onTapFirstCamera,
    this.onTapSecondCamera,
    this.photoStepFirst,
    this.photoStepSecond,
  });

  @override
  ConsumerState<TreeItemCard> createState() => _TreeItemCardState();
}

class _TreeItemCardState extends ConsumerState<TreeItemCard> {
  bool isExpanded = true;
  bool isEditingName = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.tree.name);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final validationMap = ref.watch(treeValidationMapProvider);
    final validation = validationMap[widget.tree.treeId];
    final isComplete = validation?.isValid ?? false;
    final hasMissing = validation?.hasMissingFields ?? false;

    final selectedTreeType = widget.tree.type;
    TreeTypeModel? selectedItem;
    if (selectedTreeType != null) {
      final matches = widget.allTrees
          .where((t) => t.commonName == selectedTreeType)
          .toList(growable: false);
      if (matches.isNotEmpty) {
        selectedItem = matches.first;
      }
    }

    Color borderColor;
    Color? backgroundColor;

    if (isComplete) {
      borderColor = colorSuccessGreen;
    } else if (hasMissing) {
      borderColor = errorColor;
    } else {
      borderColor = colorNeutralGray50;
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: Dimens.d8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      color: backgroundColor ?? colorWhite,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: colorWhite),
        child: ExpansionTile(
          initiallyExpanded: isExpanded,
          onExpansionChanged: (expanded) {
            setState(() => isExpanded = expanded);
          },
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isEditingName)
                    Expanded(
                      child: TextFormField(
                        controller: _controller,
                        autofocus: true,
                        onChanged: widget.onNameChanged,
                        onFieldSubmitted: (_) {
                          if (_controller.text.trim().isEmpty) {
                            setState(() => isEditingName = false);
                          }
                          widget.onUpdate();
                        },
                        style: Theme.of(context).textTheme.titleMedium,
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        ),
                      ),
                    )
                  else
                    Text(
                      widget.tree.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  if (isEditingName) const Spacer(),
                  IconButton(
                    icon: Icon(
                      isEditingName ? Icons.check : Icons.edit,
                      color: colorDarkGrayBlue,
                    ),
                    onPressed: () {
                      setState(() {
                        isEditingName = !isEditingName;
                      });
                      if (!isEditingName) {
                        widget.onUpdate();
                      }
                    },
                  ),
                ],
              ),
              if (!isExpanded && hasMissing)
                Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: errorColor, size: Dimens.d16.sp),
                    const SizedBox(width: 4),
                    const Text(
                      "Missing fields",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Dimens.d16.w,
                vertical: Dimens.d8.h,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: "What type of tree are you planting?",
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d16.sp,
                      ),
                      children: [
                        TextSpan(
                          text: "*",
                          style: AppTextStyle.interText.copyWith(
                            fontSize: Dimens.d14.sp,
                            color: colorFail,
                          ),
                        ),
                      ],
                    ),
                  ),
                  DropDownSearchCommon<TreeTypeModel>(
                    items: widget.allTrees,
                    filled: hasMissing,
                    fillColor: hasMissing ? colorPastelPink : null,
                    errorText: hasMissing ? 'This is a caption' : null,
                    selectedItem: selectedItem,
                    itemAsString: (tree) => tree.commonName,
                    onChanged: (tree) =>
                        widget.onTypeChanged(tree?.commonName ?? ''),
                    titleText: 'Select tree type',
                    hintText: 'Type to search tree types',
                    itemBuilder: (context, item, isSelected) {
                      return Column(
                        children: [
                          ListTile(
                            title: Text(
                              item.commonName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              item.scientificName,
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                            dense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          const Divider(
                            height: 1,
                            thickness: 0.5,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: widget.photoStepFirst ?? const SizedBox()),
                      spaceW12,
                      Expanded(
                          child: widget.photoStepSecond ?? const SizedBox()),
                    ],
                  ),
                  spaceH8,
                  if (isComplete)
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.check_mark,
                          color: colorSuccessGreen,
                          size: Dimens.d16.sp,
                        ),
                        Text(
                          'Photos & Details Complete',
                          style: AppTextStyle.interMediumText.copyWith(
                            fontSize: Dimens.d16.sp,
                            color: colorSuccessGreen,
                          ),
                        ),
                      ],
                    ),
                  TextButton.icon(
                    onPressed: () {
                      showDialogConfirms(
                        title: 'Delete this tree?',
                        text: 'Deleting this tree will ',
                        subText1: 'permanently ',
                        subText2:
                            'remove the details that you’ve put in for this tree.',
                        cancel: 'Cancel',
                        confirm: 'Delete',
                        onShowdialog: () {
                          widget.onDelete();
                          if (mounted) Navigator.of(context).pop();
                        },
                        colorConfirm: errorColor,
                      );
                    },
                    icon: Icon(
                      CupertinoIcons.delete,
                      color: colorFail,
                      size: Dimens.d18.sp,
                    ),
                    label: Text(
                      "Delete this tree",
                      style: AppTextStyle.interMediumText.copyWith(
                        fontSize: Dimens.d14.sp,
                        color: colorFail,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
