class Sales {
  final String date;
  final double sales;
  final String month;

  Sales({
    this.date,
    this.sales,
    this.month,
  });
}

class ProdSales {
  final int salesCount;
  final String prodTitle;
  final double salesAmount;

  ProdSales({
    this.salesCount,
    this.prodTitle,
    this.salesAmount,
  });
}

class CustomerCount {
  final String date;
  int count;
  final String month;

  CustomerCount({
    this.date,
    this.count,
    this.month,
  });
}
