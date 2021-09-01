import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';

const String LANGUAGE_CODE = 'languageCode';
const String ENGLISH = 'en';
const String HINDI = 'hi';

//Add language here

const Map<String, String> languageList = {
  'en': 'English',
  'hi': 'Hindi',
  // Add another language here
};

Future<Locale> setLocale(String languageCode) async {
  await SharedPrefrenceHelper().setLanguageCode(languageCode);
  return _locale(languageCode);
}

Future<String> getStringLocale() async {
  final String languageCode =
      await SharedPrefrenceHelper().getLanguageCode() ?? "en";
  return localeLanguage(languageCode);
}

String localeLanguage(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return ENGLISH;
      break;
    case HINDI:
      return HINDI;
      break;

    //`Add another language here`
    default:
      return ENGLISH;
  }
}

Future<Map> getListLocale() async {
  return languageList;
}

Future<Locale> getLocale() async {
  final String languageCode =
      await SharedPrefrenceHelper().getLanguageCode() ?? "en";
  print(languageCode);
  return _locale(languageCode);
}

Locale _locale(String languageCode) {
  switch (languageCode) {
    case ENGLISH:
      return Locale(ENGLISH);
      break;

    case HINDI:
      return Locale(HINDI);
      break;

    //`Add another language here`
    default:
      return Locale(ENGLISH);
  }
}
