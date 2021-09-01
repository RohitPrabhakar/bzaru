import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';

class CExploreState extends BaseState {
  List<OrdersModel> _searchedProducts = [];
  List<ProfileModel> _searchedStores = [];
  String _searchedQuery = "";
  List<String> _recentSearches = [];

  List<OrdersModel> get searchedProducts => _searchedProducts;
  List<ProfileModel> get searchedStores => _searchedStores;
  String get searchedQuery => _searchedQuery;
  List<String> get recentSearchers => _recentSearches;

  void setQuery(String query) {
    _searchedQuery = query;
    notifyListeners();
  }

  void clearState() {
    _searchedQuery = "";
    _searchedProducts.clear();
    _searchedStores.clear();
    notifyListeners();
  }

  void getRecentSearches() async {
    final pref = getit.get<SharedPrefrenceHelper>();
    List<String> list = await pref.getRecentSearches();
    if (list != null && list.isNotEmpty) {
      _recentSearches = List<String>.from(list.reversed)
          .sublist(0, list.length < 9 ? list.length : 8);
    }
    notifyListeners();
  }

  void clearRecentSearches() async {
    final pref = getit.get<SharedPrefrenceHelper>();
    await pref.clearRecentSearches();
    _recentSearches.clear();
    notifyListeners();
  }

  Future<void> getSearchItemAndStore(String query) async {
    final repo = getit.get<CustomerRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();

    isBusy = true;
    _searchedProducts.clear();
    _searchedStores.clear();

    List<String> recentList = await pref.getRecentSearches();
    if (recentList != null && recentList.isNotEmpty) {
      if (!recentList.contains(query)) {
        recentList.add(query);
        await pref.setRecentSearches(recentList);
        _recentSearches = List.from(recentList);
      }
    } else {
      final list = List<String>();
      list.add(query);
      await pref.setRecentSearches(list);
      _recentSearches = List.from(list);
    }

    final list = await execute(() async {
      return await repo.getAvailableProducts(query);
    }, label: "GET  Searched Products");

    final storeList = await execute(() async {
      return await repo.getSearchedStores(query);
    }, label: "GET  Searched Stores");

    if (list != null) {
      print("--------------------------PRODUCTS-----------------------------");
      print(list);
      _searchedProducts = List.from(list);
    }
    if (storeList != null) {
      print("--------------------------STORES-----------------------------");
      print(storeList);
      _searchedStores = List.from(storeList);
    }

    isBusy = false;
    notifyListeners();
  }
}
