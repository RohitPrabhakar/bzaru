import 'dart:convert';

import 'package:flutter_bzaru/helper/enum.dart';

class ArticlesModel {
  final int id;
  final String imageUrl;
  final UserRole role;
  final String title;
  final String onClickUrl;
  final Map<String, String> lang;

  ArticlesModel({
    this.id,
    this.imageUrl,
    this.role,
    this.title,
    this.onClickUrl,
    this.lang,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imageUrl': imageUrl,
      'role': role.toString(),
      'title': title,
      'onClickUrl': onClickUrl,
      'lang': lang,
    };
  }

  factory ArticlesModel.fromMap(Map<String, dynamic> map) {
    if (map == null) return null;

    return ArticlesModel(
      id: map['id'],
      imageUrl: map['imageUrl'],
      role: TypeOfSearch.fromString(map['role']),
      title: map['title'],
      onClickUrl: map['onClickUrl'],
      lang: Map<String, String>.from(map['lang']),
    );
  }

  String toJson() => json.encode(toMap());

  factory ArticlesModel.fromJson(String source) =>
      ArticlesModel.fromMap(json.decode(source));
}
