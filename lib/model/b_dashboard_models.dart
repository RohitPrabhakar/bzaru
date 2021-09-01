class BSalesModel {
  final int id;
  final String title;
  final Map<String, String> lang;
  final bool hasSubCategories;

  BSalesModel({
    this.id,
    this.title,
    this.lang,
    this.hasSubCategories,
  });
}

class BProdSalesModel {
  final String id;
  final String prodTitle;
  double sales;
  int count;

  BProdSalesModel({
    this.id,
    this.prodTitle,
    this.count,
    this.sales,
  });
}
