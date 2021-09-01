import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/product_image_screen.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/out_of_stock.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/helper/enum.dart';

class StoreCategoryItem extends StatelessWidget {
  final ProductModel productModel;
  final String query;

  const StoreCategoryItem({
    Key key,
    this.productModel,
    this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    sizeConfig.init(context);

    final unit = locale.getTranslatedValue(KeyConstants.unit);
    final inStock = productModel.inStock != null ? productModel.inStock : true;

    return Container(
      margin: EdgeInsets.only(right: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        border: Border.all(
          color: Colors.grey[300],
          width: 1.5,
        ),
      ),
      // height: 200,
      width: sizeConfig.safeWidth * 40,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: productModel.id,
            child: Container(
              alignment: Alignment.center,
              child: productModel.imageUrl != null &&
                      productModel.imageUrl.isNotEmpty
                  ? customNetworkImage(
                      productModel.imageUrl[0],
                      height: sizeConfig.safeHeight * 10,
                      width: sizeConfig.safeWidth * 35,

                      // fit: BoxFit.cover,
                      placeholder: BPlaceHolder(
                        height: sizeConfig.safeHeight * 10,
                        // width: 140,
                      ),
                    )
                  : Image.asset(
                      KImages.intro2,
                      height: sizeConfig.safeHeight * 10,
                      width: sizeConfig.safeWidth * 35,
                    ),
            ).ripple(() {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  fullscreenDialog: true,
                  maintainState: true,
                  builder: (context) =>
                      ProductImageScreen(productModel: productModel),
                ),
              );
            }),
          ),
          // SizedBox(height: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    BText(
                      "₹ ${productModel.price.toStringAsFixed(2)}",
                      variant: TypographyVariant.h1,
                      style: TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                    productModel.mrp != null && productModel.mrp != 0.0
                        ? BText(
                            "MRP ₹ ${productModel.mrp.toStringAsFixed(2)}",
                            variant: TypographyVariant.h3,
                            style: TextStyle(
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.lineThrough,
                              fontSize: 10,
                            ),
                            overflow: TextOverflow.ellipsis,
                          )
                        : SizedBox(),
                  ],
                ),
                BText(
                  productModel.title.capitalize(),
                  variant: TypographyVariant.h2,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                // SizedBox(height: 5),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BText(
                        "${productModel.size} ${productModel.productSize.asString() ?? unit}",
                        variant: TypographyVariant.h2,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      inStock ? _buildAddButtonCounter() : OutOfStock(),
                    ],
                  ),
                ),
                SizedBox()
              ],
            ).pH(2),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButtonCounter() {
    final inStock = productModel.inStock != null ? productModel.inStock : true;

    return Consumer<CStoreState>(
      builder: (context, state, child) {
        final count = state.tempQty(productModel);

        return count > 0
            ? Card(
                color: Colors.white,
                elevation: 10.0,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          state.updateItemQuantity(1, productModel, false);
                        },
                        child: productModel.tempQty == 1
                            ? Icon(
                                Icons.delete,
                                color: KColors.customerPrimaryColor,
                                size: 30,
                              )
                            : Icon(
                                Icons.remove,
                                color: KColors.customerPrimaryColor,
                                size: 30,
                              ),
                      ),
                      SizedBox(width: 10),
                      BText(
                        count.toString(),
                        variant: TypographyVariant.h2,
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          state.updateItemQuantity(1, productModel, true);
                        },
                        child: Icon(
                          Icons.add,
                          color: KColors.customerPrimaryColor,
                          size: 30,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : GestureDetector(
                onTap: inStock
                    ? () {
                        state.updateItemQuantity(1, productModel, true);
                        print("HERE");
                      }
                    : null,
                child: Icon(
                  Icons.add_circle_outline,
                  color:
                      inStock ? KColors.customerPrimaryColor : Colors.grey[200],
                  size: 30,
                ),
              );
      },
    );
  }
}
