import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/c_details.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CustomerListTile extends StatelessWidget {
  final CustomerListModel profileModel;

  const CustomerListTile({
    Key key,
    this.profileModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = profileModel.customerName.capitalize();
    final totalOrders = profileModel.totalOrders ?? 0;
    final totalAmount = profileModel.totalAmount.toStringAsFixed(2) ?? 0.00;
    final locale = AppLocalizations.of(context);

    return Container(
      color: KColors.bgColor,
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      margin: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: customNetworkImage(
              profileModel.customerProfileImage ??
                  "https://cdn.pixabay.com/photo/2020/11/04/19/22/windmill-5713337_960_720.jpg",
              fit: BoxFit.cover,
              placeholder: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  boxShadow: [
                    BoxShadow(color: Colors.grey[100], blurRadius: 5.0)
                  ],
                ),
              ),
              height: 60,
              width: 60,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BText("${locale.getTranslatedValue(KeyConstants.name)}: $name",
                    variant: TypographyVariant.h2),
                SizedBox(height: 10),
                BText(
                    "${locale.getTranslatedValue(KeyConstants.totalOrder)}: $totalOrders",
                    variant: TypographyVariant.h2),
                SizedBox(height: 10),
                BText(
                    "${locale.getTranslatedValue(KeyConstants.totalAmount)}: $totalAmount",
                    variant: TypographyVariant.h2),
              ],
            ),
          )
        ],
      ),
    ).ripple(() {
      Navigator.of(context).push(CupertinoPageRoute(
        builder: (context) => CustomerDetailsScreen(profileModel: profileModel),
      ));
    });
  }
}
