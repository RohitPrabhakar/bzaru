import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/customer/c_explore_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/widgets/c_store_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/product_image_screen.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/store_front.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class SearchedItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<CExploreState>(
      builder: (context, state, child) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          state.searchedProducts.isNotEmpty
              ? Column(
                  children: state.searchedProducts
                      .map(
                        (productModel) => _buildProduct(context, productModel),
                      )
                      .toList(),
                )
              : SizedBox(),
          SizedBox(height: 20),
          state.searchedStores.isNotEmpty
              ? BText(
                  locale.getTranslatedValue(KeyConstants.stores),
                  variant: TypographyVariant.h1,
                )
              : SizedBox(),
          SizedBox(height: 10),
          state.searchedStores.isNotEmpty
              ? Column(
                  children: state.searchedStores
                      .map(
                        (store) => _buildStore(context, store),
                      )
                      .toList(),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Widget _buildProduct(BuildContext context, OrdersModel model) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => StoreFrontPage(
              profileModel: ProfileModel(
                id: model.merchantId,
                coverImage: model.merchantCoverImage,
                name: model.merchantName,
                avatar: model.merchantImage,
                categoryOfBusiness: model.categoryOfBusiness,
              ),
            ),
          ),
        );

        Navigator.of(context).push(
          CupertinoPageRoute(
              fullscreenDialog: true,
              maintainState: true,
              builder: (context) =>
                  ProductImageScreen(productModel: model.items[0])),
        );
      },
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Card(
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: model.items[0].imageUrl != null &&
                      model.items[0].imageUrl.isNotEmpty
                  ? customNetworkImage(model.items[0].imageUrl[0],
                      fit: BoxFit.cover,
                      height: 50,
                      width: 50,
                      placeholder: BPlaceHolder(
                        height: 50,
                        width: 50,
                      ))
                  : Container(
                      height: 50,
                      width: 50,
                      alignment: Alignment.center,
                      child: Text("NA")),
            ),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BText(
                  model.items[0].title?.capitalize(),
                  variant: TypographyVariant.h1,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.0),
                Row(
                  children: [
                    BText(
                      model.merchantName?.capitalize(),
                      variant: TypographyVariant.h4,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    BText(
                      " | ",
                      variant: TypographyVariant.h4,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    BText(
                      model.items[0].subCategory.toString().capitalize(),
                      variant: TypographyVariant.h4,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStore(BuildContext context, ProfileModel store) {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => StoreFrontPage(
                profileModel: store,
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
                height: 80,
                width: 80,
                color: Colors.white,
                child: customNetworkImage(
                  store.avatar,
                  fit: BoxFit.cover,
                  placeholder: BPlaceHolder(
                    height: 80,
                    width: 80,
                  ),
                  height: 80,
                  width: 80,
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
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BText(
                            store.name ?? "Business Name",
                            variant: TypographyVariant.h1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 5),
                          BText(
                            locale.getTranslatedValue(KeyConstants.delievey),
                            variant: TypographyVariant.h3,
                            style: TextStyle(fontWeight: FontWeight.w300),
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
}
