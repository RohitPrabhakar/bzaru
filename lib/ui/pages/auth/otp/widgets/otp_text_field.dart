import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/ui/pages/auth/validators.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';

class OTPTextField extends StatefulWidget {
  const OTPTextField({
    Key key,
    this.onSubmitted,
    this.clearOTP,
    this.otp1 = "",
    this.otp2 = "",
    this.otp3 = "",
    this.otp4 = "",
    this.otp5 = "",
    this.otp6 = "",
  }) : super(key: key);

  final String otp1;
  final String otp2;
  final String otp3;
  final String otp4;
  final String otp5;
  final String otp6;
  final bool clearOTP;
  final ValueChanged<String> onSubmitted;

  @override
  _OTPTextFieldState createState() => _OTPTextFieldState();
}

class _OTPTextFieldState extends State<OTPTextField> {
  FocusNode otp1FocusNode;
  FocusNode otp2FocusNode;
  FocusNode otp3FocusNode;
  FocusNode otp4FocusNode;
  FocusNode otp5FocusNode;
  FocusNode otp6FocusNode;

  TextEditingController _otp1;
  TextEditingController _otp2;
  TextEditingController _otp3;
  TextEditingController _otp4;
  TextEditingController _otp5;
  TextEditingController _otp6;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.clearOTP) {
      clearTextFields();
    }
  }

  @override
  void dispose() {
    _otp1.dispose();
    _otp2.dispose();
    _otp3.dispose();
    _otp4.dispose();
    _otp5.dispose();
    _otp6.dispose();

    otp1FocusNode.dispose();
    otp2FocusNode.dispose();
    otp3FocusNode.dispose();
    otp4FocusNode.dispose();
    otp5FocusNode.dispose();
    otp6FocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _otp1 = TextEditingController(text: widget.otp1);
    _otp2 = TextEditingController(text: widget.otp2);
    _otp3 = TextEditingController(text: widget.otp3);
    _otp4 = TextEditingController(text: widget.otp4);
    _otp5 = TextEditingController(text: widget.otp5);
    _otp6 = TextEditingController(text: widget.otp6);

    if (widget.clearOTP) {
      clearTextFields(); // !PLEASE CHECK THIS ONE >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
    }

    otp1FocusNode = FocusNode();
    otp2FocusNode = FocusNode();
    otp3FocusNode = FocusNode();
    otp4FocusNode = FocusNode();
    otp5FocusNode = FocusNode();
    otp6FocusNode = FocusNode();
  }

  void clearTextFields() {
    _otp1.clear();
    _otp2.clear();
    _otp3.clear();
    _otp4.clear();
    _otp5.clear();
    _otp6.clear();
  }

  ///Changing Focus to next `OTP`
  void changeFocus(String value, FocusNode focusNode) {
    if (value.length == 1) {
      focusNode.requestFocus();
    }
    if (value.length == 0) {
      FocusScope.of(context).previousFocus();
    }
  }

  void saveForm() {
    final String otp = _otp1.text +
        _otp2.text +
        _otp3.text +
        _otp4.text +
        _otp5.text +
        _otp6.text;

    print("HERERERER OPT is $otp");
    widget.onSubmitted(otp);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomOTPTextField(
            controller: _otp1,
            focusNode: otp1FocusNode,
            onChanged: (value) {
              if (value.length == 0) {
                return;
              }
              changeFocus(value, otp2FocusNode);
            },
          ),
          SizedBox(width: 10.0),
          CustomOTPTextField(
            controller: _otp2,
            focusNode: otp2FocusNode,
            onChanged: (value) {
              changeFocus(value, otp3FocusNode);
            },
          ),
          SizedBox(width: 10.0),
          CustomOTPTextField(
            controller: _otp3,
            focusNode: otp3FocusNode,
            onChanged: (value) {
              changeFocus(value, otp4FocusNode);
            },
          ),
          SizedBox(width: 10.0),
          CustomOTPTextField(
            controller: _otp4,
            focusNode: otp4FocusNode,
            onChanged: (value) {
              changeFocus(value, otp5FocusNode);
            },
          ),
          SizedBox(width: 10.0),
          CustomOTPTextField(
            controller: _otp5,
            focusNode: otp5FocusNode,
            onChanged: (value) {
              changeFocus(value, otp6FocusNode);
            },
          ),
          SizedBox(width: 10.0),
          CustomOTPTextField(
            controller: _otp6,
            focusNode: otp6FocusNode,
            textInputAction: TextInputAction.done,
            onChanged: (value) {
              if (value.length == 1) {
                otp6FocusNode.unfocus();
                saveForm();
              }
              if (value.length == 0) {
                FocusScope.of(context).previousFocus();
              }
            },
          ),
        ],
      ),
    );
  }
}

class CustomOTPTextField extends StatelessWidget {
  const CustomOTPTextField({
    Key key,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.textInputAction,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50.0,
      width: 20.0,
      child: TextFormField(
        controller: controller ?? TextEditingController(),

        textAlign: TextAlign.center,
        // cursorHeight: 30,   //! Not available with version 1.17.5
        keyboardType: TextInputType.phone,
        textInputAction: textInputAction ?? TextInputAction.next,
        style: KStyles.otp,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
        ],
        validator: KValidator.otpValidators,

        decoration: InputDecoration(
          helperText: '',
        ),
        focusNode: focusNode,
        onChanged: onChanged,
      ),
    );
  }
}
