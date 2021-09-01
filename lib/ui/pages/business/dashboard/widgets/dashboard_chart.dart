import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/sales_model.dart';
import 'package:flutter_bzaru/providers/business/m_dashboard_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class DashboardChart extends StatefulWidget {
  final String lang;

  const DashboardChart({Key key, this.lang}) : super(key: key);
  @override
  _DashboardChartState createState() => _DashboardChartState();
}

class _DashboardChartState extends State<DashboardChart> {
  List<charts.Series> seriesList;
  ValueNotifier<int> currentMonthView = ValueNotifier<int>(1);
  ValueNotifier<int> currentProdViewByCount = ValueNotifier<int>(10101);
  ValueNotifier<int> _mainCategoryView = ValueNotifier<int>(100);
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  String langCode;

  List<Sales> salesData = [];

  @override
  void initState() {
    super.initState();
    getSalesDashboard(1);
  }

  @override
  void dispose() {
    currentMonthView.dispose();
    _mainCategoryView.dispose();
    currentProdViewByCount.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  void getSalesDashboard(int forMonths) async {
    _isLoading.value = true;
    langCode = langCode ?? await SharedPrefrenceHelper().getLanguageCode();
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getDashboardSales(forMonths);
    seriesList = _createSalesData(state.salesData);
    _isLoading.value = false;
  }

  void getCustomersListAnalytics() async {
    _isLoading.value = true;
    langCode = langCode ?? await SharedPrefrenceHelper().getLanguageCode();
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getCustomersListAnalytics();
    seriesList = _createUniqueCustomerData(state.uniqueCustomerCount);
    _isLoading.value = false;
  }

  void getTopProductsByCount() async {
    _isLoading.value = true;
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getTopProductsByCount();
    seriesList = _createProductDataByCount(state.topProductSales);
    _isLoading.value = false;
  }

  void getWorstProductsByCount() async {
    _isLoading.value = true;
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getWorstProductsByCount();
    seriesList = _createProductDataByCount(state.worstProductSales);
    _isLoading.value = false;
  }

  void getTopProductsBySales() async {
    _isLoading.value = true;
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getTopProductBySales();
    seriesList = _createProductDataBySales(state.topProductSales);
    _isLoading.value = false;
  }

  void getWorstProductsBySales() async {
    _isLoading.value = true;
    final state = Provider.of<MDashboardState>(context, listen: false);
    await state.getWorstProductBySales();
    seriesList = _createProductDataBySales(state.worstProductSales);
    _isLoading.value = false;
  }

  List<charts.Series<Sales, String>> _createSalesData(List<Sales> data) {
    return [
      charts.Series<Sales, String>(
        id: "Sales",
        domainFn: (Sales sales, _) => sales.month,
        measureFn: (Sales sales, _) => sales.sales,
        data: data,
        colorFn: (datum, index) =>
            charts.ColorUtil.fromDartColor(KColors.graphColor),
      )
    ];
  }

  List<charts.Series<ProdSales, String>> _createProductDataByCount(
      List<ProdSales> data) {
    return [
      charts.Series<ProdSales, String>(
        id: "TopProdSales",
        domainFn: (ProdSales sales, _) => sales.prodTitle,
        measureFn: (ProdSales sales, _) => sales.salesCount,
        data: data,
        colorFn: (datum, index) =>
            charts.ColorUtil.fromDartColor(KColors.graphColor),
      )
    ];
  }

  List<charts.Series<ProdSales, String>> _createProductDataBySales(
      List<ProdSales> data) {
    return [
      charts.Series<ProdSales, String>(
        id: "WorstProdSales",
        domainFn: (ProdSales sales, _) => sales.prodTitle,
        measureFn: (ProdSales sales, _) => sales.salesAmount,
        data: data,
      )
    ];
  }

  List<charts.Series<CustomerCount, String>> _createUniqueCustomerData(
      List<CustomerCount> data) {
    return [
      charts.Series<CustomerCount, String>(
        id: "Sales",
        domainFn: (CustomerCount count, _) => count.month,
        measureFn: (CustomerCount count, _) => count.count,
        data: data,
        colorFn: (datum, index) =>
            charts.ColorUtil.fromDartColor(KColors.graphColor),
      )
    ];
  }

  Widget barChart() {
    return charts.BarChart(
      seriesList,
      animate: true,
      vertical: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig.init(context);
    final locale = AppLocalizations.of(context);

    return Consumer<MDashboardState>(
      builder: (context, state, _) {
        return Container(
          height: sizeConfig.safeHeight * 60,
          padding: EdgeInsets.all(5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildMainDropDown(),
              _buildSubDropDown(),
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) => isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ValueListenableBuilder(
                          valueListenable: _mainCategoryView,
                          builder: (context, mainCategory, child) {
                            final model = state.mainCategory.firstWhere(
                                (element) => element.id == mainCategory);

                            if (model.hasSubCategories) {
                              if (model.id == 100) {
                                return state.salesData != null &&
                                        state.salesData.isNotEmpty
                                    ? state.salesData.length <
                                            currentMonthView.value
                                        ? Center(
                                            child: BText(
                                              langCode != null &&
                                                      langCode.isNotEmpty
                                                  ? langCode == "en"
                                                      ? "No data available for ${currentMonthView.value} months"
                                                      : "${currentMonthView.value} महीने के लिए कोई डेटा उपलब्ध नहीं है"
                                                  : "No data available for ${currentMonthView.value} months",
                                              variant: TypographyVariant.h1,
                                            ),
                                          )
                                        : barChart()
                                    : Center(
                                        child: BText(
                                          locale.getTranslatedValue(
                                              KeyConstants.noDataAvaialble),
                                          variant: TypographyVariant.h1,
                                        ),
                                      );
                              } else {
                                return model.id == 101
                                    ? state.topProductSales != null &&
                                            state.topProductSales.isNotEmpty
                                        ? barChart()
                                        : Center(
                                            child: BText(
                                              locale.getTranslatedValue(
                                                  KeyConstants.noDataAvaialble),
                                              variant: TypographyVariant.h1,
                                            ),
                                          )
                                    : state.worstProductSales != null &&
                                            state.worstProductSales.isNotEmpty
                                        ? barChart()
                                        : Center(
                                            child: BText(
                                              locale.getTranslatedValue(
                                                  KeyConstants.noDataAvaialble),
                                              variant: TypographyVariant.h1,
                                            ),
                                          );
                              }
                            } else {
                              return barChart();
                            }
                          },
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMainDropDown() {
    final state = Provider.of<MDashboardState>(context, listen: false);
    final locale = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        BText(
          "${locale.getTranslatedValue(KeyConstants.chooseAnOption)}: ",
          variant: TypographyVariant.h1,
        ),
        ValueListenableBuilder(
          valueListenable: _mainCategoryView,
          builder: (context, mainCategory, child) => Container(
            width: sizeConfig.safeWidth * 32,
            child: DropdownButton<int>(
              underline: SizedBox(),
              isExpanded: true,
              iconEnabledColor: KColors.businessPrimaryColor,
              icon: Icon(Icons.keyboard_arrow_down),
              value: mainCategory,
              style: TextStyle(
                color: KColors.businessPrimaryColor,
                fontWeight: FontWeight.w500,
                fontSize: 16,
                height: 1.0,
                fontFamily: 'Roboto',
              ),
              dropdownColor: Colors.white,
              items: state.mainCategory != null
                  ? state.mainCategory
                      .map(
                        (model) => DropdownMenuItem(
                          child: BText(
                            langCode != null && langCode.isNotEmpty
                                ? model.lang[langCode]
                                : model.title,
                            variant: TypographyVariant.h1,
                            overflow: TextOverflow.visible,
                            style: TextStyle(
                              color: KColors.businessPrimaryColor,
                            ),
                          ),
                          value: model.id,
                        ),
                      )
                      .toList()
                  : [],
              onChanged: (int value) async {
                if (value != _mainCategoryView.value) {
                  _mainCategoryView.value = value;

                  switch (value) {
                    case 101:
                      getTopProductsByCount();
                      currentProdViewByCount.value = 10101;
                      break;
                    case 102:
                      getWorstProductsByCount();
                      currentProdViewByCount.value = 10101;
                      break;
                    case 103:
                      getCustomersListAnalytics();
                      break;
                  }
                }
              },
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSubDropDown() {
    final state = Provider.of<MDashboardState>(context, listen: false);

    return ValueListenableBuilder(
      valueListenable: _mainCategoryView,
      builder: (context, mainCategory, child) {
        final model = state.mainCategory
            .firstWhere((element) => element.id == mainCategory);
        final title = langCode != null && langCode.isNotEmpty
            ? model.lang[langCode]
            : model.title;

        return model.hasSubCategories
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BText(
                    "$title: " ?? "Sales Record: ", //TODO: Add locale
                    variant: TypographyVariant.h1,
                  ),
                  ValueListenableBuilder(
                    valueListenable: currentMonthView,
                    builder: (context, monthValue, child) =>
                        ValueListenableBuilder(
                      valueListenable: currentProdViewByCount,
                      builder: (context, countViewValue, child) => Container(
                        width: sizeConfig.safeWidth * 32,
                        child: DropdownButton<int>(
                          underline: SizedBox(),
                          isExpanded: true,
                          iconEnabledColor: KColors.businessPrimaryColor,
                          icon: Icon(Icons.keyboard_arrow_down),
                          value: model.id == 100 ? monthValue : countViewValue,
                          style: TextStyle(
                            color: KColors.businessPrimaryColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            height: 1.0,
                            fontFamily: 'Roboto',
                          ),
                          dropdownColor: Colors.white,
                          items: model.id == 100
                              ? state.salesRecordCategory != null
                                  ? state.salesRecordCategory
                                      .map(
                                        (model) => DropdownMenuItem(
                                          child: BText(
                                            langCode != null &&
                                                    langCode.isNotEmpty
                                                ? model.lang[langCode]
                                                : model.title,
                                            variant: TypographyVariant.h1,
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(
                                              color:
                                                  KColors.businessPrimaryColor,
                                            ),
                                          ),
                                          value: model.id,
                                        ),
                                      )
                                      .toList()
                                  : []
                              : state.prodRecordCategory != null
                                  ? state.prodRecordCategory.map((model) {
                                      return DropdownMenuItem(
                                        child: BText(
                                          langCode != null &&
                                                  langCode.isNotEmpty
                                              ? model.lang[langCode]
                                              : model.title,
                                          variant: TypographyVariant.h1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: KColors.businessPrimaryColor,
                                          ),
                                        ),
                                        value: model.id,
                                      );
                                    }).toList()
                                  : [],
                          onChanged: (int value) async {
                            switch (model.id) {
                              case 100:
                                if (value != currentMonthView.value) {
                                  currentMonthView.value = value;
                                  getSalesDashboard(value);
                                }
                                break;

                              case 101:
                                currentProdViewByCount.value = value;
                                if (value == 10101) {
                                  getTopProductsByCount();
                                } else {
                                  getTopProductsBySales();
                                }
                                break;
                              case 102:
                                currentProdViewByCount.value = value;
                                if (value == 10101) {
                                  getWorstProductsByCount();
                                } else {
                                  getWorstProductsBySales();
                                }
                                break;
                            }
                          },
                        ),
                      ),
                    ),
                  )
                ],
              )
            : SizedBox();
      },
    );
  }
}
