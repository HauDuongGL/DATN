import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:verify_clone/core/base/base.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/gen/assets.gen.dart';
import 'package:verify_clone/utils/style_utils.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  late List<CameraDescription> cameras;
  bool isCameraInitialized = false;
  bool isFlashOn = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
    cameraController = CameraController(
      cameras[0],
      ResolutionPreset.high,
      enableAudio: false,
    );
    await cameraController.initialize();
    if (!mounted) return;
    setState(() {
      isCameraInitialized = true;
    });
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _takePicture() async {
    if (!cameraController.value.isInitialized ||
        cameraController.value.isTakingPicture) return;

    try {
      final XFile file = await cameraController.takePicture();
      context.pop(file.path);
    } catch (e) {
      print('error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    isFlashOn = !isFlashOn;
    await cameraController.setFlashMode(
      isFlashOn ? FlashMode.torch : FlashMode.off,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      showBackButton: false,
      showAppBar: false,
      body: isCameraInitialized
          ? Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(cameraController),
                Positioned.fill(
                  child: IgnorePointer(
                      child: Assets.images.cameraBg.image(
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  )),
                ),
                Positioned(
                  top: Dimens.d40.h,
                  left: Dimens.d16.w,
                  right: Dimens.d16.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.clear,
                          color: colorWhite,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Text(
                        'Before planting',
                        style: AppTextStyle.interBoldText.copyWith(
                          fontSize: Dimens.d16.sp,
                          color: colorWhite,
                        ),
                      ),
                      GestureDetector(
                        onTap: _toggleFlash,
                        child: Icon(
                          isFlashOn
                              ? CupertinoIcons.bolt_badge_a_fill
                              : CupertinoIcons.bolt_fill,
                          color: colorWhite,
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 33,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      spaceW147,
                      GestureDetector(
                        onTap: _takePicture,
                        child: Assets.icons.icBtnCamera.svg(),
                      ),
                      spaceW108,
                      const Icon(
                        Icons.help_outline,
                        color: colorWhite,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
