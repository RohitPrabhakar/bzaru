import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/auth_provider.dart';
import 'package:flutter_bzaru/ui/pages/auth/login/login_bottom_sheet.dart';
import 'package:flutter_bzaru/ui/pages/auth/otp/widgets/otp_text_field.dart';
import 'package:flutter_bzaru/ui/pages/auth/otp/widgets/resend_text_counter.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class OTPBottomSheet extends StatefulWidget {
  ///`callingFromScreen` determines how to handle `OTP Bottom Sheet`
  ///It is a required field.
  final String callingFromScreen;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final Function onResendSMS;
  final String verificationId;
  final ProfileModel model;
  final Future Function(UserCredential) onVerfied;
  final Function(String) onError;
  const OTPBottomSheet(
      {Key key,
      @required this.callingFromScreen,
      this.scaffoldKey,
      this.onResendSMS,
      this.verificationId,
      this.model,
      this.onVerfied,
      this.onError})
      : assert(callingFromScreen != null),
        super(key: key);

  @override
  _OTPBottomSheetState createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ValueNotifier<bool> clearOTP = ValueNotifier<bool>(false);
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);
  TextEditingController _otpController;
  String otp = "";

  @override
  void dispose() {
    super.dispose();
    _otpController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _otpController = TextEditingController();
  }

  ///Building `Phone number` text
  Widget _buildPhoneNumber() {
    final locale = AppLocalizations.of(context);
    return Consumer<AuthState>(
      builder: (context, authProvider, child) {
        final phone =
            authProvider.phoneNumber.isEmpty ? "N.A" : authProvider.phoneNumber;
        final code =
            authProvider.countryCode.isEmpty ? "N.A" : authProvider.countryCode;
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            RichText(
              text: TextSpan(
                text: "$code $phone",
                style: KStyles.h2.copyWith(
                  letterSpacing: 1.2,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                text: locale.getTranslatedValue(KeyConstants.wrongNumber),
                style: KStyles.h2.copyWith(
                  color: KColors.businessDarkColor,
                  letterSpacing: 1.2,
                ),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    if (widget.callingFromScreen == "register") {
                      Navigator.of(context).pop();
                      print("REGISTER");
                    } else {
                      //!Show Login Bottom Sheet
                      print("LOGIN");

                      Navigator.of(context).pop();
                      showModalBottomSheet(
                        context: context,
                        builder: (context) => LoginBottomSheet(),
                      );
                    }
                  },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    final locale = AppLocalizations.of(context);

    return BFlatButton2(
      text: locale.getTranslatedValue(KeyConstants.verify),
      isWraped: true,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      onPressed: verifyOTP,
      isLoading: isLoading,
      isBold: true,
    );
  }

  ///Building `Resend SMS` & `Time Row`
  Widget _buildResendRow() {
    return ResendTextCounter(
      onResetTimer: (value) {
        if (value) {
          clearOTP.value = true;
          widget.onResendSMS();
        }
      },
    ).pH(30);
  }

  Future<void> verifyOTP() async {
    final valid = _formKey.currentState.validate();
    // widget.onVerificationComplete(valid);
    if (valid) {
      isLoading.value = true;
      final credential = await Provider.of<AuthState>(context, listen: false)
          .verifyOTP(widget.verificationId, otp, onError: (dynamic error) {
        widget.onError(error.message);

        isLoading.value = false;
        return null;
      }, onSucess: (val) {
        print("OTP Verified");
        return val;
      });
      if (credential == null) {
        Navigator.pop(context);
        return;
      }
      await widget.onVerfied(credential);
    }
    isLoading.value = false;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return SingleChildScrollView(
      // padding: EdgeInsets.only(
      //   bottom: MediaQuery.of(context).viewInsets.bottom,
      // ),
      child: Form(
        key: _formKey,
        child: Container(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              // border: Border.all(
              //   color: KColors.customerPrimaryColor,
              //   width: 1.5,
              // ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 30),
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      child: BText(
                        locale.getTranslatedValue(KeyConstants.enterOTP),
                        variant: TypographyVariant.headerSmall,
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 23,
                          color: KColors.businessPrimaryColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildPhoneNumber(),
                  ],
                ).pH(30),
                SizedBox(height: 30),
                ValueListenableBuilder(
                  valueListenable: clearOTP,
                  builder: (context, clearOTPbool, child) => OTPTextField(
                    onSubmitted: (value) {
                      print(value);
                      otp = value;
                    },
                    clearOTP: clearOTPbool,
                  ),
                ),
                Text(locale.getTranslatedValue(KeyConstants.enter6digitOTP),
                    style:
                        KStyles.h1.copyWith(color: Colors.grey, fontSize: 14)),
                SizedBox(height: 10),
                _buildSubmitButton(),
                SizedBox(height: 30),
                _buildResendRow(),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
