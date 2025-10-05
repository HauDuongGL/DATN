import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:verify_clone/core/base/base_logo_scafold.dart';
import 'package:verify_clone/core/config/resources/color.dart';
import 'package:verify_clone/core/config/resources/dimens.dart';
import 'package:verify_clone/core/config/resources/language.dart';
import 'package:verify_clone/core/config/resources/styles.dart';
import 'package:verify_clone/core/config/router/router_name.dart';
import 'package:verify_clone/data/services/database_helper.dart';
import 'package:verify_clone/gen/translations.g.dart';
import 'package:verify_clone/presentation/sign_in_page/riverpod/enum/enum.dart';
import 'package:verify_clone/presentation/sign_in_page/riverpod/login_riverpod.dart';
import 'package:verify_clone/presentation/widgets/button/app_button.dart';
import 'package:verify_clone/presentation/widgets/textField/text_from_field_common.dart';
import 'package:verify_clone/presentation/widgets/toggle_switch/toggle_switch_common.dart';
import 'package:verify_clone/utils/style_utils.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscureText = true;
  bool isVisible = false;
  bool isLoginTrue = false;
  String? errorMsg;

  final db = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.listenManual<AsyncValue<LoginResult?>>(
        loginRiverpod,
        (prev, next) {
          if (next is AsyncData && next.value == LoginResult.success) {
            context.goNamed(RoutesName.home.name);
          }
        },
      );
    });
  }

  Future<void> onLoginPressed() async {
    final result = await ref.read(loginRiverpod.notifier).login(
          emailController.text,
          passwordController.text,
        );
    return result;
  }

  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginRiverpod);
    final loginResult = loginState.valueOrNull;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => FocusScope.of(context).unfocus(),
      child: AppLogoScaffold(
        toggleSwitch: ToggleSwitchCommon(
          labels: [
            LocaleKeys.app_bar_eng.tr(),
            LocaleKeys.app_bar_swa.tr(),
          ],
          onToggle: (index) {
            if (index == 0) {
              context.setLocale(AppLanguages.en);
            } else {
              context.setLocale(AppLanguages.sw);
            }
            setState(() {});
          },
          borderSideColor: colorStroke,
          width: Dimens.d104.w,
          height: Dimens.d34.h,
          fontSize: Dimens.d14.sp,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimens.d18.w),
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            LocaleKeys.login_page_title.tr(),
                            style: AppTextStyle.interBoldText.copyWith(
                              fontSize: Dimens.d24.sp,
                            ),
                          ),
                          spaceH16,
                          Text(
                            LocaleKeys.login_page_title_email.tr(),
                            style: AppTextStyle.interBoldText.copyWith(
                              fontSize: Dimens.d16.sp,
                            ),
                          ),
                          spaceH8,
                          TextFormFieldCommon(
                            controller: emailController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return LocaleKeys.login_page_email_required
                                    .tr();
                              }
                              if (loginResult == LoginResult.userNotFound) {
                                return LoginResult.userNotFound.name;
                              }
                              return null;
                            },
                            hintText: LocaleKeys.login_page_email.tr(),
                            hintStyle: AppTextStyle.interText.copyWith(
                              color: colorStroke,
                              fontSize: Dimens.d16.sp,
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.d33.r),
                            ),
                            prefixIcon: const Icon(
                              CupertinoIcons.envelope,
                              color: colorStroke,
                            ),
                          ),
                          spaceH16,
                          Text(
                            LocaleKeys.login_page_title_password.tr(),
                            style: AppTextStyle.interBoldText.copyWith(
                              fontSize: Dimens.d16.sp,
                            ),
                          ),
                          spaceH8,
                          TextFormFieldCommon(
                            controller: passwordController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return LocaleKeys.login_page_password_required
                                    .tr();
                              }
                              if (loginResult == LoginResult.wrongPassword) {
                                return LoginResult.wrongPassword.name;
                              }
                              return null;
                            },
                            hintText: LocaleKeys.login_page_password.tr(),
                            hintStyle: AppTextStyle.interText.copyWith(
                              color: colorStroke,
                              fontSize: Dimens.d16.sp,
                            ),
                            isPassword: obscureText,
                            borderRadius: BorderRadius.all(
                              Radius.circular(Dimens.d33.r),
                            ),
                            prefixIcon: const Icon(
                              CupertinoIcons.lock,
                              color: colorStroke,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                obscureText
                                    ? CupertinoIcons.eye
                                    : CupertinoIcons.eye_slash,
                                color: colorStroke,
                              ),
                              onPressed: () {
                                setState(() => obscureText = !obscureText);
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {},
                                child: Text(
                                  LocaleKeys.login_page_forgot_password.tr(),
                                  style: AppTextStyle.interBoldText.copyWith(
                                    color: colorBlue,
                                    fontSize: Dimens.d14.sp,
                                  ),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.d18.w,
              vertical: Dimens.d12.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  padding: EdgeInsets.symmetric(vertical: Dimens.d14.h),
                  width: double.infinity,
                  title: LocaleKeys.login_page_log_in.tr(),
                  style: AppTextStyle.interBoldText.copyWith(color: colorWhite),
                  color: colorBlue,
                  borderRadius: Dimens.d33.r,
                  onTap: () async {
                    FocusScope.of(context).unfocus();
                    final email = emailController.text.trim();
                    final password = passwordController.text;

                    if (email.isEmpty || password.isEmpty) {
                      formKey.currentState!.validate();
                      return;
                    }

                    await onLoginPressed();
                    formKey.currentState!.validate();
                  },
                ),
                spaceH24,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(LocaleKeys.login_page_confirm_sign_up.tr()),
                    spaceW5,
                    GestureDetector(
                      onTap: () {},
                      child: Text(
                        LocaleKeys.login_page_sign_up.tr(),
                        style:
                            AppTextStyle.interText.copyWith(color: colorBlue),
                      ),
                    )
                  ],
                ),
                spaceH31,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
