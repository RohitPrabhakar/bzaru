import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/model/b_dashboard_models.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/ui/theme/extensions.dart';
import 'package:intl/intl.dart';

class AnalyticsService {
  final FirebaseFirestore firestore;
  AnalyticsService({this.firestore});

  Future<Source> getSource() async {
    final hasInternet = await Utility.hasInternetConnection();
    if (hasInternet) {
      return Source.serverAndCache;
    } else {
      return Source.cache;
    }
  }

  //get Sales dashboard for a given month
  Future<List<Sales>> getSalesDashboard(
      String merchantId, int forMonths) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    List<String> orderDates = [];
    List<Sales> allSalesData = [];
    final todayDate = DateTime.now();

    for (int i = 0; i < forMonths; i++) {
      if (i == 0) {
        orderDates.add(todayDate.toString().getYearAndMonth());
      } else {
        final prevDate =
            DateTime(todayDate.year, todayDate.month - i).toString();
        orderDates.add(prevDate.getYearAndMonth());
      }
    }

    try {
      final source = await getSource();

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(merchantId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnap) async {
        if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
          for (var orderDateDoc in qSnap.docs) {
            if (orderDates.contains(orderDateDoc.id)) {
              await refMasterOrder
                  .doc(Constants.merchantCollection)
                  .collection(Constants.merchantCollection)
                  .doc(merchantId)
                  .collection(Constants.orderDateDocument)
                  .doc(orderDateDoc.id)
                  .collection(Constants.orderSubCollection)
                  .get(GetOptions(source: source))
                  .then((documentSnapshot) async {
                double totalSales = 0.00;
                print("HELLO ${documentSnapshot.docs}");
                final date = DateTime(
                  int.tryParse(orderDateDoc.id.split("-")[0]),
                  int.tryParse(orderDateDoc.id.split("-")[1]),
                );

                for (var document in documentSnapshot.docs) {
                  if (document.data()["orderStatus"] == "complete") {
                    totalSales = totalSales +
                        double.tryParse(document.data()["totalAmount"]);
                    print("TOTAL SALES: $totalSales");
                  }
                }

                allSalesData.add(Sales(
                  date: date.toString(),
                  month: DateFormat("MMM").format(date),
                  sales: totalSales,
                ));
              });
            }
          }
        }
      }).catchError((error) => throw error);
      return allSalesData;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<BProdSalesModel>> getProductsByCount(String merchantId) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    List<BProdSalesModel> prodSalesModel = [];

    try {
      final source = await getSource();

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(merchantId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnap) async {
        if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
          for (var orderDateDoc in qSnap.docs) {
            await refMasterOrder
                .doc(Constants.merchantCollection)
                .collection(Constants.merchantCollection)
                .doc(merchantId)
                .collection(Constants.orderDateDocument)
                .doc(orderDateDoc.id)
                .collection(Constants.orderSubCollection)
                .get(GetOptions(source: source))
                .then((documentSnapshot) async {
              for (var document in documentSnapshot.docs) {
                List<ProductModel> products = [];
                if (document.data()["orderStatus"] == "complete") {
                  document.data()["items"].forEach((json) {
                    products.add(ProductModel.fromJson(json));
                  });
                  for (var prod in products) {
                    final model =
                        prodSalesModel != null && prodSalesModel.isNotEmpty
                            ? prodSalesModel.firstWhere(
                                (element) => element.id == prod.id,
                                orElse: () => null)
                            : null;

                    if (model != null) {
                      //PRODUCT IS IN THE MAP ALREADY
                      int index = prodSalesModel.indexOf(model);
                      prodSalesModel[index].count =
                          prodSalesModel[index].count + 1;
                    } else {
                      //ADD PRODUCT FIRST TIME
                      prodSalesModel.add(
                        BProdSalesModel(
                          id: prod.id,
                          prodTitle: prod.title,
                          count: 1,
                        ),
                      );
                    }
                  }
                }
              }
            });
          }
        }
      }).catchError((error) => throw error);
      return prodSalesModel;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  Future<List<BProdSalesModel>> getProductBySales(String merchantId) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);
    List<BProdSalesModel> prodSalesModel = [];

    try {
      final source = await getSource();

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(merchantId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((qSnap) async {
        if (qSnap.docs != null && qSnap.docs.isNotEmpty) {
          for (var orderDateDoc in qSnap.docs) {
            await refMasterOrder
                .doc(Constants.merchantCollection)
                .collection(Constants.merchantCollection)
                .doc(merchantId)
                .collection(Constants.orderDateDocument)
                .doc(orderDateDoc.id)
                .collection(Constants.orderSubCollection)
                .get(GetOptions(source: source))
                .then((documentSnapshot) async {
              for (var document in documentSnapshot.docs) {
                List<ProductModel> products = [];

                if (document.data()["orderStatus"] == "complete") {
                  document.data()["items"].forEach((json) {
                    products.add(ProductModel.fromJson(json));
                  });
                  for (var prod in products) {
                    final model =
                        prodSalesModel != null && prodSalesModel.isNotEmpty
                            ? prodSalesModel.firstWhere(
                                (element) => element.id == prod.id,
                                orElse: () => null)
                            : null;

                    if (model != null) {
                      //PRODUCT IS IN THE MAP ALREADY
                      int index = prodSalesModel.indexOf(model);
                      prodSalesModel[index].sales =
                          prodSalesModel[index].sales + prod.price;
                      print(
                          " PRICE SALES MODEL: : : : ${prodSalesModel[index].sales}");
                    } else {
                      //ADD PRODUCT FIRST TIME
                      print(" PRICE FIRST TIME: : : : ${prod.price}");
                      prodSalesModel.add(
                        BProdSalesModel(
                          id: prod.id,
                          prodTitle: prod.title,
                          sales: prod.price,
                        ),
                      );
                    }
                  }
                }
              }
            });
          }
        }
      }).catchError((error) => throw error);
      return prodSalesModel;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }

  ///`Getting unique customers`
  Future<List<CustomerCount>> getCustomersListAnalytics(
      String merhcantId) async {
    CollectionReference refMasterOrder =
        firestore.collection(Constants.orderMasterCollection);

    List<String> ids = List<String>();
    List<CustomerCount> customerCount = [];

    try {
      final source = await getSource();

      print("Getting Customer list");

      await refMasterOrder
          .doc(Constants.merchantCollection)
          .collection(Constants.merchantCollection)
          .doc(merhcantId)
          .collection(Constants.orderDateDocument)
          .get(GetOptions(source: source))
          .then((docSnapshots) async {
        for (var dateDoc in docSnapshots.docs) {
          await refMasterOrder
              .doc(Constants.merchantCollection)
              .collection(Constants.merchantCollection)
              .doc(merhcantId)
              .collection(Constants.orderDateDocument)
              .doc(dateDoc.id)
              .collection(Constants.orderSubCollection)
              .get()
              .then((orderDocs) {
            for (var document in orderDocs.docs) {
              final date = DateTime(
                int.tryParse(document.data()["createdAt"].split("-")[0]),
                int.tryParse(document.data()["createdAt"].split("-")[1]),
              );
              final model = customerCount.isNotEmpty
                  ? customerCount
                      .firstWhere((element) => element.date == date.toString())
                  : null;

              if (model == null) {
                customerCount.add(
                  CustomerCount(
                    count: 1,
                    date: date.toString(),
                    month: DateFormat("MMM").format(date),
                  ),
                );
                if (!ids.contains(document["customerId"])) {
                  ids.add(document["customerId"]);
                }
              } else {
                if (!ids.contains(document["customerId"])) {
                  model.count += 1;
                  ids.add(document["customerId"]);
                }
              }
            }
          });
        }
      });

      return customerCount;
    } on FirebaseAuthException catch (e) {
      throw e;
    } catch (e) {
      throw e;
    }
  }
}
