import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/customer_list_model.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/widgets/customer_list_tile.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CustomerSearchDelegate extends SearchDelegate<CustomerListModel> {
  final List<CustomerListModel> listOfCustomers;
  final String searchField;

  CustomerSearchDelegate({
    this.listOfCustomers,
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
        },
      )
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
    final resultList = listOfCustomers
        .where(
            (customer) => customer.customerName.toLowerCase().contains(query))
        .toList();

    return resultList.isEmpty
        ? Center(
            child: BText(
              locale.getTranslatedValue(KeyConstants.noResult),
              variant: TypographyVariant.h2,
            ),
          )
        : ListView(
            shrinkWrap: true,
            children: resultList
                .map((customer) => CustomerListTile(profileModel: customer))
                .toList(),
          );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final locale = AppLocalizations.of(context);

    final List<CustomerListModel> list = query.isEmpty
        ? []
        : listOfCustomers
            .where((customer) =>
                customer.customerName.toLowerCase().contains(query))
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
              final customer = list[index];
              return CustomerListTile(profileModel: customer);
            },
          );
  }
}
