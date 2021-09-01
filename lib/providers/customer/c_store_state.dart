import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:url_launcher/url_launcher.dart';

class CStoreState extends BaseState {
  List<ProfileModel> _allStoresList = [];
  List<ProfileModel> _yourStoresList;
  List<ProfileModel> _moreStoresList;
  List<ProductModel> _listOfProducts = [];
  List<ProductModel> listOfSearchProducts = [];
  List<ProductModel> _displayProductList = [];
  List<String> _merchantsIds = [];
  List<TimingModel> _storeTimings = [];

  List<OrdersModel> _personalCart = [];
  List<OrdersModel> get personalCart =>
      _personalCart; //ITEMS ADDED TO CART  Will go to ORder State

  List<ProfileModel> get yourStoreList => _yourStoresList;
  List<ProfileModel> get moreStoresList => _moreStoresList;
  List<String> get merchantsIds => _merchantsIds;

  List<CategoryModel> _categories;

  String selectedCategory = "";
  String searchedkeyWord = "";
  ChatMessage _lastChatMessage = ChatMessage();

  int _cartItems = 0;
  int get cartItems => _cartItems;

  List<TimingModel> get storeTimings => _storeTimings;
  ChatMessage get lastChatMessage => _lastChatMessage;
  List<ProductModel> _addedProductsInCart = []; //TODO: MAIN CART
  List<ProductModel> get addedProductsInCart {
    if (_addedProductsInCart == null) {
      return null;
    } else {
      return _addedProductsInCart;
    }
  }

  List<ProductModel> get listOfProducts {
    if (_listOfProducts == null) {
      return null;
    } else {
      return _listOfProducts;
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

  ///Gets if product was added to Cart & returns
  ///the quantity of the item.
  int tempQty(ProductModel productModel) {
    final ProductModel product = _addedProductsInCart.firstWhere(
      (element) => element.id == productModel.id,
      orElse: () => null,
    );

    if (product != null) {
      productModel.tempQty = product.tempQty;
      return product.tempQty;
    } else {
      productModel.tempQty = 0;
      return 0;
    }
  }

  double getTotalAmount(List<OrdersModel> list) {
    double totalAmount = 0.0;
    list.forEach((order) {
      totalAmount = totalAmount + order.totalAmount;
    });

    return totalAmount;
  }

  int calculateCartItems() {
    _cartItems = 0;
    _addedProductsInCart.forEach((element) {
      _cartItems = _cartItems + element.tempQty;
    });

    return _cartItems;
  }

  ///`updating temp quantity`
  void updateItemQuantity(int quantity, ProductModel productModel, bool isAdd) {
    if (isAdd) {
      //ADDITION LOOP
      productModel.tempQty = productModel.tempQty + quantity;

      if (!_addedProductsInCart.contains(productModel)) {
        _addedProductsInCart.add(productModel);
      } else {
        _addedProductsInCart[_addedProductsInCart
            .indexWhere((element) => element == productModel)] = productModel;
      }
    } else {
      //SUBTRACT CONDITION
      if (productModel.tempQty > 1) {
        productModel.tempQty = productModel.tempQty - quantity;
        _addedProductsInCart[_addedProductsInCart
            .indexWhere((element) => element == productModel)] = productModel;
      } else {
        productModel.tempQty = 0;
        _addedProductsInCart.removeAt(_addedProductsInCart
            .indexWhere((element) => element == productModel));
      }
    }
    notifyListeners();
  }

  //`Set Personal cart`
  Future<void> setPersonalCartFromSharedPref() async {
    final pref = getit.get<SharedPrefrenceHelper>();
    final cart = await pref.getCustomerCart();
    final addedProducts = await pref.getAddedProductsToCart();

    if (cart != null && cart.isNotEmpty) {
      print("CART: $cart");
      _personalCart = List.from(cart);
    } else {
      _personalCart = [];
    }

    if (addedProducts != null && addedProducts.isNotEmpty) {
      print("ADDED: $cart");
      _addedProductsInCart = List.from(addedProducts);
    } else {
      _addedProductsInCart = [];
    }

    notifyListeners();
  }

  ///`Building Personal Cart`
  Future<void> updatePersonalCart() async {
    List<String> merchantsIds = [];
    final pref = getit.get<SharedPrefrenceHelper>();

    merchantsIds.clear();
    _personalCart.clear();
    _merchantsIds.clear();

    _addedProductsInCart.forEach((product) {
      if (merchantsIds.isEmpty) {
        merchantsIds.add(product.merchantId);
      } else {
        if (!merchantsIds.contains(product.merchantId)) {
          merchantsIds.add(product.merchantId);
        }
      }
    });

    _merchantsIds = List.from(merchantsIds);

    merchantsIds.forEach((id) {
      double totalAmount = 0;
      String merchantName =
          _allStoresList.firstWhere((profile) => profile.id == id).name;
      String merchantImage =
          _allStoresList.firstWhere((profile) => profile.id == id).avatar;
      String merchantContact = _allStoresList
          .firstWhere((profile) => profile.id == id)
          .contactPrimary;

      final listOfProducts = _addedProductsInCart
          .where((product) => product.merchantId == id)
          .toList();

      listOfProducts.forEach((product) {
        totalAmount += product.price * product.tempQty;
        product.quantity = product.tempQty;
      });

      OrdersModel ordersModel = OrdersModel(
        merchantId: id,
        items: List.from(listOfProducts),
        totalAmount: totalAmount,
        merchantName: merchantName,
        merchantImage: merchantImage,
        totalItems: listOfProducts.length,
        merchantContact: merchantContact,
      );

      _personalCart.add(ordersModel);
    });

    await pref.setAddedProductsToCart(_addedProductsInCart);
    notifyListeners();
  }

  //Dividing Stores
  Future<void> divideStoresList(List<Map<String, ProfileModel>> map) async {
    _yourStoresList = List<ProfileModel>();
    _moreStoresList = List<ProfileModel>();

    map.forEach((mapModel) {
      if (mapModel.keys.first == "your") {
        _allStoresList.add(mapModel.values.first);
        _yourStoresList.add(mapModel.values.first);
      } else {
        _moreStoresList.add(mapModel.values.first);
        _allStoresList.add(mapModel.values.first);
      }
    });

    print("YOUR STORES:  ${_yourStoresList.length}");
    print("MORE STORES:  ${_moreStoresList.length}");
  }

  List<ProductModel> divideCategoricalList(String category) {
    final catProducts = _listOfProducts
        .where((element) => element.subCategory == category)
        .toList();
    return catProducts;
  }

  ///`Fetching Customer Stores`
  Future getCustomerStores() async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    final customerId = await pref.getAccessToken();

    final map = await execute(() async {
      return repo.getCustomerStoreList(customerId);
    });

    if (map != null) {
      print("Customer Stores length: ${map.length}");
      divideStoresList(map);
    } else {
      print("No Order found");
    }
    notifyListeners();
  }

  void clearState() {
    addedProductsInCart?.clear();
    _allStoresList?.clear();
    _yourStoresList?.clear();
    _moreStoresList?.clear();
    _listOfProducts?.clear();
    listOfSearchProducts?.clear();
    _displayProductList?.clear();
    _personalCart?.clear();
    _categories?.clear();
    selectedCategory = '';
    searchedkeyWord = "";

    notifyListeners();
  }

  ///`--------------------------------------DUPLICATE FUNCTIONS FROM PRODUCT PROVIDER WITH TWEAK--------------->`

  ///`Fetching Merchant Products for Specific merchant`
  //`Fetching Merchant Product List`
  Future getMerchantProductList(String merchantId) async {
    final repo = getit.get<BussinessRepository>();
    isBusy = true;
    _listOfProducts.clear();
    _displayProductList.clear();
    searchedkeyWord = "";
    selectedCategory = "";

    final list = await execute(() async {
      return await repo.getMerchantProductList(merchantId);
    }, label: "getMerchantProductList");
    if (list != null) {
      list.forEach((model) {
        if (!model.isDeleted) {
          print(model);
          _listOfProducts.add(model);
        }
      });

      _displayProductList = List.from(_listOfProducts);
    }
    notifyListeners();
    isBusy = false;
  }

  ///Fetch `Categories` for Products
  Future<void> getSubCategories(ProfileModel profileModel) async {
    final repo = getit.get<BussinessRepository>();
    final String mainCategory = profileModel.categoryOfBusiness;
    final merchantId = profileModel.id;

    isBusy = true;
    final list = await execute(() async {
      return await repo.getMerchantSubCategories(mainCategory, merchantId);
    }, label: "GET  merchant Sub Categories");

    _categories = List.from(list);
    print("CATEGORIES, ${categories.length}");

    isBusy = false;
    notifyListeners();
  }

  ///Opening `Dailer`
  Future<void> launchCaller(String contact) async {
    final url = "tel:$contact";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  //Get Store Timings
  Future getStoreTimings(String merchantId) async {
    final repo = getit.get<BussinessRepository>();

    isBusy = true;
    final list = await execute(() async {
      return await repo.getMerchantTimings(merchantId);
    }, label: "getMerchantProductList");
    if (list != null) {
      list.sort((a, b) => a.index.compareTo(b.index));
      _storeTimings = List<TimingModel>.from(list);
    }
    isBusy = false;
  }

  //Getting chat for the customer
  Future<void> getChatWithStore(String forMerchantId) async {
    try {
      isBusy = true;
      final repo = getit.get<CustomerRepository>();
      final customerId = await SharedPrefrenceHelper().getAccessToken();

      _lastChatMessage = await execute(() async {
        return repo.getChatWithStore(customerId, forMerchantId);
      });

      isBusy = false;
      notifyListeners();
    } catch (e) {
      _lastChatMessage = ChatMessage();
      notifyListeners();
    }
  }
}
