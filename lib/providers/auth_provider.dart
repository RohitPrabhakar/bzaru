import 'package:contacts_service/contacts_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/repository.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthState extends BaseState {
  String _phoneNumber = '';
  String _countryCode = '';
  ProfileModel model;
  Iterable<Contact> _contacts;
  bool isLoading = false;

  ///`Getters`
  String get phoneNumber => _phoneNumber;
  String get countryCode => _countryCode;
  Iterable<Contact> get contacts => _contacts;

  ///`Setters`
  void setPhoneNumberAndCode(String phoneNumber, String code) {
    _phoneNumber = phoneNumber;
    _countryCode = code;
  }

  Future<void> getContacts() async {
    isLoading = true;
    _contacts = await ContactsService.getContacts();
    print("AUTH CONTACTS ${_contacts.length}");
    isLoading = false;
    notifyListeners();
  }

  Future register(
      {ProfileModel data,
      Function(dynamic) onError,
      Function(String) onSucess}) async {
    model = data;
    final repo = getit.get<Repository>();
    await execute(() async {
      return repo.register(model);
    }, label: "Register", onError: onError, onSucess: onSucess);
  }

  Future sendOTP(
      {Future Function(PhoneAuthCredential credential) verificationCompleted,
      Future Function(String verificationId, int resendToken) codeSent,
      Future Function(String verificationId) codeAutoRetrievalTimeout,
      Future Function(FirebaseAuthException e) verificationFailed}) async {
    final repo = getit.get<Repository>();
    await execute(() async {
      return await repo.sendOTP(_countryCode + _phoneNumber,
          verificationCompleted: verificationCompleted,
          codeSent: codeSent,
          codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
          verificationFailed: verificationFailed);
    }, label: "Semd OTP");
  }

  Future<UserCredential> verifyOTP(String verificationId, String smsCode,
      {Function(dynamic) onError, Function(UserCredential) onSucess}) async {
    final repo = getit.get<Repository>();
    final credentail = await execute(() async {
      return await repo.verifyOTP(verificationId, smsCode);
    }, label: "Semd OTP", onError: onError, onSucess: onSucess);

    if (credentail != null && credentail.user != null) {
      print("User id: ${credentail.user.uid}");
      print("User Phone: ${credentail.user.phoneNumber}");
      return credentail;
    } else {
      return credentail;
    }
  }

  Future<ProfileModel> login(UserCredential credential) async {
    final repo = getit.get<Repository>();
    return await execute(() async {
      return await repo.login(credential);
    }, label: "login");
  }

  Future<bool> isUserAvailable(String mobile) async {
    final repo = getit.get<Repository>();
    return await execute(() async {
      return await repo.isUserAvailable(mobile);
    }, label: "isUserAvailable");
  }

  Future<void> addCollectionListener() async {
    final repo = getit.get<BussinessRepository>();
    final merchantId =
        await getit.get<SharedPrefrenceHelper>().getAccessToken();
    print("ADDDINGGGG COLLECTION LISTENER");
    return await execute(() async {
      return await repo.addCollectionListener(merchantId);
    });
  }

  Future<void> removeCollectionListener() async {
    final repo = getit.get<BussinessRepository>();
    final merchantId =
        await getit.get<SharedPrefrenceHelper>().getAccessToken();
    print("DISPOSINGGGGG COLLECTION LISTENER");
    return await execute(() async {
      return await repo.disposeCollectionListener(merchantId);
    });
  }

  Future<void> launchPrivacy() async {
    final url = Constants.privacyTermsLink.isNotEmpty
        ? Constants.privacyTermsLink
        : Constants.webSiteLink;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
