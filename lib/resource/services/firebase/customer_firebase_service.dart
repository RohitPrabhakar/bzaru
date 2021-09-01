import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/model/ads_model.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/help_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';

class CustomerFirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  CustomerFirebaseService({this.auth, this.firestore, this.storage});

  Future<Source> getSource() async {
    final hasInternet = await Utility.hasInternetConnection();
    if (hasInternet) {
      return Source.serverAndCache;
    } else {
      return Source.cache;
    }
  }

  Future<List<HelpModel>> getHelpArticles() async {
    CollectionReference ref =
        firestore.collection(Constants.helpCenterCollection);
    List<HelpModel> articles = [];

    try {
      final source = await getSource();

      await ref.get(GetOptions(source: source)).then((querySnapshot) {
        if (querySnapshot.docs != null && querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((qDoc) {
            articles.add(HelpModel.fromJson(qDoc.data()));
          });
        }
      }).catchError((error) => throw error);

      return articles;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<Map<String, ProfileModel>>> getCustomerStoreList(
      String customerId) async {
    CollectionReference merchantRef =
        firestore.collection(Constants.merchantCollection);

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    List<Map<String, ProfileModel>> mapOfAllStores =
        List<Map<String, ProfileModel>>();

    try {
      List<ProfileModel> allStores = [];
      List<String> ids = List<String>();

      final source = await getSource();
      print("SOURCE: $source");

      await merchantRef.get(GetOptions(source: source)).then((querySnapshot) {
        if (querySnapshot.docs != null && querySnapshot.docs.isNotEmpty) {
          querySnapshot.docs.forEach((qDoc) {
            //TODO: ADD CONDITION SOMEDAY
            allStores.add(ProfileModel.fromJson(qDoc.data()));
          });
        }
      });

      await refMasterOrder
          .doc(Constants.customerCollection)
          .collection(Constants.customerCollection)
          .doc(customerId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnap) async {
        for (var orderDoc in qSnap.docs) {
          await refMasterOrder
              .doc(Constants.customerCollection)
              .collection(Constants.customerCollection)
              .doc(customerId)
              .collection(Constants.orderDateDocument)
              .doc(orderDoc.id)
              .collection(Constants.orderSubCollection)
              .get(GetOptions(source: source))
              .then((cusOrderSnap) async {
            if (cusOrderSnap.docs != null && cusOrderSnap.docs.isNotEmpty) {
              for (var document in cusOrderSnap.docs) {
                if (ids.isNotEmpty) {
                  if (!ids.contains(document.data()["merchantId"])) {
                    ids.add(document.data()["merchantId"]);
                  }
                } else {
                  ids.add(document.data()["merchantId"]);
                }
              }
            }
          });
        }
      });

      //Computing
      if (ids.isNotEmpty) {
        allStores.forEach((model) {
          if (ids.contains(model.id)) {
            mapOfAllStores.add({
              "your": model,
            });
          } else {
            mapOfAllStores.add({
              "more": model,
            });
          }
        });
      } else {
        allStores.forEach((model) {
          mapOfAllStores.add({
            "more": model,
          });
        });
      }

      return mapOfAllStores;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ChatMessage>> getChatsForCustomer(String customerId) async {
    CollectionReference messageUserRef =
        firestore.collection(Constants.messagesUsersCollection);

    CollectionReference refMerchant =
        firestore.collection(Constants.merchantCollection);

    List<ChatMessage> chatLastMessages = [];
    List<ChatMessage> tempList = [];
    try {
      final source = await getSource();
      print("SOURCE: $source");

      await messageUserRef
          .doc(customerId)
          .collection(Constants.messagesUsersCollection)
          .get(GetOptions(source: source))
          .then(
        (snapshot) async {
          if (snapshot.docs != null && snapshot.docs.isNotEmpty) {
            snapshot.docs.forEach((element) {
              tempList.add(ChatMessage.fromJson(element.data()["lastMessage"]));
            });

            for (ChatMessage chatItem in tempList) {
              ChatMessage chatMessage = ChatMessage(
                createdAt: chatItem.createdAt ?? null,
                message: chatItem.message ?? null,
                seen: chatItem.seen ?? null,
                timeStamp: chatItem.timeStamp ?? null,
                senderId: chatItem.senderId ?? null,
                senderName: chatItem.senderName ?? null,
                receiverId: chatItem.receiverId ?? null,
                key: chatItem.key ?? null,
              );

              if (chatItem.senderId == customerId) {
                await refMerchant
                    .doc(chatItem.receiverId)
                    .get(GetOptions(source: source))
                    .then((docSnapshot) {
                  if (docSnapshot != null && docSnapshot.exists) {
                    chatMessage = ChatMessage(
                      createdAt: chatItem.createdAt ?? null,
                      message: chatItem.message ?? null,
                      seen: chatItem.seen ?? null,
                      timeStamp: chatItem.timeStamp ?? null,
                      senderId: chatItem.senderId ?? null,
                      senderName: chatItem.senderName ?? null,
                      receiverId: chatItem.receiverId ?? null,
                      key: chatItem.key ?? null,
                      receiverImage: docSnapshot?.data()["avatar"] == null
                          ? ""
                          : docSnapshot?.data()["avatar"],
                      receiverName: docSnapshot.data()["name"],
                    );
                    chatLastMessages.add(chatMessage);
                  }
                });
              } else {
                //SENDER IS THE RECIEVER--> IF SENDER IS NOT THE CUSTOMER

                await refMerchant
                    .doc(chatItem.senderId)
                    .get(GetOptions(source: source))
                    .then((docSnapshot) {
                  if (docSnapshot != null && docSnapshot.exists) {
                    chatMessage = ChatMessage(
                      createdAt: chatItem.createdAt ?? null,
                      message: chatItem.message ?? null,
                      seen: chatItem.seen ?? null,
                      timeStamp: chatItem.timeStamp ?? null,
                      senderId: chatItem.senderId ?? null,
                      senderName: chatItem.senderName ?? null,
                      receiverId: chatItem.receiverId ?? null,
                      key: chatItem.key ?? null,
                      receiverImage: docSnapshot?.data()["avatar"] != null
                          ? docSnapshot.data()["avatar"]
                          : null,
                      receiverName: docSnapshot.data()["name"],
                    );
                    chatLastMessages.add(chatMessage);
                  }
                });
              }
            }
          }
        },
      ).catchError((error) => throw error);

      return chatLastMessages;
      // return [];
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<OrdersModel>> getCustomerNotifications(String customerId) async {
    CollectionReference ref =
        firestore.collection(UserRole.CUSTOMER.asString());

    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    List<OrdersModel> list = List<OrdersModel>();

    try {
      final source = await getSource();

      await ref
          .doc(customerId)
          .collection(Constants.notificationsCollection)
          .get(GetOptions(source: source))
          .then((querySnapshot) async {
        if (querySnapshot.docs != null && querySnapshot.docs.isNotEmpty) {
          for (var notificationId in querySnapshot.docs) {
            await refMasterOrder
                .doc(Constants.customerCollection)
                .collection(Constants.customerCollection)
                .doc(customerId)
                .collection(Constants.orderDateDocument)
                .get(GetOptions(source: source))
                .then((orderDateSnaps) async {
              if (orderDateSnaps.docs != null &&
                  orderDateSnaps.docs.isNotEmpty) {
                for (var document in orderDateSnaps.docs) {
                  await refMasterOrder
                      .doc(Constants.customerCollection)
                      .collection(Constants.customerCollection)
                      .doc(customerId)
                      .collection(Constants.orderDateDocument)
                      .doc(document.id)
                      .collection(Constants.orderSubCollection)
                      .where("orderNumber", isEqualTo: notificationId.id)
                      .get(GetOptions(source: source))
                      .then((docSnap) {
                    if (docSnap.docs != null && docSnap.docs.isNotEmpty) {
                      OrdersModel model =
                          OrdersModel.fromJson(docSnap.docs[0].data());
                      list.add(model);
                    }
                  });
                }
              }
            });
          }
        }
      }).catchError((error) => throw error);

      return list;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> clearCustomerNotifications(
      String customerId, bool clearAll, String orderId) async {
    CollectionReference ref =
        firestore.collection(UserRole.CUSTOMER.asString());

    try {
      final source = await getSource();
      print("SOURCE: $source");

      if (clearAll) {
        await ref
            .doc(customerId)
            .collection(Constants.notificationsCollection)
            .get(GetOptions(source: source))
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        }).catchError((error) => throw error);
      } else {
        await ref
            .doc(customerId)
            .collection(Constants.notificationsCollection)
            .doc(orderId)
            .delete()
            .catchError((error) => throw error);
      }

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> saveCustomerAddress(
      String customerId, List<CustomerAddressModel> savedAddressList) async {
    CollectionReference ref =
        firestore.collection(UserRole.CUSTOMER.asString());

    savedAddressList.forEach((model) async {
      await ref
          .doc(customerId)
          .collection(Constants.customerAddressCollection)
          .doc(model.id)
          .set(model.toJson(), SetOptions(merge: true))
          .catchError((error) => throw error);
    });

    return true;
  }

  Future<List<CustomerAddressModel>> getCustomerAddress(
      String customerId) async {
    CollectionReference ref =
        firestore.collection(UserRole.CUSTOMER.asString());

    List<CustomerAddressModel> list = List<CustomerAddressModel>();
    final source = await getSource();
    print("SOURCE: $source");

    await ref
        .doc(customerId)
        .collection(Constants.customerAddressCollection)
        .get(GetOptions(source: source))
        .then((qSnap) {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        qSnap.docs.forEach((qDoc) {
          list.add(CustomerAddressModel.fromJson(qDoc.data()));
        });
      }
    }).catchError((error) => throw error);

    return list;
  }

  Future<bool> deleteCustomerAddress(
      String customerId, CustomerAddressModel model) async {
    CollectionReference ref =
        firestore.collection(UserRole.CUSTOMER.asString());

    await ref
        .doc(customerId)
        .collection(Constants.customerAddressCollection)
        .doc(model.id)
        .delete()
        .catchError((error) => throw error);

    return true;
  }

  Future<List<TimingModel>> fetchAvailableTimings(String merchantId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());

    List<TimingModel> timings = [];

    final source = await getSource();
    print("SOURCE: $source");

    await ref
        .doc(merchantId)
        .collection(Constants.merchantTimingsCollection)
        .get(GetOptions(source: source))
        .then((qSnap) {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        qSnap.docs.forEach((element) {
          element.data()["data"].forEach((item) {
            timings.add(TimingModel.fromJson(item));
          });
        });
      }
    }).catchError((onError) => throw onError);

    timings.forEach((element) {
      print(element);
    });

    return timings;
  }

  //getting products for explore
  Future<List<OrdersModel>> getAvailableProducts(String productTitle) async {
    CollectionReference refMerch =
        firestore.collection(UserRole.MERCHANT.asString());
    CollectionReference refProducts =
        firestore.collection(Constants.productCollection);
    List<OrdersModel> list = [];

    final source = await getSource();
    print("SOURCE: $source");

    await refProducts.get(GetOptions(source: source)).then((qSnap) async {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        for (QueryDocumentSnapshot element in qSnap.docs) {
          if (element.data()["title"] != null) {
            bool isContain = element
                        .data()["title"]
                        .toLowerCase()
                        .contains(productTitle.toLowerCase()) &&
                    element.data()["isDeleted"] == false
                ? true
                : false;
            if (isContain) {
              OrdersModel model;
              print("PRODUCT -> ${element.data()}");

              await refMerch
                  .doc(element.data()["merchantId"])
                  .get(GetOptions(source: source))
                  .then((value) {
                model = OrdersModel(
                  merchantId: element.data()["merchantId"],
                  // merchantImage: value.data()["avatar"] != null
                  //     ? value.data()["avatar"]
                  //     : null,
                  merchantName: value.data()["name"],
                  merchantCoverImage: value.data()["coverImage"],
                  categoryOfBusiness: value.data()["categoryOfBusiness"],
                  items: [
                    ProductModel.fromJson(element.data()),
                  ],
                );
              });

              list.add(model);
            }
          }
        }
      }
    }).catchError((onError) => throw onError);

    return list;
  }

  Future<List<ProfileModel>> getSearchedStores(String title) async {
    CollectionReference refMerchant =
        firestore.collection(UserRole.MERCHANT.asString());

    List<ProfileModel> stores = [];

    final source = await getSource();
    print("SOURCE: $source");

    await refMerchant.get(GetOptions(source: source)).then((qSnap) {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        qSnap.docs.forEach((element) {
          bool isContain = element
              .data()["name"]
              .toLowerCase()
              .contains(title.toLowerCase());

          if (isContain) {
            stores.add(ProfileModel.fromJson(element.data()));
          }
        });
      }
    }).catchError((onError) => throw onError);

    return stores;
  }

  Future<List<AdsModel>> getAds(List<int> adsIds) async {
    CollectionReference refAds = firestore.collection(Constants.adsCollection);

    List<AdsModel> ads = [];
    final source = await getSource();

    await refAds.get(GetOptions(source: source)).then((qSnap) {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        adsIds.forEach((id) {
          final model =
              qSnap.docs.firstWhere((element) => element.data()["id"] == id);
          if (model != null) {
            ads.add(AdsModel.fromMap(model.data()));
          }
        });
      }
    }).catchError((onError) => throw onError);

    return ads;
  }

  Future<List<ArticlesModel>> getCustomerArticles(List<int> articleIds) async {
    CollectionReference refArticles =
        firestore.collection(Constants.articlesCollection);

    List<ArticlesModel> articles = [];
    final source = await getSource();

    await refArticles.get(GetOptions(source: source)).then((qSnap) {
      if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
        articleIds.forEach((id) {
          final model =
              qSnap.docs.firstWhere((element) => element.data()["id"] == id);
          if (model != null) {
            articles.add(ArticlesModel.fromMap(model.data()));
          }
        });
      }
    }).catchError((onError) => throw onError);

    return articles;
  }

  Future<ChatMessage> getChatWithStore(
      String customerId, String forMerchantId) async {
    CollectionReference messageUserRef =
        firestore.collection(Constants.messagesUsersCollection);

    CollectionReference refMerchant =
        firestore.collection(Constants.merchantCollection);

    ChatMessage chatMessage;

    try {
      final source = await getSource();
      print("SOURCE: $source");
      print("CUSTOMER ID: $customerId");
      print("MERCHANT ID: $forMerchantId");

      await messageUserRef
          .doc(customerId)
          .collection(Constants.messagesUsersCollection)
          .doc(forMerchantId)
          .get(GetOptions(source: source))
          .then(
        (docSnap) async {
          if (docSnap != null && docSnap.exists) {
            final chatItem = ChatMessage.fromJson(docSnap.data());
            print("CHAT ITEM $chatItem");

            if (chatItem.senderId == customerId) {
              await refMerchant
                  .doc(chatItem.receiverId)
                  .get(GetOptions(source: source))
                  .then((docSnapshot) {
                if (docSnapshot != null && docSnapshot.exists) {
                  chatMessage = ChatMessage(
                    createdAt: chatItem.createdAt ?? null,
                    message: chatItem.message ?? null,
                    seen: chatItem.seen ?? null,
                    timeStamp: chatItem.timeStamp ?? null,
                    senderId: chatItem.senderId ?? null,
                    senderName: chatItem.senderName ?? null,
                    receiverId: chatItem.receiverId ?? null,
                    key: chatItem.key ?? null,
                    receiverImage: docSnapshot?.data()["avatar"] == null
                        ? ""
                        : docSnapshot?.data()["avatar"],
                    receiverName: docSnapshot.data()["name"],
                  );
                }
              });
            } else {
              //SENDER IS THE RECIEVER--> IF SENDER IS NOT THE CUSTOMER
              await refMerchant
                  .doc(chatItem.senderId)
                  .get(GetOptions(source: source))
                  .then((docSnapshot) {
                if (docSnapshot != null && docSnapshot.exists) {
                  chatMessage = ChatMessage(
                    createdAt: chatItem.createdAt ?? null,
                    message: chatItem.message ?? null,
                    seen: chatItem.seen ?? null,
                    timeStamp: chatItem.timeStamp ?? null,
                    senderId: chatItem.senderId ?? null,
                    senderName: chatItem.senderName ?? null,
                    receiverId: chatItem.receiverId ?? null,
                    key: chatItem.key ?? null,
                    receiverImage: docSnapshot?.data()["avatar"] != null
                        ? docSnapshot.data()["avatar"]
                        : null,
                    receiverName: docSnapshot.data()["name"],
                  );
                }
              });
            }
          }
        },
      ).catchError((error) => throw error);

      return chatMessage;
      // return [];
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }
}
