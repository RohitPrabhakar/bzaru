import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/store_front.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CStoreTile extends StatelessWidget {
  final ProfileModel profileModel;

  const CStoreTile({
    Key key,
    @required this.profileModel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => StoreFrontPage(
                profileModel: profileModel,
              ),
            ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        elevation: 10.0,
        // color: KColors.bgColor,
        child: Padding(
          padding: const EdgeInsets.only(right: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                color: Colors.white,
                child: customNetworkImage(
                  profileModel.avatar,
                  fit: BoxFit.cover,
                  placeholder: BPlaceHolder(
                    height: 70,
                    width: 70,
                  ),
                  height: 70,
                  width: 70,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BText(
                            profileModel.name ??
                                locale.getTranslatedValue(
                                    KeyConstants.merchantName),
                            variant: TypographyVariant.h1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 5),
                          BText(
                            locale.getTranslatedValue(KeyConstants.delievey),
                            variant: TypographyVariant.h3,
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Icon(
                        Icons.navigate_next,
                        size: 40,
                        color: KColors.customerPrimaryColor,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  // @override
  // Widget build(BuildContext context) {
  // return GestureDetector(
  //   onTap: () {
  //      Navigator.push(
  //         context,
  //         CupertinoPageRoute(
  //           builder: (context) => StoreFrontPage(
  //             profileModel: profileModel,
  //           ),
  //         ));
  //   },
  //   child: Card(
  //     margin: EdgeInsets.symmetric(vertical: 5.0),
  //     elevation: 5.0,
  //     color: KColors.bgColor,
  //     child: Padding(
  //       padding: const EdgeInsets.only(right: 10.0),
  //       child: Row(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Container(
  //             height: 80,
  //             width: 80,
  //             color: Colors.white,
  //             child: customNetworkImage(
  //               profileModel.avatar,
  //               fit: BoxFit.cover,
  //               placeholder: BPlaceHolder(
  //                 height: 80,
  //                 width: 80,
  //               ),
  //               height: 80,
  //               width: 80,
  //             ),
  //           ),
  //           SizedBox(width: 20),
  //           Expanded(
  //             child: Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Expanded(
  //                   flex: 10,
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       BText(
  //                         profileModel.name ?? "Business Name",
  //                         variant: TypographyVariant.h1,
  //                         // style: TextStyle(
  //                         //     fontWeight: FontWeight.w500, fontSize: 16),
  //                       ),
  //                       SizedBox(height: 10),
  //                       BText(
  //                         "Delivery",
  //                         variant: TypographyVariant.h1,
  //                         style: TextStyle(fontWeight: FontWeight.w300),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   flex: 1,
  //                   child: Icon(
  //                     Icons.navigate_next,
  //                     size: 40,
  //                     color: KColors.customerPrimaryColor,
  //                   ).pV(20),
  //                 )
  //               ],
  //             ),
  //           ),
  //         ],
  //       ),
  //     ),
  //   ),
  // );}
}
