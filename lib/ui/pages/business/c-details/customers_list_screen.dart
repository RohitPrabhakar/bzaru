import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/widgets/customer_list_tile.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/widgets/customer_search_delegate.dart';
import 'package:flutter_bzaru/ui/pages/business/invite/m_invite.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/custom_list_tile.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CustomerListScreen extends StatefulWidget {
  @override
  _CustomerListScreenState createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    getCustomersList();
  }

  Future<void> getCustomersList() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _isLoading.value = true;
      await Provider.of<MCustomerState>(context, listen: false)
          .getCustomersList();
      _isLoading.value = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.customers),
        bgColor: KColors.businessPrimaryColor,
        trailingIcon: Icons.search,
        onTrailingPressed: () async {
          final listOfCustomers =
              Provider.of<MCustomerState>(context, listen: false).allCustomers;
          await showSearch(
            context: context,
            delegate: CustomerSearchDelegate(
              listOfCustomers: listOfCustomers,
              searchField:
                  locale.getTranslatedValue(KeyConstants.searchACustomer),
            ),
          );
        },
      ),
      body: Consumer<MCustomerState>(
        builder: (context, state, child) => state.isBusy
            ? Center(
                child: OverlayLoading(
                  showLoader: _isLoading,
                  loadingMessage:
                      "${locale.getTranslatedValue(KeyConstants.fetchingList)}...",
                ),
              )
            : state.allCustomers != null && state.allCustomers.isNotEmpty
                ? Container(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: ListView.builder(
                            itemCount: state.allCustomers.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return CustomerListTile(
                                profileModel: state.allCustomers[index],
                              );
                            },
                          ),
                        ),
                        Container(
                          color: KColors.bgColor,
                          child: BListTile(
                            leadingIcon: Icons.account_box_outlined,
                            tileHeight: 50,
                            title: locale.getTranslatedValue(
                                KeyConstants.inviteCustomers),
                            nextScreen: MInvite(),
                          ),
                        ),
                      ],
                    ))
                : Center(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.noCustomersFound),
                      variant: TypographyVariant.titleSmall,
                    ),
                  ),
      ),
    );
  }
}
