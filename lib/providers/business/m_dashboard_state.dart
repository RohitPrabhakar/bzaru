import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/b_dashboard_models.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/bussiness_repository.dart';

class MDashboardState extends BaseState {
  List<Sales> _salesData = [];
  List<ProdSales> _topProductSales = [];
  List<ProdSales> _worstProductSales = [];
  List<CustomerCount> _uniqueCustomerCount = [];

  List<Sales> get salesData => _salesData;
  List<ProdSales> get topProductSales => _topProductSales;
  List<ProdSales> get worstProductSales => _worstProductSales;
  List<BSalesModel> get salesRecordCategory => _salesRecordCategory;
  List<BSalesModel> get prodRecordCategory => _prodRecordCategory;
  List<BSalesModel> get mainCategory => _mainCategory;
  List<CustomerCount> get uniqueCustomerCount => _uniqueCustomerCount;

  List<BSalesModel> _mainCategory = [
    BSalesModel(
      id: 100,
      title: "Sales Record",
      lang: {
        "en": "Sales Record",
        "hi": "बिक्री रिकॉर्ड",
      },
      hasSubCategories: true,
    ),
    BSalesModel(
      id: 101,
      title: "Top 5 products",
      lang: {
        "en": "Top 5 products",
        "hi": "शीर्ष 5 उत्पाद",
      },
      hasSubCategories: true,
    ),
    BSalesModel(
      id: 102,
      title: "Worst 5 products",
      lang: {"en": "Worst 5 products", "hi": "सबसे खराब 5 उत्पाद"},
      hasSubCategories: true,
    ),
    BSalesModel(
      id: 103,
      title: "Unique customer count",
      lang: {
        "en": "Unique customer count",
        "hi": "अद्वितीय ग्राहक गणना",
      },
      hasSubCategories: false,
    ),
  ];

  List<BSalesModel> _prodRecordCategory = [
    BSalesModel(
      id: 10101,
      title: "Sort by count",
      lang: {
        "en": "Sort by count",
        "hi": "गिनती के आधार पर छाँटें",
      },
    ),
    BSalesModel(
      id: 10102,
      title: "Sort by price",
      lang: {
        "en": "Sort by price",
        "hi": "मूल्य के आधार पर छाँटें",
      },
    ),
  ];

  List<BSalesModel> _salesRecordCategory = [
    BSalesModel(
      id: 1,
      title: "1 month",
      lang: {
        "en": "1 month",
        "hi": "1 महीना",
      },
    ),
    BSalesModel(
      id: 3,
      title: "3 months",
      lang: {
        "en": "3 months",
        "hi": "3 महीने",
      },
    ),
    BSalesModel(
      id: 6,
      title: "6 months",
      lang: {"en": "6 months", "hi": "6 महीने"},
    ),
    BSalesModel(
      id: 9,
      title: "9 months",
      lang: {
        "en": "9 months",
        "hi": "9 महीने",
      },
    ),
    BSalesModel(
      id: 12,
      title: "12 months",
      lang: {"en": "12 months", "hi": "12 महीने"},
    ),
  ];

  Future<void> getDashboardSales(int forMonths) async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    _salesData.clear();

    final allSalesData = await execute(() async {
      return await repo.getSalesDashboard(merchantId, forMonths);
    }, label: "getSalesDashboard");

    if (allSalesData != null) {
      _salesData = List.from(allSalesData);
    }
    notifyListeners();
  }

  Future<void> getTopProductsByCount() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    _topProductSales.clear();

    final list = await execute(() async {
      return await repo.getProductsByCount(merchantId);
    }, label: "getTopProductsByCount");

    if (list != null) {
      list.sort((a, b) => b.count.compareTo(a.count));
      final List<BProdSalesModel> tempList = List<BProdSalesModel>.from(list)
        ..length = list.length > 5 ? 5 : list.length;
      tempList.forEach((prod) {
        _topProductSales.add(ProdSales(
          prodTitle: prod.prodTitle.length > 8
              ? "${prod.prodTitle.substring(0, 8)}..."
              : prod.prodTitle,
          salesCount: prod.count,
        ));
      });
    }
    notifyListeners();
  }

  Future<void> getWorstProductsByCount() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    print("GETT??? ");
    _worstProductSales.clear();

    final list = await execute(() async {
      return await repo.getProductsByCount(merchantId);
    }, label: "getWorstProductsByCount");

    if (list != null) {
      list.sort((a, b) => a.count.compareTo(b.count));
      final List<BProdSalesModel> tempList = List<BProdSalesModel>.from(list)
        ..length = list.length > 5 ? 5 : list.length;
      tempList.forEach((prod) {
        _worstProductSales.add(ProdSales(
          prodTitle: prod.prodTitle.length > 8
              ? "${prod.prodTitle.substring(0, 8)}..."
              : prod.prodTitle,
          salesCount: prod.count,
        ));
      });
    }
    notifyListeners();
  }

  Future<void> getTopProductBySales() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    _topProductSales.clear();

    final list = await execute(() async {
      return await repo.getProductBySales(merchantId);
    }, label: "getTopProductBySales");

    if (list != null) {
      list.sort((a, b) => b.sales.compareTo(a.sales));
      final List<BProdSalesModel> tempList = List<BProdSalesModel>.from(list)
        ..length = list.length > 5 ? 5 : list.length;
      tempList.forEach((prod) {
        print("SALES AMOUNT-> ${prod.sales}");
        _topProductSales.add(ProdSales(
          prodTitle: prod.prodTitle.length > 8
              ? "${prod.prodTitle.substring(0, 8)}..."
              : prod.prodTitle,
          salesAmount: prod.sales,
        ));
      });
    }
    notifyListeners();
  }

  Future<void> getWorstProductBySales() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    print("GETT??? ");
    _worstProductSales.clear();

    final list = await execute(() async {
      return await repo.getProductBySales(merchantId);
    }, label: "getWorstProductBySales");

    if (list != null) {
      list.sort((a, b) => a.sales.compareTo(b.sales));
      final List<BProdSalesModel> tempList = List<BProdSalesModel>.from(list)
        ..length = list.length > 5 ? 5 : list.length;
      tempList.forEach((prod) {
        _worstProductSales.add(ProdSales(
          prodTitle: prod.prodTitle.length > 8
              ? "${prod.prodTitle.substring(0, 8)}..."
              : prod.prodTitle,
          salesAmount: prod.sales,
        ));
      });
    }
    notifyListeners();
  }

  Future<void> getCustomersListAnalytics() async {
    final repo = getit.get<BussinessRepository>();
    final pref = getit.get<SharedPrefrenceHelper>();
    String merchantId = await pref.getAccessToken();
    print("GET CUSTOMERLIST ");
    _worstProductSales.clear();

    final list = await execute(() async {
      return await repo.getCustomersListAnalytics(merchantId);
    }, label: "getCustomersListAnalytics");

    if (list != null) {
      _uniqueCustomerCount = List.from(list);
      list.forEach((element) {
        print(element.date);
        print(element.month);
        print(element.count);
        print("=================================");
      });
    }
    notifyListeners();
  }
}
