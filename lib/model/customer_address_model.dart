class CustomerAddressModel {
  final String id;
  final String fullName;
  final String address1;
  final String address2;
  final String city;
  final String state;
  final String country;
  final String pinCode;
  final String mobileNumber;
  final double latitude;
  final double longitude;
  final String shopNumber;
  final String landmark;

  CustomerAddressModel(
      {this.id,
      this.fullName,
      this.address1,
      this.address2,
      this.city,
      this.state,
      this.country,
      this.pinCode,
      this.mobileNumber,
      this.latitude,
      this.longitude,
      this.landmark,
      this.shopNumber});

  CustomerAddressModel copyWith(
      {String id,
      String fullName,
      String address1,
      String address2,
      String city,
      String state,
      String country,
      String pinCode,
      String mobileNumber,
      double latitude,
      double longitude,
      final String shopNumber,
      final String landmark}) {
    return CustomerAddressModel(
        id: id ?? this.id,
        fullName: fullName ?? this.fullName,
        address1: address1 ?? this.address1,
        address2: address2 ?? this.address2,
        city: city ?? this.city,
        state: state ?? this.state,
        country: country ?? this.country,
        pinCode: pinCode ?? this.pinCode,
        mobileNumber: mobileNumber ?? this.mobileNumber,
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        landmark: landmark ?? this.landmark,
    shopNumber: shopNumber??this.shopNumber);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'address1': address1,
      'address2': address2,
      'city': city,
      'state': state,
      'country': country,
      'pinCode': pinCode,
      'mobileNumber': mobileNumber,
      'latitude': latitude,
      'longitude': longitude,
      'shopNumber':shopNumber,
      'landMark':landmark
    };
  }

  factory CustomerAddressModel.fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return CustomerAddressModel(
      id: map['id'],
      fullName: map['fullName'],
      address1: map['address1'],
      address2: map['address2'],
      city: map['city'],
      state: map['state'],
      country: map['country'],
      pinCode: map['pinCode'],
      mobileNumber: map['mobileNumber'],
      latitude: map['latitude'],
      longitude: map['longitude'],
      landmark: map['landMark'],
      shopNumber: map['shopNumber']
    );
  }

  @override
  String toString() {
    return 'CustomerAddressModel(id: $id, fullName: $fullName, address1: $address1, address2: $address2, city: $city, state: $state, country: $country, pinCode: $pinCode, mobileNumber: $mobileNumber)';
  }
}
