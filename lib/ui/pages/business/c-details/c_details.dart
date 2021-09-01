import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerListModel profileModel;

  const CustomerDetailsScreen({Key key, this.profileModel}) : super(key: key);

  @override
  _CustomerDetailsScreenState createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  ///Build Detail
  Column _buildDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          label,
          variant: TypographyVariant.h1,
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 5),
        BText(
          value,
          variant: TypographyVariant.h1,
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final model = widget.profileModel;
    String date = model.lastOrderDate.day.toString() +
        "-" +
        model.lastOrderDate.month.toString() +
        "-" +
        model.lastOrderDate.year.toString();

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.customerDetails),
        bgColor: KColors.businessPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(top: 20),
        child: Column(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.name),
                  model.customerName ?? "Customer Name",
                ),
                SizedBox(height: 20),
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.email),
                  model.customerEmail ?? "xyz@gmail.com",
                ),
                SizedBox(height: 20),
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.address),
                  model.customerAddress,
                ),
                SizedBox(height: 20),
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.pastOrder),
                  "#${model.lastOrderNumber}" ?? "Order Id",
                ),
                SizedBox(height: 20),
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.orderValue),
                  model.lastOrderAmount.toStringAsFixed(2),
                ),
                SizedBox(height: 20),
                _buildDetail(
                  locale.getTranslatedValue(KeyConstants.lastOrderDate),
                  date,
                ),
              ],
            ),
            // SizedBox(height: 40),
            // BFlatButton(
            //   text: "Remove",
            //   color: KColors.businessPrimaryColor,
            //   isBold: true,
            //   isWraped: true,
            //   onPressed: () {
            //     //TODO: Remove CUstomer from here
            //   },
            //   padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            // ),
            SizedBox(height: 20),
          ],
        ),
      ).pH(20),
    );
  }
}
