import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/functions_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/ui/pages/auth/login/widgets/country_code_box.dart';
import 'package:flutter_bzaru/ui/pages/auth/otp/otp_bottom_sheet.dart';
import 'package:flutter_bzaru/ui/pages/auth/validators.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class LoginBottomSheet extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const LoginBottomSheet({Key key, this.scaffoldKey}) : super(key: key);
  @override
  _LoginBottomSheetState createState() => _LoginBottomSheetState();
}

class _LoginBottomSheetState extends State<LoginBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  TextEditingController _phoneNumberController;

  @override
  void dispose() {
    super.dispose();
    _phoneNumberController.clear();
    _phoneNumberController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _phoneNumberController = TextEditingController();
  }

  void sendOTP() async {
    final locale = AppLocalizations.of(context);
    final isValid = _formKey.currentState.validate();

    if (!isValid) {
      return;
    }
    loading.value = true;
    _formKey.currentState.save();
    if (isValid) {
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
          loading.value = false;
        },
        codeAutoRetrievalTimeout: (String verificationId) async {},
        verificationFailed: (FirebaseAuthException e) async {
          Navigator.of(context).pop();

          if (e.message != null) {
            Utility.displaySnackbar(context,
                msg: e.message, key: widget.scaffoldKey);
          } else {
            Utility.displaySnackbar(
              context,
              msg: locale.getTranslatedValue(KeyConstants.someErrorOccured),
              key: widget.scaffoldKey,
            );
          }
          loading.value = false;
        },
      );
    }
  }

  void displayBottomSheet(String verificationId) {
    ProfileModel model = ProfileModel(
      contactPrimary: "+91" + _phoneNumberController.text,
    );

    // *Calling OTP SCREEN Here
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      builder: (context) => OTPBottomSheet(
        callingFromScreen: "login",
        verificationId: verificationId,
        model: model,
        onResendSMS: () {
          /// Close current bottom sheet
          Navigator.pop(context);

          /// resend otp and bottom sheet will get open automatically again
          sendOTP();
        },
        onVerfied: onVerfied,
        onError: (error) {
          Navigator.pop(context);
          Utility.displaySnackbar(context, msg: error, key: widget.scaffoldKey);
        },
      ),
      isScrollControlled: true,
    );
  }

  Future<void> onVerfied(UserCredential credential) async {
    final locale = AppLocalizations.of(context);
    final model =
        await Provider.of<AuthState>(context, listen: false).login(credential);
    if (model == null) {
      Utility.displaySnackbar(context,
          msg: locale.getTranslatedValue(KeyConstants.mobileNotRegistered),
          key: widget.scaffoldKey);
      Navigator.pop(context);
      Navigator.pop(context);
      return;
    } else {
      print("Navigate to Home page");

      await BFunctionsHelper.initalizeAppTheme(context);

      if (model.accountLoggedOut != null && model.accountLoggedOut) {
        Navigator.pop(context);
        Navigator.pop(context);
        Utility.displaySnackbar(context,
            msg: locale.getTranslatedValue(KeyConstants.accountLocked),
            key: widget.scaffoldKey);
      } else {
        Navigator.of(context)
            .pushAndRemoveUntil(BottomNavBar.getRoute(), (_) => false);
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
          CountryCodeBox(),
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
                    letterSpacing: 1.2,
                    fontSize: 18,
                  ),
                  border: InputBorder.none,
                ),
                textInputAction: TextInputAction.done,
                validator: KValidator.buildValidators(context, Labels.phone),
                style: KStyles.hintTextStyle.copyWith(
                  height: 1,
                  letterSpacing: 1.2,
                  fontSize: 18,
                ),
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
    return SingleChildScrollView(
      // padding: EdgeInsets.only(
      //   // bottom: MediaQuery.of(context).viewInsets.bottom,
      // ),
      child: Form(
        key: _formKey,
        child: Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 50),
                _buildPhoneTextField(),
                SizedBox(height: 30),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: KColors.customerPrimaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: loading,
                    builder: (BuildContext context, bool value, Widget child) {
                      if (value) {
                        return CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        );
                      }
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(Icons.phone, size: 26, color: Colors.white),
                          BText(
                            locale.getTranslatedValue(
                                KeyConstants.loginWithPhone),
                            variant: TypographyVariant.button,
                            style: TextStyle(fontSize: 20),
                          ),
                          SizedBox(width: 10),
                        ],
                      );
                    },
                  ),
                ).ripple(() async {
                  sendOTP(); // *SAVING THE FORM HERE
                }),
                SizedBox(height: 50),
              ],
            ).pH(30),
          ),
        ),
      ),
    );
  }
}
