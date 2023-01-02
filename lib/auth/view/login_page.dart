import 'dart:async';

import 'package:appsize/appsize.dart';
import 'package:client/client.dart';
import 'package:data_persistence/data_persistence.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router_flow/go_router_flow.dart';
import 'package:weappear/auth/cubit/auth_cubit.dart';
import 'package:weappear/auth/view/register_page.dart';

import 'package:weappear/onboarding/view/onboarding_page.dart';
import 'package:weappear/utils/validators.dart';
import 'package:weappear_localizations/weappear_localizations.dart';
import 'package:weappear_ui/weappear_ui.dart';

class PageLogin extends StatelessWidget {
  const PageLogin({
    super.key,
    this.registerSuccessful = false,
  });

  static String get name => 'login';

  final bool registerSuccessful;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(
        dataPersistenceRepository: context.read<DataPersistenceRepository>(),
        client: context.read<Client>(),
      ),
      child: ViewLogin(
        registerSuccessful: registerSuccessful,
      ),
    );
  }
}

class ViewLogin extends StatefulWidget {
  const ViewLogin({
    super.key,
    required this.registerSuccessful,
  });

  final bool registerSuccessful;

  @override
  State<ViewLogin> createState() => _ViewLoginState();
}

class _ViewLoginState extends State<ViewLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  Timer _debounce = Timer(Duration.zero, () {});
  late final l10n = context.l10n;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.registerSuccessful) {
        WeAppearSnackbar.success(message: l10n.userRegisteredSuccessfully).show(context);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isSuccess) {
          context.goNamed(PageOnboarding.name);
        } else if (state.isFailure) {
          if (_debounce.isActive) return;
          WeAppearSnackbar.error(message: l10n.invalidCredentials).show(context);
          _debounce = Timer(const Duration(seconds: 3), () {});
        }
      },
      builder: (context, state) {
        return GestureDetector(
          onTap: FocusScope.of(context).unfocus,
          child: Scaffold(
            body: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 34.sp,
              ),
              child: AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: AutofillGroup(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          SizedBox(height: 170.sp),
                          SvgPicture.asset(
                            'assets/icons/weappear_logo.svg',
                            width: 100.sp,
                          ),
                          SizedBox(height: 40.sp),
                          Text(
                            l10n.signIn.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xff303030),
                            ),
                          ),
                          SizedBox(height: 92.sp),
                          WeappearTextFormField(
                            key: const Key('emailInput'),
                            validator: (value) => validateEmail(value, context),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: l10n.email,
                          ),
                          SizedBox(height: 32.sp),
                          WeappearTextFormField(
                            key: const Key('passwordInput'),
                            validator: (value) => validatePassword(value, context),
                            handlePassword: true,
                            controller: _passwordController,
                            keyboardType: TextInputType.emailAddress,
                            hintText: l10n.password,
                            onSaved: submit,
                          ),
                          SizedBox(height: 7.sp),
                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              child: Text(
                                l10n.forgotYourPassword,
                                style: TextStyle(
                                  color: const Color(0xff4285F4),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 77.sp,
                          ),
                          WeappearMaterialButton(
                            key: const Key('loginButton'),
                            onPressed: submit,
                            height: 48.sp,
                            minWidth: 285.sp,
                            isLoading: state.isLoading,
                            title: l10n.signIn.toUpperCase(),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                          ),
                          SizedBox(
                            height: 36.sp,
                          ),
                          Text(
                            l10n.dontHaveAnAccount,
                            style: TextStyle(
                              color: const Color(0xffC9C8C8),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => context.goNamed(PageRegister.name),
                            child: Text(
                              l10n.register.toUpperCase(),
                              style: TextStyle(
                                color: const Color(0xff4285F4),
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void submit([dynamic _]) {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            _emailController.text,
            _passwordController.text,
          );
    }
  }
}

class InputDecorations {
  static InputDecoration authInputDecoration({
    required String hintext,
    IconData? suffixIcon,
  }) {
    return InputDecoration(
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(
          color: Color(0xff4285F4),
        ),
      ),
      hintText: hintext,
      suffixIcon: suffixIcon != null
          ? Icon(
              suffixIcon,
            )
          : null,
    );
  }
}
