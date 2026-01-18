import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  // Environment variables - loaded from .env file
  static String get apiBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get kGoogleApiKey => dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '';
  static String get appLink => dotenv.env['APP_LINK'] ?? 'https://bzaru.com/';
  static String get privacyTermsLink => dotenv.env['PRIVACY_TERMS_LINK'] ?? '';

  // Firebase collection names (not sensitive)
  static const userCollecrion = "users";
  static const customerCollection = "customer";
  static const merchantCollection = "merchant";
  static const orderCollection = "order";
  static const merchantProductCollection = "merchantProduct";
  static const merchantTimingsCollection = "merchantTimings";
  static const productCollection = "products";
  static const messagesCollection = "message";
  static const messagesUsersCollection = "message-Users";
  static const notificationsCollection = "notifications";
  static const mainCategoryCollection = "main-category";
  static const subCategoryCollection = "sub-category";
  static const helpCenterCollection = "help-center";
  static const customerAddressCollection = "customer-address";
  static const articlesCollection = "articles";
  static const adsCollection = "banner-ads";
  static const orderDateDocument = "order-date";
  static const termsConditionCollection = "terms-condition";
  static const orderMasterCollection = "order-master";
  static const orderSubCollection = "order-sub";
  static const productMasterCollection = "product-master";

  // Static website link (public)
  static const webSiteLink = "https://bzaru.com/";
}
