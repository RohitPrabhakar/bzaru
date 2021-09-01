import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/resource/services/api_gateway.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';

class Repository {
  final ApiGateway apiGatway;
  final SessionService session;
  Repository(this.apiGatway, this.session);

  Future<String> register(ProfileModel model) async {
    final data = await apiGatway.register(model);
    session.saveSession(model);
    return data;
  }

  Future<PhoneAuthCredential> sendOTP(String contact,
      {Future Function(PhoneAuthCredential credential) verificationCompleted,
      Future Function(String verificationId, int resendToken) codeSent,
      Future Function(String verificationId) codeAutoRetrievalTimeout,
      Future Function(FirebaseAuthException e) verificationFailed}) async {
    return await apiGatway.sendOTP(
      contact,
      verificationCompleted: verificationCompleted,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      verificationFailed: verificationFailed,
    );
  }

  Future<UserCredential> verifyOTP(
      String verificationId, String smsCode) async {
    return await apiGatway.verifyOTP(verificationId, smsCode);
  }

  Future<ProfileModel> login(UserCredential credential) async {
    final model = await apiGatway.login(credential);
    session.saveKey(model.id);
    session.saveSession(model);
    return model;
  }

  Future<String> uploadFile(File file) async {
    return await apiGatway.uploadFile(file);
  }

  Future<ProfileModel> getUserProfile({String userId, UserRole role}) async {
    assert(role != null);
    return await apiGatway.getUserProfile(userId, role: role);
  }

  Future<bool> updateProfile(ProfileModel model) async {
    final data = await apiGatway.updateProfile(model);
    session.saveSession(model);
    return data;
  }

  Future<bool> isUserAvailable(String mobile) async {
    return await apiGatway.isUserAvailable(mobile);
  }

  Future<String> uploadProductImage(File file, String merchantId) async {
    return await apiGatway.uploadProductImage(file, merchantId);
  }
}
