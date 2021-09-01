import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/terms_condition_model.dart';

class AuthService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  AuthService({this.auth, this.firestore});

  Future<String> register(ProfileModel model) async {
    CollectionReference users = firestore.collection(model.role.asString());
    CollectionReference termsRef =
        firestore.collection(Constants.termsConditionCollection);

    try {
      final TermsConditionModel termsModel = TermsConditionModel(
        userName: model.name,
        email: model.email,
        phoneNumber: model.contactPrimary,
        acceptDate: DateTime.now().toString(),
        termsAndCondition: Constants.privacyTermsLink, //TODO: MAYBE CHANGE
      );

      await users.doc(model.id).set(model.toJson()).then((value) async {
        print("USER ADDED");
        await termsRef
            .doc(model.id)
            .set(termsModel.toJson())
            .then((value) => print("Terms Added"))
            .catchError((error) => print("Failed to add terms: $error"));
      }).catchError((error) {
        print("Failed to add user: $error");
        return;
      });

      return "User update";
    } catch (e) {
      throw e;
    }
  }

  Future<PhoneAuthCredential> sendOTP(String contact,
      {Future Function(PhoneAuthCredential credential) verificationCompleted,
      Future Function(String verificationId, int resendToken) codeSent,
      Future Function(String verificationId) codeAutoRetrievalTimeout,
      Future Function(FirebaseAuthException e) verificationFailed}) async {
    assert(contact != null && contact.length > 10);
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: contact,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print("Verification Completed");
          if (verificationCompleted != null)
            await verificationCompleted(credential);
          return credential;
        },
        verificationFailed: (FirebaseAuthException e) {
          print("Verification Failed");
          if (verificationFailed != null) {
            verificationFailed(e);
          }
        },
        codeSent: (String verificationId, int resendToken) async {
          print("Code sent | Verfication id: $verificationId");
          if (codeSent != null) await codeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) async {
          print("Auto retrival time out");
          if (codeAutoRetrievalTimeout != null)
            await codeAutoRetrievalTimeout(verificationId);
        },
      );
    } catch (e) {
      throw e;
    }
  }

  Future<UserCredential> verifyOTP(
      String verificationId, String smsCode) async {
    var _credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return auth.signInWithCredential(_credential).then(
        (UserCredential result) async {
      print("UserIs result ${result.user.uid} ");
      return result;
    }, onError: (error) {
      throw error;
    });
  }

  Future<ProfileModel> getUserProfile(String id) async {
    assert(id != null);
    final collection = UserRole.CUSTOMER.asString();
    return firestore
        .collection(collection)
        .where("id", isEqualTo: id)
        .get()
        .then((QuerySnapshot documentSnapshot) {
      if (documentSnapshot.docs != null && documentSnapshot.docs.isNotEmpty) {
        print('User exists on the database');
        ProfileModel model =
            ProfileModel.fromJson(documentSnapshot.docs.first.data());
        print('User name ${model.name}');
        return model;
      } else {
        throw Exception("User is not exist");
      }
    }, onError: (error) {
      throw error;
    });
  }

  Future<bool> isUserAvailable(String mobile) async {
    assert(mobile != null);
    final collection = UserRole.CUSTOMER.asString();
    return firestore
        .collection(collection)
        .where("contactPrimary", isEqualTo: mobile)
        .get()
        .then((QuerySnapshot documentSnapshot) {
      if (documentSnapshot.docs != null && documentSnapshot.docs.isNotEmpty) {
        print('User exists on the database');
        ProfileModel model =
            ProfileModel.fromJson(documentSnapshot.docs.first.data());
        print('User name ${model.name}');
        return true;
      } else {
        return false;
      }
    }, onError: (error) {
      throw error;
    });
  }
}
