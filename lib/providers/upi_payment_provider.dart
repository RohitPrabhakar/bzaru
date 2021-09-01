

import 'dart:math';

import 'package:flutter_bzaru/model/upi_payment_model.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:upi_pay/upi_pay.dart';

class UpiPaymentProvider extends BaseState{
  UpiPaymentModel paymentDetails;
  String upiAddressError = "";

  set (upiPaymentModel){
    this.paymentDetails = upiPaymentModel;
  }
  makePayment() async{
    final err = _validateUpiAddress(paymentDetails.receiverUpiAddress);
    if (err != null) {
      upiAddressError = err;
    }


    paymentDetails.transactionRef = Random.secure().nextInt(1 << 32).toString();


    final a = await UpiPay.initiateTransaction(
      amount:paymentDetails.amount.toString(),
      app: paymentDetails.app,
      receiverName: paymentDetails.receiverName,
      receiverUpiAddress: paymentDetails.receiverUpiAddress,
      transactionRef: paymentDetails.transactionRef,
      transactionNote: paymentDetails.transactionNote,
      // merchantCode: paymentDetails.merchantCode,
    );

    print(a);
  }

  String _validateUpiAddress(String value) {
    if (value.isEmpty) {
      return 'UPI VPA is required.';
    }
    if (value.split('@').length != 2) {
      return 'Invalid UPI VPA';
    }
    return null;
  }
}

