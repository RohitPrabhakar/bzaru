import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';

class ChatState extends BaseState {
  List<ChatMessage> _messageList;
  List<ChatMessage> _allMessageList;

  ProfileModel _chatUser;
  List<ChatMessage> _lastMessageChatsMerchant;

  List<ChatMessage> get allMessageList => _allMessageList;

  List<ChatMessage> get lastMessageChat => _lastMessageChatsMerchant;

  StreamSubscription<QuerySnapshot> _messageSubscription;
  static CollectionReference _messageCollection =
      FirebaseFirestore.instance.collection(Constants.messagesCollection);

  static CollectionReference _userCollection =
      FirebaseFirestore.instance.collection(Constants.messagesUsersCollection);

  ProfileModel get chatUser => _chatUser;
  set setChatUser(ProfileModel model) {
    print("setChatUser -> Id: ${model.id}, Name: ${model.name}");
    _chatUser = model;
  }

  String _channelName;

  List<ChatMessage> get messageList {
    if (_messageList == null) {
      return null;
    } else {
      _messageList.sort((x, y) => DateTime.parse(x.createdAt)
          .toLocal()
          .compareTo(DateTime.parse(y.createdAt).toLocal()));
      _messageList.reversed;
      _messageList = _messageList.reversed.toList();
      return List.from(_messageList);
    }
  }

  void databaseInit(String userId, String myId) async {
    print("databaseInit -> userId: $userId, myId: $myId");

    _messageList = null;

    getChannelName(userId, myId);

    _messageSubscription = _messageCollection
        .doc(_channelName)
        .collection(Constants.messagesCollection)
        .snapshots()
        .listen((QuerySnapshot snapshot) {
      if (snapshot.docChanges.isEmpty) {
        return;
      }
      if (snapshot.docChanges.first.type == DocumentChangeType.added) {
        _onMessageAdded(snapshot.docChanges.first.doc);
      } else if (snapshot.docChanges.first.type == DocumentChangeType.removed) {
        // _onNotificationRemoved(snapshot.documentChanges.first.doc);
      } else if (snapshot.docChanges.first.type ==
          DocumentChangeType.modified) {
        _onMessageChanged(snapshot.docChanges.first.doc);
      }
    });
  }

  /// Fetch chat  all chat messages
  /// `_channelName` is used as primary key for chat message table
  /// `_channelName` is created from  by combining first 5 letters from user ids of two users
  void getchatDetailAsync() async {
    try {
      // _messageList.clear();
      if (_messageList == null) {
        _messageList = [];
      }
      _messageCollection
          .doc(_channelName)
          .collection(Constants.messagesCollection)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot != null && querySnapshot.docs.isNotEmpty) {
          for (var i = 0; i < querySnapshot.docs.length; i++) {
            final model = ChatMessage.fromJson(querySnapshot.docs[i].data());
            model.key = querySnapshot.docs.first.id;
            _messageList.add(model);
          }
          // _userlist.addAll(_userFilterlist);
          // _userFilterlist.sort((x, y) => y.followers.compareTo(x.followers));
          notifyListeners();
        } else {
          _messageList = null;
        }
      });
      // kDatabase
      //     .child('chats')
      //     .child(_channelName)
      //     .once()
      //     .then((DataSnapshot snapshot) {
      //   _messageList = List<ChatMessage>();
      //   if (snapshot.value != null) {
      //     var map = snapshot.value;
      //     if (map != null) {
      //       map.forEach((key, value) {
      //         var model = ChatMessage.fromJson(value);
      //         model.key = key;
      //         _messageList.add(model);
      //       });
      //     }
      //   } else {
      //     _messageList = null;
      //   }
      // });
    } catch (error) {
      print(error);
    }
  }

  void onMessageSubmitted(ChatMessage message,
      {ProfileModel myUser, ProfileModel secondUser}) {
    print(chatUser.id);
    try {
      if (message.message != null &&
          message.message.length > 0 &&
          message.message.length < 400) {
        _userCollection
            .doc(message.senderId)
            .collection(Constants.messagesUsersCollection)
            .doc(message.receiverId)
            .set({"lastMessage": message.toJson()});
        _userCollection
            .doc(message.receiverId)
            .collection(Constants.messagesUsersCollection)
            .doc(message.senderId)
            .set({"lastMessage": message.toJson()});

        FirebaseFirestore.instance
            .collection(Constants.messagesCollection)
            .doc(_channelName)
            .collection(Constants.messagesCollection)
            .doc()
            .set(message.toJson());
        // sendAndRetrieveMessage(message);

      }
    } catch (error) {
      print(error);
    }
  }

  String getChannelName(String user1, String user2) {
    user1 = user1.substring(0, 8);
    user2 = user2.substring(0, 8);
    List<String> list = [user1, user2];
    list.sort();
    _channelName = '${list[0]}-${list[1]}';
    // print(_channelName); //2RhfE-5kyFB
    return _channelName;
  }

  void _onMessageAdded(DocumentSnapshot snapshot) {
    if (_messageList == null) {
      _messageList = List<ChatMessage>();
    }
    if (snapshot.data != null) {
      var map = snapshot.data();
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = snapshot.id;
        if (_messageList.length > 0 &&
            _messageList.any((x) => x.key == model.key)) {
          return;
        }
        _messageList.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void _onMessageChanged(DocumentSnapshot snapshot) {
    if (_messageList == null) {
      _messageList = List<ChatMessage>();
    }
    if (snapshot.data != null) {
      var map = snapshot.data();
      if (map != null) {
        var model = ChatMessage.fromJson(map);
        model.key = snapshot.id;
        if (_messageList.length > 0 &&
            _messageList.any((x) => x.key == model.key)) {
          return;
        }
        _messageList.add(model);
      }
    } else {
      _messageList = null;
    }
    notifyListeners();
  }

  void onChatScreenClosed() {
    if (_messageSubscription != null) {
      _messageSubscription.cancel();
    }
  }

  @override
  void dispose() {
    if (_messageSubscription != null) {
      _messageSubscription.cancel();
    }
    super.dispose();
  }

  void setChatsMessages(List<ChatMessage> chatMessages) {
    print("HEREEEE SET CHAT");
    _lastMessageChatsMerchant?.clear();
    _lastMessageChatsMerchant = List<ChatMessage>();

    _lastMessageChatsMerchant = List.from(chatMessages);

    _lastMessageChatsMerchant.sort((a, b) => DateTime.tryParse(b.createdAt)
        .compareTo(DateTime.tryParse(a.createdAt)));

    notifyListeners();
  }

  //FOR MERCHANT
  Future<void> getChatsForMerchant() async {
    try {
      isBusy = true;
      final repo = getit.get<BussinessRepository>();
      final merchantId = await SharedPrefrenceHelper().getAccessToken();

      final tempList = await execute(() async {
        return repo.getChatsForMerchant(merchantId);
      });

      if (tempList != null) {
        _allMessageList = List.from(tempList);
        setChatsMessages(tempList);
      } else {
        _allMessageList = [];
      }
      isBusy = false;
      notifyListeners();
    } catch (e) {}
  }

  //FOR CUSTOMER
  Future<void> getChatsForCustomer() async {
    try {
      isBusy = true;
      final repo = getit.get<CustomerRepository>();
      final customerId = await SharedPrefrenceHelper().getAccessToken();

      final tempList = await execute(() async {
        return repo.getChatsForCustomer(customerId);
      });

      if (tempList != null) {
        _allMessageList = List.from(tempList);
        setChatsMessages(tempList);
      } else {
        _allMessageList = [];
      }
      isBusy = false;
      notifyListeners();
    } catch (e) {}
  }
}
