import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_category_item.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class ProductSearchDelegate extends SearchDelegate<ProductModel> {
  final List<ProductModel> listOfProducts;
  final String searchField;

  ProductSearchDelegate({
    this.listOfProducts,
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
    final locale = AppLocalizations.of(context);

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

    return resultList.isEmpty
        ? Center(
            child: BText(locale.getTranslatedValue(KeyConstants.noResult),
                variant: TypographyVariant.h2))
        : GridView.count(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20.0),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: resultList
                .map((product) => StoreCategoryItem(
                      productModel: product,
                    ))
                .toList(),
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
            child: BText(locale.getTranslatedValue(KeyConstants.noResult),
                variant: TypographyVariant.h2))
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
