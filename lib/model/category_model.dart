class CategoryModel {
  final String category;
  final Map<String, String> lang;

  CategoryModel({this.category, this.lang});

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'lang': lang,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return CategoryModel(
      category: map['category'],
      lang: Map<String, String>.from(map['lang']),
    );
  }
}
