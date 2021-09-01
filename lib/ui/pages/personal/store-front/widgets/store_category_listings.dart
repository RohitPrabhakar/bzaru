import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_category_item.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class StoreCategoryListings extends StatelessWidget {
  final CategoryModel categoryModel;
  final List<ProductModel> listOfProducts;
  final String langCode;

  const StoreCategoryListings({
    Key key,
    this.categoryModel,
    this.listOfProducts,
    this.langCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    print(langCode);
    sizeConfig.init(context);

    return Container(
      height: sizeConfig.safeHeight * 27,
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
                // style: TextStyle(fontWeight: FontWeight.bold),
              ),
              // BText(
              //   "View 100+ More",
              //   variant: TypographyVariant.h2,
              // ),
            ],
          ),
          SizedBox(height: 10),
          Expanded(
            child: Container(
              child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: listOfProducts?.length ?? 0,
                  itemBuilder: (context, index) {
                    return _buildCategoryItemList(listOfProducts[index]);
                  }),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _buildCategoryItemList(ProductModel productModel) {
    return StoreCategoryItem(productModel: productModel);
  }
}
