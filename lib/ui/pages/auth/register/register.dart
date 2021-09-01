import 'dart:async';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/functions_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/providers.dart';
import 'package:flutter_bzaru/ui/pages/auth/login/widgets/country_code_box.dart';
import 'package:flutter_bzaru/ui/pages/auth/otp/otp_bottom_sheet.dart';
import 'package:flutter_bzaru/ui/pages/auth/validators.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  File profile;
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  ValueNotifier<bool> showLoader = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isChecked = ValueNotifier<bool>(false);

  TextEditingController _emailController;
  TextEditingController _firstNameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _lastNameController;
  TextEditingController _phoneNumberController;
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _connectivitySubscription.cancel();
    _isChecked.dispose();
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
  }

  void sendOTP() async {
    final locale = AppLocalizations.of(context);

    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      final isValid = _formKey.currentState.validate();
      final locale = AppLocalizations.of(context);

      if (!isValid) {
        return;
      }
      _formKey.currentState.save();
      if (isValid) {
        showLoader.value = true;

        /// Hide keyboardType
        FocusManager.instance.primaryFocus.unfocus();
        final state = Provider.of<AuthState>(context, listen: false);
        state.setPhoneNumberAndCode(_phoneNumberController.text, "+91");

        /// Send otp to mobile no
        await state.sendOTP(
          verificationCompleted: (PhoneAuthCredential credential) async {},

          /// Triggered when otp is sent to mobile
          codeSent: (String verificationId, int resendToken) async {
            displayBottomSheet(verificationId);
            showLoader.value = false;
          },
          codeAutoRetrievalTimeout: (String verificationId) async {},
          verificationFailed: (FirebaseAuthException e) async {
            if (e.message != null) {
              Utility.displaySnackbar(context,
                  msg: e.message, key: scaffoldKey);
            } else {
              Utility.displaySnackbar(context,
                  msg: locale.getTranslatedValue(KeyConstants.someErrorOccured),
                  key: scaffoldKey);
            }
            showLoader.value = false;
          },
        );
        showLoader.value = false;
      }
    }
  }

  /// Display bottom sheet
  void displayBottomSheet(String verificationId) {
    ProfileModel model = ProfileModel(
      contactPrimary: "+91" + _phoneNumberController.text,
      role: UserRole.CUSTOMER,
      name: _firstNameController.text + " " + _lastNameController.text,
      email: _emailController.text,
      createdAt: DateTime.now(),
      activityStatus: UserActivityStatus.ACTIVE,
      lastLogin: DateTime.now().toString(),
      accountLoggedOut: false,
    );

    // *Calling OTP SCREEN Here
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => OTPBottomSheet(
        callingFromScreen: "register",
        verificationId: verificationId,
        scaffoldKey: scaffoldKey,
        model: model,
        onResendSMS: () {
          /// Close current bottom sheet
          Navigator.pop(context);

          /// resend otp and bottom sheet will get open automatically again
          sendOTP();
        },
        onVerfied: (credential) async {
          await onOTPVerfied(credential, model);
        },
        onError: (error) {
          Utility.displaySnackbar(context, msg: error, key: scaffoldKey);
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> onOTPVerfied(
      UserCredential credential, ProfileModel model) async {
    final locale = AppLocalizations.of(context);

    /// Save user data in database
    // var model = widget.model;
    final isAlreadyExist = await Provider.of<AuthState>(context, listen: false)
        .isUserAvailable(model.contactPrimary);
    print("ALREADY EXIST? $isAlreadyExist");

    if (isAlreadyExist == null || isAlreadyExist) {
      Navigator.pop(context);
      Utility.displaySnackbar(
        context,
        msg: locale.getTranslatedValue(KeyConstants.mobileAlreadyRegistered),
        key: scaffoldKey,
      );
      return;
    }
    model.id = credential.user.uid;
    final state = Provider.of<AuthState>(context, listen: false);
    String profileUrl;

    /// upload profile to firebase storage
    if (profile != null) {
      profileUrl = await state.uploadFile(profile);
      model.avatar = profileUrl;
      print(profileUrl);
    }

    bool isRegistered = false;

    await state.register(
        data: model,
        onSucess: (val) {
          isRegistered = true;
        },
        onError: (dynamic error) {
          print("ERROR??");
          Utility.displaySnackbar(context,
              msg: error.message, key: scaffoldKey);
          return;
        });

    if (isRegistered) {
      print("Navigate to Home page");
      final bool isInternetAvaliable = await Utility.hasInternetConnection();
      await BFunctionsHelper.initalizeAppTheme(context);

      if (isInternetAvaliable) {
        Navigator.of(context)
            .pushAndRemoveUntil(BottomNavBar.getRoute(), (context) => false);
      } else {
        Navigator.of(context)
            .push(CupertinoPageRoute(builder: (context) => NoInternet()));
      }
    }
  }

  ///Building `Phone Text Field` where the User will `enter`
  Widget _buildPhoneTextField() {
    final locale = AppLocalizations.of(context);
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        border: Border.all(color: KColors.customerPrimaryColor),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CountryCodeBox(
            textStyle: KStyles.hintTextStyle.copyWith(
              height: 1,
              fontSize: 16,
            ),
          ),
          Container(
              height: 70, width: 1.5, color: KColors.customerPrimaryColor),
          Expanded(
            child: Container(
              height: 70,
              child: TextFormField(
                autocorrect: false,
                keyboardType: TextInputType.number,
                controller: _phoneNumberController,
                decoration: InputDecoration(
                  helperText: "",
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                  hintText:
                      locale.getTranslatedValue(KeyConstants.enterPhoneNumber),
                  hintStyle: KStyles.hintTextStyle.copyWith(
                    height: 1,
                    fontSize: 16,
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.done,
                validator: KValidator.buildValidators(context, Labels.phone),
                style: KStyles.fieldTextStyle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: scaffoldKey,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.signUp),
        bgColor: KColors.customerPrimaryColor,
      ),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              vertical: 30,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  UserProfileImage(
                    onFileSelected: (file) {
                      profile = file;
                    },
                  ),
                  SizedBox(height: 30),
                  BTextField(
                    hintText: locale.getTranslatedValue(KeyConstants.firstName),
                    choice: Labels.name,
                    controller: _firstNameController,
                    borderColor: KColors.customerPrimaryColor,
                  ),
                  BTextField(
                    hintText: locale.getTranslatedValue(KeyConstants.lastName),
                    choice: Labels.name,
                    controller: _lastNameController,
                    borderColor: KColors.customerPrimaryColor,
                  ),
                  BTextField(
                    hintText: locale.getTranslatedValue(KeyConstants.email),
                    choice: Labels.email,
                    controller: _emailController,
                    borderColor: KColors.customerPrimaryColor,
                  ),
                  _buildPhoneTextField(),
                  SizedBox(height: 20),
                  _buildPrivaryDocument(),
                  SizedBox(height: 20),
                  ValueListenableBuilder<bool>(
                      valueListenable: _isChecked,
                      builder: (context, isChecked, _) {
                        return BFlatButton(
                          text: locale.getTranslatedValue(KeyConstants.submit),
                          color: isChecked
                              ? KColors.customerPrimaryColor
                              : KColors.disableButtonColor,
                          isWraped: true,
                          isBold: true,
                          onPressed: isChecked ? sendOTP : null,
                        );
                      }),
                ],
              ),
            ),
          ).pH(30),
          OverlayLoading(showLoader: showLoader)
        ],
      ),
    );
  }

  _buildPrivaryDocument() {
    final locale = AppLocalizations.of(context);

    return Container(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ValueListenableBuilder<bool>(
              valueListenable: _isChecked,
              builder: (context, isChecked, _) {
                return Checkbox(
                  value: isChecked,
                  onChanged: (value) {
                    _isChecked.value = value;
                  },
                  activeColor: KColors.customerPrimaryColor,
                ).ripple(() {
                  _isChecked.value = !_isChecked.value;
                });
              }),
          SizedBox(width: 5),
          BText(
            locale.getTranslatedValue(KeyConstants.viewPrivacy),
            variant: TypographyVariant.h2,
            style: TextStyle(color: KColors.customerPrimaryColor),
          ).ripple(() {
            launcPrivacy();
          }),
        ],
      ),
    );
  }

  Future<void> launcPrivacy() async {
    final state = Provider.of<AuthState>(context, listen: false);
    try {
      await state.launchPrivacy();
    } catch (e) {
      scaffoldKey.currentState
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
