import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text_field.dart';

class KValidator {
  static Function(String) buildValidators(BuildContext context, Labels choice) {
    final locale = AppLocalizations.of(context);

    Function(String) emailValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(value)) {
        return locale.getTranslatedValue(KeyConstants.invalidEmail);
      }

      if (!value.startsWith(RegExp(r'[A-Za-z]'))) {
        return locale.getTranslatedValue(KeyConstants.invalidEmail);
      }
      if (value.length > 32) {
        return locale.getTranslatedValue(KeyConstants.emailMustBeLessThan);
      }
      if (value.length < 6) {
        return locale.getTranslatedValue(KeyConstants.emailIsShort);
      }
      return null;
    };

    Function(String) nameValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      if (value.length > 32) {
        return locale.getTranslatedValue(KeyConstants.nameMustBeLessThan);
      }
      if (!value.startsWith(RegExp(r'[A-za-z]'))) {
        return locale.getTranslatedValue(KeyConstants.invalidName);
      }
      if (value.length < 3) {
        return locale.getTranslatedValue(KeyConstants.nameShouldBeAtleast);
      }
      if (value.contains(RegExp(r'[0-9]'))) {
        return locale.getTranslatedValue(KeyConstants.invalidName);
      }
      if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%0-9-]').hasMatch(value)) {
        return locale.getTranslatedValue(KeyConstants.invalidName);
      }
      return null;
    };

    Function(String) phoneValidtors = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      if (value.length < 10) {
        return locale.getTranslatedValue(KeyConstants.phoneNumberMustBeLess);
      }
      if (value.contains(RegExp(r'[A-Z]')) ||
          value.contains(RegExp(r'[a-z]')) ||
          value.contains(".com")) {
        return locale.getTranslatedValue(KeyConstants.onlyTenDigits);
      }
      if (value.length > 10) {
        return locale.getTranslatedValue(KeyConstants.invalidPhoneNumber);
      }
      if (!RegExp(r"[0-9]{10}").hasMatch(value)) {
        return locale.getTranslatedValue(KeyConstants.invalidPhoneNumber);
      }
      if (!value.startsWith(RegExp(r"[0-9]"))) {
        return locale.getTranslatedValue(KeyConstants.invalidPhoneNumber);
      }
      return null;
    };

    Function(String) passwordValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      // else if (value.length < 8) {
      //   return locale.getTranslatedValue(KeyConstants.passwordLessThan);
      // }

      return null;
    };

    Function(String) confirmPasswordValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      } else if (value.length < 8) {
        return locale.getTranslatedValue(KeyConstants.passwordLessThan);
      }

      return null;
    };
    Function(String) textValidator = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }

      return null;
    };

    Function(String) addressValidator = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      if (value.length > 46) {
        return locale.getTranslatedValue(KeyConstants.textCantBeMore);
      }

      return null;
    };
    Function(String) forgotPasswordValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      //For Number
      if (value.startsWith(RegExp(r"[0-9]"))) {
        if (!RegExp(r"^[0-9]{10}").hasMatch(value)) {
          return locale.getTranslatedValue(KeyConstants.invalidPhoneNumber);
        }
        if (value.length < 10) {
          return locale.getTranslatedValue(KeyConstants.phoneNumberMustBeLess);
        }
        if (value.length > 10) {
          return locale.getTranslatedValue(KeyConstants.invalidPhoneNumber);
        }

        if (value.contains(RegExp(r'[A-Z]')) ||
            value.contains(RegExp(r'[a-z]')) ||
            value.contains(".com")) {
          return locale.getTranslatedValue(KeyConstants.onlyTenDigits);
        }

        return null;
      }

      //for email
      if (!value.startsWith(RegExp(r'[A-Z][a-z]'))) {
        if (!RegExp(
                r"^([a-zA-Z0-9_\-\.]+)@([a-zA-Z0-9_\-\.]+)\.([a-zA-Z]{2,5})$")
            .hasMatch(value)) {
          return locale.getTranslatedValue(KeyConstants.invalidEmail);
        }
        if (value.length > 32) {
          return locale.getTranslatedValue(KeyConstants.emailMustBeLessThan);
        }
        if (value.length < 6) {
          return locale.getTranslatedValue(KeyConstants.emailIsShort);
        }
        // if (!value.contains("@")) {
        //   return locale.getTranslatedValue(KeyConstants.invalidEmail);
        // }
        // if (!value.contains(".com")) {
        //   return locale.getTranslatedValue(KeyConstants.invalidEmail);
        // }

        return null;
      }

      return null;
    };
    Function(String) pinValidators = (String value) {
      if (value.isEmpty) {
        return locale.getTranslatedValue(KeyConstants.fieldEmptyText);
      }
      if (value.length < 6) {
        return locale.getTranslatedValue(KeyConstants.enterValidPinCode);
      }
      if (value.contains(RegExp(r'[A-Z]')) ||
          value.contains(RegExp(r'[a-z]')) ||
          value.contains(".com")) {
        return locale.getTranslatedValue(KeyConstants.enterValidPinCode);
      }
      if (value.length > 6) {
        return locale.getTranslatedValue(KeyConstants.enterValidPinCode);
      }
      if (!RegExp(r"[0-9]{6}").hasMatch(value)) {
        return locale.getTranslatedValue(KeyConstants.enterValidPinCode);
      }
      if (!value.startsWith(RegExp(r"[0-9]"))) {
        return locale.getTranslatedValue(KeyConstants.enterValidPinCode);
      }
      return null;
    };

    if (choice == Labels.name) return nameValidators;
    if (choice == Labels.email) return emailValidators;
    if (choice == Labels.password) return passwordValidators;
    if (choice == Labels.phone) return phoneValidtors;
    if (choice == Labels.confirmPassword) return confirmPasswordValidators;
    if (choice == Labels.reset) return forgotPasswordValidators;
    if (choice == Labels.text) return textValidator;
    if (choice == Labels.pin) return pinValidators;
    if (choice == Labels.address) return addressValidator;

    return nameValidators;
  }

  static Function(String) otpValidators = (String value) {
    if (value.isEmpty) {
      return "";
    }
  };
}
