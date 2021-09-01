import 'dart:convert';

class TermsConditionModel {
  final String userName;
  final String phoneNumber;
  final String email;
  final String acceptDate;
  final String termsAndCondition;

  TermsConditionModel({
    this.userName,
    this.phoneNumber,
    this.email,
    this.acceptDate,
    this.termsAndCondition,
  });

  TermsConditionModel copyWith({
    String userName,
    String phoneNumber,
    String email,
    String acceptDate,
    String termsAndCondition,
  }) {
    return TermsConditionModel(
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      acceptDate: acceptDate ?? this.acceptDate,
      termsAndCondition: termsAndCondition ?? this.termsAndCondition,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'phoneNumber': phoneNumber,
      'email': email,
      'acceptDate': acceptDate,
      'termsAndCondition': termsAndCondition,
    };
  }

  factory TermsConditionModel.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return TermsConditionModel(
      userName: map['userName'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      acceptDate: map['acceptDate'],
      termsAndCondition: map['termsAndCondition'],
    );
  }

  @override
  String toString() {
    return 'TermsConditionModel(userName: $userName, phoneNumber: $phoneNumber, email: $email, acceptDate: $acceptDate, termsAndCondition: $termsAndCondition)';
  }
}
