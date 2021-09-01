import 'dart:convert';

class AdsModel {
  final int id;
  final String imageUrl;

  AdsModel({this.id, this.imageUrl});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
    };
  }

  factory AdsModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return AdsModel(
      id: map['id'],
      imageUrl: map['imageUrl'],
    );
  }

  String toJson() => json.encode(toMap());

  factory AdsModel.fromJson(String source) =>
      AdsModel.fromMap(json.decode(source));
}
