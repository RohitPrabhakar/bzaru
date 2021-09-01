import 'package:flutter_bzaru/model/profile_model.dart';

abstract class SessionService {

  Future<void> saveSession(ProfileModel register);

  Future<ProfileModel> loadSession();

  Future<void> saveKey(String key);

  Future<void> clearSession();

}