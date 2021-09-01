import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_explore_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/explore/widgets/explore_item.dart';
import 'package:flutter_bzaru/ui/pages/personal/explore/widgets/explore_search_bar.dart';
import 'package:flutter_bzaru/ui/pages/personal/explore/widgets/searched_item.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:provider/provider.dart';

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  @override
  void initState() {
    _isLoading.value = true;
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getRecentSearches();
    });
    super.initState();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _isLoading.dispose();
    super.dispose();
  }

  void getRecentSearches() async {
    final state = Provider.of<CExploreState>(context, listen: false);
    state.getRecentSearches();
    state.clearState();
    _isLoading.value = false;
  }

  void clearRecentSearchers() async {
    final state = Provider.of<CExploreState>(context, listen: false);
    state.clearRecentSearches();
  }

  Widget _buildPopularStores() {
    final locale = AppLocalizations.of(context);

    return Card(
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.popluarStores),
              variant: TypographyVariant.h1,
              style: TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: Row(
                children: [
                  ExploreItem(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPopularProducts() {
    final locale = AppLocalizations.of(context);

    return Card(
      elevation: 10.0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.popularProducts),
              variant: TypographyVariant.h1,
              style: TextStyle(
                fontSize: 16,
                // fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 10.0),
            Container(
              child: Row(
                children: [
                  ExploreItem(),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(List<String> recentSearches) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.recentSearches),
              variant: TypographyVariant.h1,
              style: TextStyle(fontSize: 18),
            ),
            GestureDetector(
              onTap: () {
                clearRecentSearchers();
              },
              child: BText(
                locale.getTranslatedValue(KeyConstants.clear),
                variant: TypographyVariant.h3,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: KColors.customerPrimaryColor,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        ListView.builder(
          shrinkWrap: true,
          itemCount: recentSearches.length,
          padding: EdgeInsets.symmetric(vertical: 5),
          itemBuilder: (context, index) => Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            child: GestureDetector(
              onTap: () async {
                final state =
                    Provider.of<CExploreState>(context, listen: false);
                await state.getSearchItemAndStore(recentSearches[index]);
                state.setQuery(recentSearches[index]);
              },
              child: Row(
                children: [
                  Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 18,
                  ),
                  SizedBox(width: 5),
                  BText(
                    recentSearches[index],
                    variant: TypographyVariant.h2,
                    style: TextStyle(
                        fontWeight: FontWeight.w300, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(),
        SizedBox(height: 40),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) {
          return isLoading
              ? OverlayLoading(
                  showLoader: _isLoading,
                  loadingMessage:
                      locale.getTranslatedValue(KeyConstants.exploring),
                  bgScreenColor: Colors.white,
                )
              : SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                    child: Column(
                      children: [
                        ExploreSearchBar(
                          scaffoldKey: _scaffoldKey,
                        ),
                        SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Consumer<CExploreState>(
                                builder: (context, state, child) {
                              return state.isBusy
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              1.5,
                                      child: OverlayLoading(
                                        showLoader:
                                            ValueNotifier<bool>(state.isBusy),
                                        loadingMessage:
                                            locale.getTranslatedValue(
                                                KeyConstants.exploring),
                                        bgScreenColor: Colors.white,
                                      ),
                                    )
                                  : state.searchedProducts.isNotEmpty ||
                                          state.searchedStores.isNotEmpty
                                      ? SearchedItem()
                                      : state.searchedQuery != null &&
                                              state.searchedQuery.isNotEmpty
                                          ? Container(
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  1.5,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  BText(
                                                    locale.getTranslatedValue(
                                                        KeyConstants.oops),
                                                    variant:
                                                        TypographyVariant.h1,
                                                  ),
                                                  SizedBox(height: 5),
                                                  BText(
                                                    locale.getTranslatedValue(
                                                        KeyConstants
                                                            .weCouldnotUnderstand),
                                                    variant:
                                                        TypographyVariant.h1,
                                                  ),
                                                ],
                                              ))
                                          : Column(
                                              children: [
                                                state.recentSearchers != null &&
                                                        state.recentSearchers
                                                            .isNotEmpty
                                                    ? _buildRecentSearches(
                                                        state.recentSearchers)
                                                    : SizedBox(),
                                                // _buildPopularStores(), //TODO: POPLUAR STORES
                                                SizedBox(height: 40),
                                                // _buildPopularProducts(),
                                              ],
                                            );
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}
