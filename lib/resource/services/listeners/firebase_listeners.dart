import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';

class FirebaseListeners {
  final FirebaseFirestore firestore;

  FirebaseListeners({this.firestore});

  StreamSubscription<QuerySnapshot> orderStream(String userId, UserRole role) {
    CollectionReference ref = firestore.collection(role.asString());

    return ref
        .doc(userId)
        .collection(Constants.orderCollection)
        .snapshots()
        .listen((event) {
      event.docChanges.forEach((element) {
        print(element.doc.data());
      });
    });
  }
}
