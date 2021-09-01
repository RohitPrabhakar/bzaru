import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/ads_model.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:flutter_bzaru/resource/repository/repository.dart';

class ProfileState extends BaseState {
  List<TimingModel> timingsList = TimingModel.timingList();
  List<TimingModel> tempTimingsList = TimingModel
      .timingList(); //TO SAVE IMINGS MODEL TEMPORARY, IF THE USER DIDNT SAVE IT

  UserRole _selectedProfile = UserRole.CUSTOMER;
  UserRole _primaryProfile = UserRole.CUSTOMER;
  ProfileModel _customerProfileModel;
  ProfileModel _merchantProfileModel;
  List<AdsModel> _customerAdsList = [];
  List<ArticlesModel> _customerArticlesList = [];
  List<ArticlesModel> _merchantArticlesList = [];

  //!------------------------------->>>>>>>

  UserRole get selectedProfile => _selectedProfile;
  UserRole get primaryProfile => _primaryProfile;
  ProfileModel get customerProfileModel => _customerProfileModel;
  ProfileModel get merchantProfileModel => _merchantProfileModel;
  List<AdsModel> get customerAdsList => _customerAdsList;
  List<ArticlesModel> get customerArticlesList => _customerArticlesList;
  List<ArticlesModel> get merchantArticlesList => _merchantArticlesList;

  void updateTimeingHours(TimingModel timingModel) {
    timingsList[timingModel.index] = timingModel;
    notifyListeners();
  }

  // void saveMerchantTimingHours() {
  //   timingsList = List.from(tempTimingsList);
  //   notifyListeners();
  // }

  void clearTimingHours() {
    timingsList = List.from(tempTimingsList);
    notifyListeners();
  }

  void setSelectedProfile(UserRole role) {
    _selectedProfile = role;
    notifyListeners();
  }

  void setUserProfile(ProfileModel profileModel) {
    _customerProfileModel = profileModel;
    notifyListeners();
  }

  void setPrimaryProfile(UserRole role) {
    _primaryProfile = role;
    print("Primary Profile $role");
    SharedPrefrenceHelper().setPrimaryProfile(role.toString());
    notifyListeners();
  }

  Future getCustomerProfile() async {
    final repo = getit.get<Repository>();
    isBusy = true;
    _customerProfileModel = await execute(() async {
      return await repo.getUserProfile(role: UserRole.CUSTOMER);
    }, label: "getProfile");
    isBusy = false;
    notifyListeners();
  }

  Future getMerchantProfile() async {
    try {
      final repo = getit.get<Repository>();
      isBusy = true;
      _merchantProfileModel = await execute(() async {
        return await repo.getUserProfile(role: UserRole.MERCHANT);
      }, label: "getMerchantProfile");
      isBusy = false;
      print("MERCHANT ID FROM -> ${_merchantProfileModel.id}");
      notifyListeners();
    } catch (e) {
      _merchantProfileModel = null;
    }
  }

  Future updateProfile(ProfileModel model) async {
    final repo = getit.get<Repository>();
    isBusy = true;
    await execute(() async {
      await repo.updateProfile(model);
      if (model.role == UserRole.CUSTOMER) {
        _customerProfileModel = model;
      } else {
        _merchantProfileModel = model;
      }
    }, label: "updateProfile");
    isBusy = false;
    notifyListeners();
  }

  Future updateMerchantTimings(List<TimingModel> timings) async {
    final repo = getit.get<BussinessRepository>();
    isBusy = true;
    final merchantId = merchantProfileModel.id;
    print(merchantId);
    await execute(() async {
      await repo.updateMerchantTimings(timings, merchantId);
    }, label: "updateMerchantTimings");
    isBusy = false;
    notifyListeners();
  }

  Future getMerchantTimings() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    isBusy = true;
    final list = await execute(() async {
      return await repo.getMerchantTimings(merchantId);
    }, label: "getMerchantProductList");
    if (list != null) {
      list.sort((a, b) => a.index.compareTo(b.index));
      timingsList = list;
      tempTimingsList = list;
    }
    isBusy = false;
  }

  Future getCustomerArticles() async {
    final repo = getit.get<CustomerRepository>();
    isBusy = true;
    if (customerProfileModel.articles != null &&
        customerProfileModel.articles.isNotEmpty) {
      final list = await execute(() async {
        return await repo.getCustomerArticles(customerProfileModel.articles);
      }, label: "getCustomerArticles");
      if (list != null) {
        _customerArticlesList = List.from(list);
      }
    }
    isBusy = false;
    notifyListeners();
  }

  Future getMerchantArticles() async {
    final repo = getit.get<BussinessRepository>();
    isBusy = true;
    if (merchantProfileModel.articles != null &&
        merchantProfileModel.articles.isNotEmpty) {
      final list = await execute(() async {
        return await repo.getMerchantArticles(merchantProfileModel.articles);
      }, label: "getMerchantArticles");
      if (list != null) {
        _merchantArticlesList = List.from(list);
      }
    }
    isBusy = false;
    notifyListeners();
  }

  Future getAds() async {
    final repo = getit.get<CustomerRepository>();
    isBusy = true;
    if (customerProfileModel.ads != null &&
        customerProfileModel.ads.isNotEmpty) {
      final list = await execute(() async {
        return await repo.getAds(customerProfileModel.ads);
      }, label: "getAds");
      if (list != null) {
        _customerAdsList = List.from(list);
      }
    }
    isBusy = false;
    notifyListeners();
  }
}
