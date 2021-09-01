// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'package:upi_pay/upi_pay.dart';
// import 'package:upi_india/upi_india.dart';
//
// class PaymentScreen extends StatefulWidget {
//   @override
//   _PaymentScreenState createState() => _PaymentScreenState();
// }
//
// class _PaymentScreenState extends State<PaymentScreen> {
//   Future<UpiResponse> _transaction;
//   UpiIndia _upiIndia = UpiIndia();
//   List<UpiApp> apps;
//
//   TextStyle header = TextStyle(
//     fontSize: 18,
//     fontWeight: FontWeight.bold,
//   );
//
//   TextStyle value = TextStyle(
//     fontWeight: FontWeight.w400,
//     fontSize: 14,
//   );
//
//   @override
//   void initState() {
//     _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then((value) {
//       setState(() {
//         apps = value;
//       });
//     }).catchError((e) {
//       apps = [];
//     });
//     super.initState();
//   }
//
//   Future<UpiResponse> initiateTransaction(UpiApp app) async {
//     return _upiIndia.startTransaction(
//         app: app,
//         receiverUpiId: "akkirocker1441@okicici",
//         receiverName: 'Akshay Sharma',
//         transactionRefId: 'TestingUpiIndiaPlugin',
//         transactionNote: 'Not actual. Just an example.',
//         amount: 10,
//         merchantId: "xyzyan1212876cc");
//   }
//
//   Widget displayUpiApps() {
//     if (apps == null)
//       return Center(child: CircularProgressIndicator());
//     else if (apps.length == 0)
//       return Center(
//         child: Text(
//           "No apps found to handle transaction.",
//           style: header,
//         ),
//       );
//     else
//       return Align(
//         alignment: Alignment.topCenter,
//         child: SingleChildScrollView(
//           physics: BouncingScrollPhysics(),
//           child: Wrap(
//             children: apps.map<Widget>((UpiApp app) {
//               return GestureDetector(
//                 onTap: () {
//                   _transaction = initiateTransaction(app);
//                   setState(() {});
//                 },
//                 child: Container(
//                   height: 100,
//                   width: 100,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: <Widget>[
//                       Image.memory(
//                         app.icon,
//                         height: 60,
//                         width: 60,
//                       ),
//                       Text(app.name),
//                     ],
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       );
//   }
//
//   String _upiErrorHandler(error) {
//     switch (error) {
//       case UpiIndiaAppNotInstalledException:
//         return 'Requested app not installed on device';
//       case UpiIndiaUserCancelledException:
//         return 'You cancelled the transaction';
//       case UpiIndiaNullResponseException:
//         return 'Requested app didn\'t return any response';
//       case UpiIndiaInvalidParametersException:
//         return 'Requested app cannot handle the transaction';
//       default:
//         return 'An Unknown error has occurred';
//     }
//   }
//
//   void _checkTxnStatus(String status) {
//     switch (status) {
//       case UpiPaymentStatus.SUCCESS:
//         print('Transaction Successful');
//         break;
//       case UpiPaymentStatus.SUBMITTED:
//         print('Transaction Submitted');
//         break;
//       case UpiPaymentStatus.FAILURE:
//         print('Transaction Failed');
//         break;
//       default:
//         print('Received an Unknown transaction status');
//     }
//   }
//
//   Widget displayTransactionData(title, body) {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text("$title: ", style: header),
//           Flexible(
//               child: Text(
//             body,
//             style: value,
//           )),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('UPI'),
//       ),
//       body: Column(
//         children: <Widget>[
//           Expanded(
//             child: displayUpiApps(),
//           ),
//           Expanded(
//             child: FutureBuilder(
//               future: _transaction,
//               builder:
//                   (BuildContext context, AsyncSnapshot<UpiResponse> snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   if (snapshot.hasError) {
//                     return Center(
//                       child: Text(
//                         _upiErrorHandler(snapshot.error.runtimeType),
//                         style: header,
//                       ), // Print's text message on screen
//                     );
//                   }
//
//                   UpiResponse _upiResponse = snapshot.data;
//
//                   String txnId = _upiResponse.transactionId ?? 'N/A';
//                   String resCode = _upiResponse.responseCode ?? 'N/A';
//                   String txnRef = _upiResponse.transactionRefId ?? 'N/A';
//                   String status = _upiResponse.status ?? 'N/A';
//                   String approvalRef = _upiResponse.approvalRefNo ?? 'N/A';
//                   _checkTxnStatus(status);
//
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: <Widget>[
//                         displayTransactionData('Transaction Id', txnId),
//                         displayTransactionData('Response Code', resCode),
//                         displayTransactionData('Reference Id', txnRef),
//                         displayTransactionData('Status', status.toUpperCase()),
//                         displayTransactionData('Approval No', approvalRef),
//                       ],
//                     ),
//                   );
//                 } else
//                   return Center(
//                     child: Text(''),
//                   );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }
// // String _upiAddrError;
//
// // final _upiAddressController = TextEditingController();
// // final _amountController = TextEditingController();
//
// // bool _isUpiEditable = false;
// // Future<List<ApplicationMeta>> _appsFuture;
//
// // @override
// // void initState() {
// //   super.initState();
//
// //   _amountController.text =
// //       (Random.secure().nextDouble() * 10).toStringAsFixed(2);
// //   _appsFuture = UpiPay.getInstalledUpiApplications();
// // }
//
// // @override
// // void dispose() {
// //   _amountController.dispose();
// //   _upiAddressController.dispose();
// //   super.dispose();
// // }
//
// // void _generateAmount() {
// //   setState(() {
// //     _amountController.text =
// //         (Random.secure().nextDouble() * 10).toStringAsFixed(2);
// //   });
// // }
//
// // Future<void> _onTap(ApplicationMeta app) async {
// //   final err = _validateUpiAddress(_upiAddressController.text);
// //   if (err != null) {
// //     setState(() {
// //       _upiAddrError = err;
// //     });
// //     return;
// //   }
// //   setState(() {
// //     _upiAddrError = null;
// //   });
//
// //   final transactionRef = Random.secure().nextInt(1 << 32).toString();
// //   print("Starting transaction with id $transactionRef");
//
// //   final a = await UpiPay.initiateTransaction(
// //     amount: _amountController.text,
// //     app: app.upiApplication,
// //     receiverName: 'Rajat',
// //     receiverUpiAddress: _upiAddressController.text,
// //     transactionRef: transactionRef,
// //     merchantCode: '7372',
// //   );
//
// //   print(a);
// // }
//
// // @override
// // Widget build(BuildContext context) {
// //   return Scaffold(
// //     body: Container(
// //       padding: EdgeInsets.symmetric(horizontal: 16),
// //       child: ListView(
// //         children: <Widget>[
// //           Container(
// //             margin: EdgeInsets.only(top: 32),
// //             child: Row(
// //               children: <Widget>[
// //                 Expanded(
// //                   child: TextFormField(
// //                     controller: _upiAddressController,
// //                     enabled: _isUpiEditable,
// //                     decoration: InputDecoration(
// //                       border: OutlineInputBorder(),
// //                       hintText: 'address@upi',
// //                       labelText: 'Receiving UPI Address',
// //                     ),
// //                   ),
// //                 ),
// //                 Container(
// //                   margin: EdgeInsets.only(left: 8),
// //                   child: IconButton(
// //                     icon: Icon(
// //                       _isUpiEditable ? Icons.check : Icons.edit,
// //                     ),
// //                     onPressed: () {
// //                       setState(() {
// //                         _isUpiEditable = !_isUpiEditable;
// //                       });
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           if (_upiAddrError != null)
// //             Container(
// //               margin: EdgeInsets.only(top: 4, left: 12),
// //               child: Text(
// //                 _upiAddrError,
// //                 style: TextStyle(color: Colors.red),
// //               ),
// //             ),
// //           Container(
// //             margin: EdgeInsets.only(top: 32),
// //             child: Row(
// //               children: <Widget>[
// //                 Expanded(
// //                   child: TextField(
// //                     controller: _amountController,
// //                     readOnly: true,
// //                     enabled: false,
// //                     decoration: InputDecoration(
// //                       border: OutlineInputBorder(),
// //                       labelText: 'Amount',
// //                     ),
// //                   ),
// //                 ),
// //                 Container(
// //                   margin: EdgeInsets.only(left: 8),
// //                   child: IconButton(
// //                     icon: Icon(Icons.loop),
// //                     onPressed: _generateAmount,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Container(
// //             margin: EdgeInsets.only(top: 128, bottom: 32),
// //             child: Column(
// //               mainAxisSize: MainAxisSize.min,
// //               children: <Widget>[
// //                 Container(
// //                   margin: EdgeInsets.only(bottom: 12),
// //                   child: Text(
// //                     'Pay Using',
// //                     style: Theme.of(context).textTheme.caption,
// //                   ),
// //                 ),
// //                 FutureBuilder<List<ApplicationMeta>>(
// //                   future: _appsFuture,
// //                   builder: (context, snapshot) {
// //                     if (snapshot.connectionState != ConnectionState.done) {
// //                       return Container();
// //                     }
//
// //                     return GridView.count(
// //                       crossAxisCount: 2,
// //                       shrinkWrap: true,
// //                       mainAxisSpacing: 8,
// //                       crossAxisSpacing: 8,
// //                       childAspectRatio: 1.6,
// //                       physics: NeverScrollableScrollPhysics(),
// //                       children: snapshot.data
// //                           .map((it) => Material(
// //                                 key: ObjectKey(it.upiApplication),
// //                                 color: Colors.grey[200],
// //                                 child: InkWell(
// //                                   onTap: () => _onTap(it),
// //                                   child: Column(
// //                                     mainAxisSize: MainAxisSize.min,
// //                                     mainAxisAlignment:
// //                                         MainAxisAlignment.center,
// //                                     children: <Widget>[
// //                                       Image.memory(
// //                                         it.icon,
// //                                         width: 64,
// //                                         height: 64,
// //                                       ),
// //                                       Container(
// //                                         margin: EdgeInsets.only(top: 4),
// //                                         child: Text(
// //                                           it.upiApplication.getAppName(),
// //                                         ),
// //                                       ),
// //                                     ],
// //                                   ),
// //                                 ),
// //                               ))
// //                           .toList(),
// //                     );
// //                   },
// //                 ),
// //               ],
// //             ),
// //           )
// //         ],
// //       ),
// //     ),
// //   );
// // }
//
// // String _validateUpiAddress(String value) {
// //   if (value.isEmpty) {
// //     return 'UPI Address is required.';
// //   }
// //
// //   if (!UpiPay.checkIfUpiAddressIsValid(value)) {
// //     return 'UPI Address is invalid.';
// //   }
// //
// //   return null;
// // }
