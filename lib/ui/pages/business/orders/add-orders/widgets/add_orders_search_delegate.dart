import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/pages/business/orders/add-orders/widgets/add_prod_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_category_item.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AddOrderSearchDelegate extends SearchDelegate<ProductModel> {
  final List<ProductModel> listOfProducts;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String searchField;

  AddOrderSearchDelegate({
    this.listOfProducts,
    this.scaffoldKey,
    this.searchField,
  });

  @override
  String get searchFieldLabel => searchField;

  @override
  TextStyle get searchFieldStyle => TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.w400,
        fontSize: 16.0,
        fontFamily: "Roboto",
      );

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back_ios),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    print(query);
    final resultList = listOfProducts
        .where(
          (product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()) ||
              ((product.productSnyonmys != null &&
                      product.productSnyonmys.isNotEmpty) &&
                  product.productSnyonmys.contains(query.toLowerCase())),
        )
        .toList();

    final state = Provider.of<MOrderState>(context, listen: false);
    final locale = AppLocalizations.of(context);

    return resultList.isEmpty
        ? Center(
            child: BText(
              locale.getTranslatedValue(KeyConstants.noResult),
              variant: TypographyVariant.h2,
            ),
          )
        : SingleChildScrollView(
            child: Column(
              children: [
                Column(
                  children: resultList.map((product) {
                    bool isPresent = false;
                    state.displayOrderProductList.forEach((element) {
                      if (element.id == product.id) {
                        isPresent = true;
                      }
                    });
                    return AddProdTile(
                      model: product,
                      isPresent: isPresent,
                    );
                  }).toList(),
                ),
                SizedBox(height: 40),
                BFlatButton(
                  text: locale.getTranslatedValue(KeyConstants.addText),
                  isBold: true,
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  color: KColors.businessPrimaryColor,
                  isWraped: true,
                  onPressed: () {
                    final orderState =
                        Provider.of<MOrderState>(context, listen: false);

                    if (orderState.tempEditItemList.length > 0) {
                      orderState.addItemListToDisplayList();
                      orderState.clearItemList();

                      Navigator.of(context).pop();
                    } else {
                      Utility.displaySnackbar(context,
                          msg: locale
                              .getTranslatedValue(KeyConstants.noProductAdded),
                          key: scaffoldKey);
                    }
                  },
                ),
                SizedBox(height: 40),
              ],
            ),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final list = query.isEmpty
        ? listOfProducts.sublist(
            0,
            listOfProducts.length > 10 ? 10 : listOfProducts.length,
          )
        : listOfProducts
            .where(
              (product) =>
                  product.title.toLowerCase().contains(query.toLowerCase()) ||
                  product.description
                      .toLowerCase()
                      .contains(query.toLowerCase()) ||
                  ((product.productSnyonmys != null &&
                          product.productSnyonmys.isNotEmpty) &&
                      product.productSnyonmys.contains(query.toLowerCase())),
            )
            .toList();

    return list.isEmpty
        ? Center(
            child: BText(
              locale.getTranslatedValue(KeyConstants.noResult),
              variant: TypographyVariant.h2,
            ),
          )
        : ListView.builder(
            itemCount: list.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                onTap: () {
                  query = list[index].title;
                  showResults(context);
                },
                title: BText(
                  list[index].title,
                  variant: TypographyVariant.h2,
                ),
              );
            },
          );
  }
}
