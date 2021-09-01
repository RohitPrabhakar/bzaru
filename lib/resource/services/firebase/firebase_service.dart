import 'dart:developer';
import 'dart:io';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bzaru/model/profile_model.dart';

class FirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  FirebaseService({this.auth, this.firestore, this.storage});

  Future<Source> getSource() async {
    final hasInternet = await Utility.hasInternetConnection();
    if (hasInternet) {
      return Source.serverAndCache;
    } else {
      return Source.cache;
    }
  }

  Future<bool> updateProfile(ProfileModel model) async {
    final collection = model.role.asString();
    CollectionReference users = firestore.collection(collection);
    try {
      await users
          .doc(model.id)
          .set(model.toJson())
          .then((value) => log("${model.role.asString()} profile updated",
              name: "Firebase Service", time: DateTime.now()))
          .catchError((error) => throw error);
      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<String> uploadFile(File file) async {
    try {
      try {
        await FirebaseStorage.instance
            .ref('users/${file.path.split("/").last}')
            .putFile(file);
        String downloadURL = await FirebaseStorage.instance
            .ref('users/${file.path.split("/").last}')
            .getDownloadURL();
        log("File uploaded to storage:- $downloadURL",
            name: "Firebase Service", time: DateTime.now());
        return downloadURL;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }
        throw e;
      }
    } catch (error) {
      return error;
    }
  }

  Future<ProfileModel> getUserProfile(String userId, {UserRole role}) async {
    assert(role != null);
    final collection = role.asString();
    final source = await getSource();

    return firestore
        .collection(collection)
        .doc(userId)
        .get(GetOptions(source: source))
        .then((DocumentSnapshot documentSnapshot) {
      if (documentSnapshot.exists) {
        print('Document exists on the database');
        ProfileModel model = ProfileModel.fromJson(documentSnapshot.data());
        return model;
      } else {
        throw Exception("${role.asString()} does not exist in database");
      }
    });
  }

  Future<String> uploadProductImage(File file, String merchantId) async {
    try {
      try {
        await FirebaseStorage.instance
            .ref('users/merchant/$merchantId/${file.path.split("/").last}')
            .putFile(file);
        String downloadURL = await FirebaseStorage.instance
            .ref('users/merchant/$merchantId/${file.path.split("/").last}')
            .getDownloadURL();
        log("Product File uploaded to storage:- $downloadURL",
            name: "Firebase Service", time: DateTime.now());
        return downloadURL;
      } on FirebaseException catch (e) {
        if (e.code == 'permission-denied') {
          print('User does not have permission to upload to this reference.');
        }
        throw e;
      }
    } catch (error) {
      return error;
    }
  }
}
