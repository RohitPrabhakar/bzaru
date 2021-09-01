import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/ui/pages/business/products/edit_products.dart';

class BProductListing extends StatelessWidget {
  final CategoryModel categoryModel;
  final List<ProductModel> listOfProducts;
  final String langCode;

  const BProductListing({
    Key key,
    this.categoryModel,
    this.listOfProducts,
    this.langCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    sizeConfig.init(context);

    return Container(
      height: sizeConfig.safeHeight * 25,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BText(
                categoryModel.lang[langCode ?? "en"].capitalize() ??
                    locale.getTranslatedValue(KeyConstants.undefinedCateogry),
                variant: TypographyVariant.h1,
              ),
              // BText(
              //   "View 100+ More",
              //   variant: TypographyVariant.h2,
              // ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: listOfProducts?.length ?? 0,
                itemBuilder: (context, index) {
                  return _buildCategoryItemList(listOfProducts[index]);
                }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItemList(ProductModel productModel) {
    return BProductItem(productModel: productModel);
  }
}

class BProductItem extends StatelessWidget {
  final ProductModel productModel;
  final String query;

  const BProductItem({
    Key key,
    this.productModel,
    this.query,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    sizeConfig.init(context);

    final unit = locale.getTranslatedValue(KeyConstants.unit);

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
                      EditProductScreen(productModel: productModel),
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
                BText(
                  "${productModel.size} ${productModel.productSize.asString() ?? unit}",
                  variant: TypographyVariant.h2,
                  style: TextStyle(
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ).pH(2),
          ),
        ],
      ),
    );
  }
}
