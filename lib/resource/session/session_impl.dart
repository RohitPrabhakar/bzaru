import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/resource/session/session_service.dart';

class SessionServiceImpl implements SessionService {
  final SharedPrefrenceHelper pref;
  SessionServiceImpl(
    this.pref,
  );

  Future<void> saveSession(ProfileModel session) async {
    if (session.role == UserRole.CUSTOMER) {
      await pref.saveProfile(session);
      await pref.setAccessToken(session.id);
      print("Session Save in local!!");
    }
  }

  Future<ProfileModel> loadSession() async {
    try {
      var session = await pref.getUserProfile();
      return session;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await pref.clearAll();
    print("Session clear");
  }

  @override
  Future<void> saveKey(String key) async {
    await pref.setAccessToken(key);
  }
}
