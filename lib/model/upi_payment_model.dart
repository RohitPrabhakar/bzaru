import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:upi_pay/upi_pay.dart';

class UpiPaymentModel {

  int amount;
  UpiApplication app;
  String receiverName;
  String receiverUpiAddress;
  String transactionRef;
  String transactionNote;
  String merchantCode;

  UpiPaymentModel({@required this.amount, @required this.app,@required this.receiverName,@required this.receiverUpiAddress, this.transactionNote,@required this.transactionRef, this.merchantCode
  });


}