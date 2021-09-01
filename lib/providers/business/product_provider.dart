import 'dart:io';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/repository.dart';

class ProductProvider extends BaseState {
  List<ProductModel> _listOfMerchantProducts = [];
  List<ProductModel> listOfSearchProducts = [];
  List<ProductModel> _displayProductList = [];
  List<String> _synonymsList = [];

  List<CategoryModel> _categories;

  String selectedCategory = "";
  String searchedkeyWord = "";

  List<ProductModel> get listOfMerchantProducts {
    if (_listOfMerchantProducts == null) {
      return null;
    } else {
      return _listOfMerchantProducts;
    }
  }

  List<CategoryModel> get categories {
    if (_categories == null) {
      return null;
    } else {
      return _categories;
    }
  }

  List<ProductModel> get displayProductList {
    if (_displayProductList == null) {
      return null;
    } else {
      return _displayProductList;
    }
  }

  List<ProductModel> divideCategoricalList(String category) {
    final catProducts = _listOfMerchantProducts
        .where((element) => element.subCategory == category)
        .toList();
    return catProducts;
  }

  List<String> get synonymsList => _synonymsList;

  void setSynonymList(List<String> list) {
    if (list != null && list.isNotEmpty) {
      _synonymsList = List.from(list);
    }
  }

  void addWordToSynonymList(String synonym) {
    if (_synonymsList.length < 5) _synonymsList.add(synonym);
    notifyListeners();
  }

  void clearSynonymsList() {
    if (_synonymsList != null) {
      _synonymsList.clear();
    }
    notifyListeners();
  }

  void removeWordFromSynonymList(String synonym) {
    if (_synonymsList != null && _synonymsList.isNotEmpty) {
      _synonymsList.removeWhere((element) => element == synonym);
    }

    notifyListeners();
  }

  void searchSearchedWord(String value) {
    listOfSearchProducts.clear();
    selectedCategory = "";
    searchedkeyWord = value;

    _listOfMerchantProducts.forEach((product) {
      if (product.title.toLowerCase().contains(searchedkeyWord.toLowerCase())) {
        listOfSearchProducts.add(product);
      }
    });

    notifyListeners();
  }

  void clearSearchedList() {
    listOfSearchProducts.clear();
    searchedkeyWord = "";
  }

  void setSelectedCategory(String category) {
    searchedkeyWord = "";
    if (category == selectedCategory) {
      selectedCategory = "";
    } else {
      selectedCategory = category;
    }
    notifyListeners();
  }

  List<ProductModel> getSelectedCategoryProds() {
    List<ProductModel> list = List<ProductModel>();

    final temp = _listOfMerchantProducts
        .where((element) => element.subCategory == selectedCategory);

    list = List.from(temp);
    return list;
  }

  void clearState() {
    _listOfMerchantProducts?.clear();
    listOfSearchProducts?.clear();
    _displayProductList?.clear();
    notifyListeners();
  }

  ///`Fetching Merchant Product List`
  Future getMerchantProductList() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    // final bool isInternetAvaliable = await Utility.hasInternetConnection();
    isBusy = true;
    _listOfMerchantProducts.clear();
    _displayProductList.clear();
    searchedkeyWord = "";
    selectedCategory = "";

    String merchantId = await pref.getAccessToken();

    final list = await execute(() async {
      return await repo.getMerchantProductList(merchantId);
    }, label: "getMerchantProductList");
    if (list != null) {
      list.forEach((model) {
        if (!model.isDeleted) {
          print(model);
          _listOfMerchantProducts.add(model);
        }
      });

      _displayProductList = List.from(_listOfMerchantProducts);
    }
    notifyListeners();
    isBusy = false;
  }

  Future<bool> addNewProduct(ProductModel model) async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    if (model == null) {
      model = ProductModel(
        title: "Royal Dry Fruits California Almond (1 Kg)",
        description: "100% natural % best in quality",
        price: 829.00,
        size: "0",
        imageUrl: [
          "https://www.freepngimg.com/thumb/broccoli/8-2-broccoli-png-clipart-thumb.png"
        ],
        merchantId: await pref.getAccessToken(),
      );
    }
    isBusy = true;
    final isAdded = await execute(() async {
      return await repo.addNewProduct(model);
    }, label: "getMerchantProductList");
    notifyListeners();

    isBusy = false;
    return isAdded;
  }

  ///Uploading `Product Image`
  Future<String> uploadProductImage(File file) async {
    final repo = getit.get<Repository>();

    final merchantId =
        await getit.get<SharedPrefrenceHelper>().getAccessToken();
    notifyListeners();
    return await execute(() async {
      return await repo.uploadProductImage(file, merchantId);
    }, label: "productFileUploaded");
  }

  ///`Delete` Product
  Future<bool> deleteMerchantProduct(ProductModel model) async {
    final merchantId =
        await getit.get<SharedPrefrenceHelper>().getAccessToken();
    final repo = getit.get<BussinessRepository>();
    isBusy = true;

    final isDeleted = await execute(() async {
      return await repo.deleteMerchantProduct(merchantId, model);
    }, label: "delete Product");

    notifyListeners();

    isBusy = false;
    return isDeleted;
  }

  ///`Update` Product
  Future<bool> updateProduct(ProductModel model) async {
    final repo = getit.get<BussinessRepository>();
    isBusy = true;
    final isUpdated = await execute(() async {
      return await repo.updateMerchantProduct(model);
    }, label: "Updated merchant product");

    isBusy = false;
    notifyListeners();
    return isUpdated;
  }

  ///Fetch `Categories` for Products
  Future<void> getSubCategories(ProfileModel profileModel) async {
    final repo = getit.get<BussinessRepository>();
    final String mainCategory = profileModel.categoryOfBusiness;
    final merchantId =
        await getit.get<SharedPrefrenceHelper>().getAccessToken();

    isBusy = true;
    final list = await execute(() async {
      return await repo.getMerchantSubCategories(mainCategory, merchantId);
    }, label: "GET  merchant Sub Categories");

    _categories = List.from(list);
    print("CATEGORIES, ${categories.length}");

    isBusy = false;
    notifyListeners();
  }
}
