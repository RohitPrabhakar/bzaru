import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/products/add_products.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/b_product_item.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/product_catalogue_search_delegate.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/product_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/widgets/store_category_listings.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/search_box.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter/src/painting/basic_types.dart' as painting;

class MyProductsScreen extends StatefulWidget {
  @override
  _MyProductsScreenState createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  String langCode = "en";

  @override
  void initState() {
    super.initState();
    _isLoading.value = true;
    getLocale();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      getAllMerhcantProducts();
    });
  }

  void getLocale() async {
    langCode = await SharedPrefrenceHelper().getLanguageCode();
  }

  Future<void> getAllMerhcantProducts() async {
    final state = Provider.of<ProductProvider>(context, listen: false);
    final profile =
        Provider.of<ProfileState>(context, listen: false).merchantProfileModel;
    state.clearSearchedList();
    await state.getMerchantProductList();
    await state.getSubCategories(profile);
    _isLoading.value = false;
  }

  ///Building `Search Bar` here
  Widget _buildSearchBar(List<ProductModel> list) {
    final locale = AppLocalizations.of(context);

    return SearchBox(
      onTap: () {
        showSearch(
            context: context,
            delegate: ProductCatalogueSearchDelegate(
                listOfProducts: list,
                searchField:
                    "${locale.getTranslatedValue(KeyConstants.searchInventory)}..."));
      },
    );
  }

  ///Building `FloatingActionButton` here
  Widget _buildFloatingButton() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(context,
            CupertinoPageRoute(builder: (context) => AddProductScreen()));
        // Navigator.push(context, AddProductScreen.getRoute());
      },
      backgroundColor: KColors.businessPrimaryColor,
      child: Stack(
        children: [
          Container(height: 50, width: 50),
          Align(
            alignment: Alignment.center,
            child: Container(height: 30, width: 2.0, color: Colors.white),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(height: 2.0, width: 30.0, color: Colors.white),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      // backgroundColor: KColors.bgColor,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.productsCatalog),
        removeLeadingIcon: true,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _buildFloatingButton(),
      body: ValueListenableBuilder(
        valueListenable: _isLoading,
        builder: (context, isLoading, _) => isLoading
            ? OverlayLoading(
                showLoader: _isLoading,
                bgScreenColor: Colors.white,
                loadingMessage:
                    "${locale.getTranslatedValue(KeyConstants.fetchingProducts)}...",
              )
            : Consumer<ProductProvider>(
                builder: (context, state, child) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        _buildSearchBar(state.displayProductList),
                        SizedBox(height: 20),
                        state.displayProductList != null &&
                                state.displayProductList.isNotEmpty
                            ? Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                      children: state.categories.map(
                                    (CategoryModel categoryModel) {
                                      final listOfProducts =
                                          state.divideCategoricalList(
                                              categoryModel.category);
                                      if (listOfProducts != null &&
                                          listOfProducts.isNotEmpty) {
                                        return BProductListing(
                                          categoryModel: categoryModel,
                                          listOfProducts: listOfProducts,
                                          langCode: langCode,
                                        );
                                      } else {
                                        return SizedBox();
                                      }
                                    },
                                  ).toList()),
                                ),
                              )
                            : Container(
                                height: MediaQuery.of(context).size.height / 2,
                                child: Center(
                                  child: BText(
                                    "${locale.getTranslatedValue(KeyConstants.noItemsFound)} :(",
                                    variant: TypographyVariant.titleSmall,
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                      ],
                    ).pH(20),
                  );
                },
              ),
      ),
    );
  }
}
