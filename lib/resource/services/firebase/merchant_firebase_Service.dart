import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';

class MerchantFirebaseService {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;
  MerchantFirebaseService({this.auth, this.firestore, this.storage});

  Future<Source> getSource() async {
    final hasInternet = await Utility.hasInternetConnection();
    if (hasInternet) {
      return Source.serverAndCache;
    } else {
      return Source.cache;
    }
  }

  Future<List<ProductModel>> getMerchantProductList(String merchantId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    try {
      final source = await getSource();

      return await ref
          .doc(merchantId)
          .collection(Constants.merchantProductCollection)
          .get(GetOptions(source: source))
          .then((documentSnapshot) {
        if (documentSnapshot.docs != null && documentSnapshot.docs.isNotEmpty) {
          List<ProductModel> list = List<ProductModel>();
          print('Products exists on the database');
          documentSnapshot.docs.forEach((element) {
            ProductModel model = ProductModel.fromJson(element.data());
            print("FROM GET MERCHANT ${element.data()["id"]}");
            list.add(model);
          });
          return list;
        } else {
          throw Exception(
              "Products does not exist in database for $merchantId");
        }
      }).catchError((error) => throw error);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> addNewProduct(ProductModel model) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    CollectionReference prodCollection =
        firestore.collection(Constants.productCollection);
    try {
      final createdAt = DateTime.now();
      final merchName = model.merchantId.substring(0, 5);

      final productId = (model.title.split(" ")[0].length > 6
              ? model.title.split(" ")[0].substring(0, 5).toLowerCase()
              : model.title.split(" ")[0].toLowerCase()) +
          "-" +
          merchName +
          "-" +
          createdAt.microsecondsSinceEpoch.toString();
      // createdAt.second.toString() + "-" +
      // createdAt.day.toString() + "-" +
      // createdAt.month.toString() + "-" +
      // createdAt.year.toString();

      ///`Creating docId & adding to the model id`

      // final docId = ref
      //     .doc(model.merchantId)
      //     .collection(Constants.merchantProductCollection)
      //     .doc()
      //     .id;

      // model.id = docId; //Use this if auto ids are used.
      print(productId);
      model.id = productId;

      await ref
          .doc(model.merchantId)
          .collection(Constants.merchantProductCollection)
          .doc(productId)
          .set(model.toJson())
          .then((value) => log("${model.title} added in database",
              name: "Firebase Service", time: DateTime.now()))
          .catchError((error) => throw error);

      ///`ADDING TO MAIN COLLECTION`
      await prodCollection
          .doc(productId)
          .set(model.toJson())
          .then((value) => log("ADDED TO PRODCUT COLLECTION"))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> updateMerchantTimings(
      List<TimingModel> timings, String merchantId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    bool isCollectionAvaialble = false;
    try {
      final source = await getSource();

      await ref
          .doc(merchantId)
          .collection(Constants.merchantTimingsCollection)
          .get(GetOptions(source: source))
          .then((documentSnapshot) {
        if (documentSnapshot.docs != null && documentSnapshot.docs.isNotEmpty) {
          isCollectionAvaialble = true;
        }
      });

      if (isCollectionAvaialble) {
        await ref
            .doc(merchantId)
            .collection(Constants.merchantTimingsCollection)
            .doc()
            .delete();
      }
      await ref
          .doc(merchantId)
          .collection(Constants.merchantTimingsCollection)
          .doc(Constants.merchantTimingsCollection)
          .set({
            "data": FieldValue.arrayUnion(
              timings.map((e) => e.toJson()).toList(),
            )
          })
          .then(
            (value) => log(
              "$timings added in database for ID $merchantId",
              name: "Firebase Service",
              time: DateTime.now(),
            ),
          )
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<TimingModel>> getMerchantTimings(String merchantId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    List<TimingModel> list = List<TimingModel>();
    try {
      final source = await getSource();

      return await ref
          .doc(merchantId)
          .collection(Constants.merchantTimingsCollection)
          .doc(Constants.merchantTimingsCollection)
          .get(GetOptions(source: source))
          .then(
        (documentSnapshot) {
          if (documentSnapshot != null && documentSnapshot.exists) {
            documentSnapshot.data()["data"].forEach((model) {
              list.add(TimingModel.fromJson(model));
            });
            return list;
          } else {
            throw Exception("No TIMINGS exist in database for $merchantId");
          }
        },
      ).catchError((error) => throw error);
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> deleteMerchantProduct(ProductModel model) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    CollectionReference prodCollection =
        firestore.collection(Constants.productCollection);
    try {
      // await ref
      //     .doc(merchantId)
      //     .collection(Constants.merchantTimingsCollection)
      //     .doc(model.id)
      //     .delete();

      ///`JUST UPDATING NOT REALLY DELETING`
      await ref
          .doc(model.merchantId)
          .collection(Constants.merchantProductCollection)
          .doc(model.id)
          .delete()
          .then((value) => log("DELETED MERCHANT PRODUCTS"))
          .catchError((error) => throw error);

      await prodCollection
          .doc(model.id)
          .update(model.toJson())
          .then((value) => log("DELETED FROM PRODCUT COLLECTION"))
          .catchError((error) => throw error);
      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<void> addCollectionListener(String merchantId) async {
    firestore
        .collection(UserRole.MERCHANT.toString())
        .doc(merchantId)
        .collection(Constants.merchantProductCollection)
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      print(querySnapshot.docs.length);
    }).onError((e) => print(e));
  }

  Future<void> deleteCollectionListener(String merchantId) async {
    await firestore
        .collection(UserRole.MERCHANT.toString())
        .doc(merchantId)
        .collection(Constants.merchantProductCollection)
        .snapshots()
        .listen((event) {
          print("EVENT $event");
        })
        .cancel()
        .catchError((error) => throw error);
  }

  Future<bool> updateMerchantProduct(ProductModel model) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());
    CollectionReference prodCollection =
        firestore.collection(Constants.productCollection);
    try {
      await ref
          .doc(model.merchantId)
          .collection(Constants.merchantProductCollection)
          .doc(model.id)
          .update(model.toJson())
          .then((value) => log("UPDATED TO MERCHANT PRODUCTS"))
          .catchError((error) => throw error);

      await prodCollection
          .doc(model.id)
          .update(model.toJson())
          .then((value) => log("UPDATED TO PRODCUT COLLECTION"))
          .catchError((error) => throw error);

      return true;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<CustomerListModel>> getCustomersList(String merhcantId) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    List<OrdersModel> list = List<OrdersModel>();
    List<String> ids = List<String>();
    List<CustomerListModel> customerList = List<CustomerListModel>();

    try {
      final source = await getSource();

      print("Getting Customer list");
      //TOOD::D:D:D:D

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(merhcantId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnaps) async {
        if (qSnaps.docs != null && qSnaps.docs.isNotEmpty) {
          for (var dateDoc in qSnaps.docs) {
            await refMasterOrder
                .doc(Constants.merchantCollection)
                .collection(Constants.merchantCollection)
                .doc(merhcantId)
                .collection(Constants.orderDateDocument)
                .doc(dateDoc.id)
                .collection(Constants.orderSubCollection)
                .get(GetOptions(source: source))
                .then((orderDocs) {
              if (orderDocs.docs != null && orderDocs.docs.isNotEmpty) {
                for (var order in orderDocs.docs) {
                  if (order.data()["orderStatus"] == "complete") {
                    OrdersModel model = OrdersModel.fromJson(order.data());
                    list.add(model);
                    if (!ids.contains(order["customerId"])) {
                      ids.add(order["customerId"]);
                    }
                  }
                }
              }
            });
          }

          for (var customerId in ids) {
            int totalOrders = 0;
            double totalAmount = 0.0;
            String imageUrl = "";

            //fetching updated User Image
            await firestore
                .collection(UserRole.CUSTOMER.asString())
                .doc(customerId)
                .get(GetOptions(source: source))
                .then((docSnap) => imageUrl = docSnap.data()["avatar"] != null
                    ? docSnap.data()["avatar"]
                    : null);

            final tempList = list.where(
              (element) => element.customerId == customerId,
            ); //GETTING LIST OF PARTICULAR CUSTOMER

            final orderModel = tempList.last; //LAST ORDER

            totalOrders = tempList.length;
            tempList.forEach((model) {
              print(model.totalAmount);
              totalAmount += model.totalAmount;
            });

            customerList.add(CustomerListModel(
              customerId: orderModel.customerId,
              customerAddress: orderModel.address,
              customerName: orderModel.customerName,
              customerProfileImage: imageUrl,
              totalAmount: totalAmount,
              totalOrders: totalOrders,
              lastOrderNumber: orderModel.orderNumber,
              lastOrderAmount: orderModel.totalAmount,
              lastOrderDate: orderModel.createdAt,
              customerEmail: orderModel.customerEmail,
            ));
          }
        }
      }).catchError((error) => throw error);

      return customerList;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  ///Fetching Merchant Notifications
  Future<List<OrdersModel>> getMerchantNotifications(String merchantId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());

    List<OrdersModel> list = List<OrdersModel>();
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    try {
      final source = await getSource();

      await ref
          .doc(merchantId)
          .collection(Constants.notificationsCollection)
          .get(GetOptions(source: source))
          .then((querySnapshot) async {
        if (querySnapshot.docs != null && querySnapshot.docs.isNotEmpty) {
          for (var notificationId in querySnapshot.docs) {
            await refMasterOrder
                .doc(Constants.merchantCollection)
                .collection(Constants.merchantCollection)
                .doc(merchantId)
                .collection(Constants.orderDateDocument)
                .get(GetOptions(source: source))
                .then((orderDateSnaps) async {
              if (orderDateSnaps.docs != null &&
                  orderDateSnaps.docs.isNotEmpty) {
                for (var document in orderDateSnaps.docs) {
                  await refMasterOrder
                      .doc(Constants.merchantCollection)
                      .collection(Constants.merchantCollection)
                      .doc(merchantId)
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

  ///Clearing Merchant Notificaitons
  Future<bool> clearMerchantNotifications(
      String merchantId, bool clearAll, String orderId) async {
    CollectionReference ref =
        firestore.collection(UserRole.MERCHANT.asString());

    try {
      final source = await getSource();

      if (clearAll) {
        await ref
            .doc(merchantId)
            .collection(Constants.notificationsCollection)
            .get(GetOptions(source: source))
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        }).catchError((error) => throw error);
      } else {
        await ref
            .doc(merchantId)
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

  Future<List<CategoryModel>> getMerchantSubCategories(
      String category, String merchantId) async {
    CollectionReference ref =
        firestore.collection(Constants.mainCategoryCollection);

    List<CategoryModel> categories = [];
    try {
      final source = await getSource();

      await ref
          .doc(category)
          .collection(Constants.subCategoryCollection)
          .get(GetOptions(source: source))
          .then(
        (snapshot) {
          if (snapshot.docs != null && snapshot.docs.isNotEmpty) {
            snapshot.docs.forEach((element) {
              print(element.data());
              categories.add(CategoryModel.fromJson(element.data()));
            });
          }
        },
      ).catchError((error) => throw error);

      return categories;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ChatMessage>> getChatsForMerchant(String merchantId) async {
    CollectionReference messageUserRef =
        firestore.collection(Constants.messagesUsersCollection);

    CollectionReference refCustomer =
        firestore.collection(Constants.customerCollection);

    List<ChatMessage> chatLastMessages = [];
    List<ChatMessage> tempList = [];
    try {
      final source = await getSource();

      await messageUserRef
          .doc(merchantId)
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
                createdAt: chatItem.createdAt,
                message: chatItem.message,
                seen: chatItem.seen,
                timeStamp: chatItem.timeStamp,
                senderId: chatItem.senderId,
                senderName: chatItem.senderName,
                receiverId: chatItem.receiverId,
                key: chatItem.key,
              );

              if (chatItem.senderId == merchantId) {
                await refCustomer
                    .doc(chatItem.receiverId)
                    .get(GetOptions(source: source))
                    .then((docSnapshot) {
                  if (docSnapshot != null && docSnapshot.exists) {
                    chatMessage = ChatMessage(
                      createdAt: chatItem.createdAt,
                      message: chatItem.message,
                      seen: chatItem.seen,
                      timeStamp: chatItem.timeStamp,
                      senderId: chatItem.senderId,
                      senderName: chatItem.senderName,
                      receiverId: chatItem.receiverId,
                      key: chatItem.key,
                      receiverImage: docSnapshot.data()["avatar"] != null
                          ? docSnapshot.data()["avatar"]
                          : null,
                      receiverName: docSnapshot.data()["name"],
                    );
                    chatLastMessages.add(chatMessage);
                  }
                });
              } else {
                //SENDER IS THE RECIEVER--> IF SENDER IS NOT THE MERCHANT
                await refCustomer
                    .doc(chatItem.senderId)
                    .get(GetOptions(source: source))
                    .then((docSnapshot) {
                  if (docSnapshot != null && docSnapshot.exists) {
                    chatMessage = ChatMessage(
                      createdAt: chatItem.createdAt,
                      message: chatItem.message,
                      seen: chatItem.seen,
                      timeStamp: chatItem.timeStamp,
                      senderId: chatItem.senderId,
                      senderName: chatItem.senderName,
                      receiverId: chatItem.receiverId,
                      key: chatItem.key,
                      receiverImage: docSnapshot.data()["avatar"] != null
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
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<ArticlesModel>> getMerchantArticles(List<int> articleIds) async {
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
}
