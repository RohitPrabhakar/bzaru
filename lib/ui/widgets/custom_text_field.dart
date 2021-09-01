import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/pages/auth/validators.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';

enum Labels {
  name,
  email,
  phone,
  password,
  confirmPassword,
  reset,
  text,
  optionalText,
  pin,
  address
}

class BTextField extends StatelessWidget {
  const BTextField({
    Key key,
    @required this.choice,
    this.controller,
    this.label,
    this.maxLines = 1,
    this.hintText = '',
    this.textInputAction,
    this.isEnabled = true,
    this.contentPadding =
        const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
    this.maxLengthEnforced = false,
    this.borderColor,
    this.validations,
  }) : super(key: key);

  final TextEditingController controller;
  final String label, hintText;
  final Labels choice;
  final int maxLines;
  final TextInputAction textInputAction;
  final bool isEnabled;
  final EdgeInsetsGeometry contentPadding;
  final Color borderColor;
  final bool maxLengthEnforced;
  final Function(String) validations;

  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        label == null
            ? SizedBox()
            : Text(
                label ?? "",
                style: KStyles.labelTextStyle,
              ),
        SizedBox(height: label == null ? 5 : 10),
        Container(
          height: maxLines > 1 ? 100 : 70,
          child: TextFormField(
            autocorrect: false,
            enabled: isEnabled,
            maxLengthEnforced: maxLengthEnforced,
            maxLength: maxLengthEnforced ? 120 : null,
            obscureText:
                (choice == Labels.password || choice == Labels.confirmPassword)
                    ? true
                    : false,
            maxLines: maxLines,
            keyboardType: getKeyboardType(choice),
            controller: controller ?? TextEditingController(),
            decoration: getInputDecotration(context, hintText: hintText),
            textInputAction: textInputAction ?? TextInputAction.next,
            validator: validations ?? validators(choice, context),
            style: KStyles.fieldTextStyle,
          ),
        ),
      ],
    );
  }

  InputDecoration getInputDecotration(context, {String hintText}) {
    return InputDecoration(
      helperText: "",
      hintText: hintText,
      filled: true,
      fillColor: isEnabled ? Colors.white : KColors.disableInputColor,
      hintStyle: KStyles.hintTextStyle,
      contentPadding: contentPadding,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color: borderColor ?? Theme.of(context).primaryColor,
        ),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color: borderColor ?? Theme.of(context).primaryColor,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          width: 1.5,
          color: borderColor ?? Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  TextInputType getKeyboardType(Labels choice) {
    switch (choice) {
      case Labels.name:
        return TextInputType.text;
      case Labels.email:
        return TextInputType.emailAddress;
      case Labels.password:
        return null;
      case Labels.confirmPassword:
        return null;
      case Labels.phone:
        return TextInputType.phone;
      case Labels.reset:
        return TextInputType.emailAddress;
      case Labels.address:
        return TextInputType.streetAddress;
      default:
        return TextInputType.text;
    }
  }

  Function(String) validators(Labels choice, BuildContext context) {
    switch (choice) {
      case Labels.name:
        return KValidator.buildValidators(context, choice);
      case Labels.email:
        return KValidator.buildValidators(context, choice);
      case Labels.password:
        return KValidator.buildValidators(context, choice);
      case Labels.phone:
        return KValidator.buildValidators(context, choice);
      case Labels.confirmPassword:
        return KValidator.buildValidators(context, choice);
      case Labels.reset:
        return KValidator.buildValidators(context, choice);
      case Labels.text:
        return KValidator.buildValidators(context, choice);
      case Labels.pin:
        return KValidator.buildValidators(context, choice);
      case Labels.address:
        return KValidator.buildValidators(context, choice);
      default:
        return KValidator.buildValidators(context, choice);
    }
  }
}
