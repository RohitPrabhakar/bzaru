import 'dart:convert';

class CustomerProfile {
    CustomerProfile({
        this.id,
        this.avatar,
        this.firstName,
        this.lastName,
        this.email,
        this.contactPrimary,
        this.contactSecondary,
        this.createdAt,
    });
    String id;
    final String avatar;
    final String firstName;
    final String lastName;
    final String email;
    final String contactPrimary;
    final String contactSecondary;
    final DateTime createdAt;

    factory CustomerProfile.fromRawJson(String str) => CustomerProfile.fromJson(json.decode(str));

    String toRawJson() => json.encode(toJson());

    factory CustomerProfile.fromJson(Map<String, dynamic> json) => CustomerProfile(
        id: json["id"] == null ? null : json["id"],
        firstName: json["firstName"] == null ? null : json["firstName"],
        lastName: json["lastName"] == null ? null : json["lastName"],
        email: json["email"] == null ? null : json["email"],
        contactPrimary: json["contactPrimary"] == null ? null : json["contactPrimary"],
        contactSecondary: json["contactSecondary"] == null ? null : json["contactSecondary"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "firstName": firstName == null ? null : firstName,
        "lastName": lastName == null ? null : lastName,
        "email": email == null ? null : email,
        "contactPrimary": contactPrimary == null ? null : contactPrimary,
        "contactSecondary": contactSecondary == null ? null : contactSecondary,
        "createdAt": createdAt == null ? null : createdAt.toIso8601String(),
    };
}
