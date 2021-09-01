import 'dart:convert';

class HelpModel {
  final String title;
  final String redirectUrl;

  HelpModel({
    this.title,
    this.redirectUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'redirectUrl': redirectUrl,
    };
  }

  factory HelpModel.fromJson(Map<String, dynamic> map) {
    return HelpModel(
      title: map['title'],
      redirectUrl: map['redirectUrl'],
    );
  }
}
