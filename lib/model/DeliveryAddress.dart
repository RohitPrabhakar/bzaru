class DeliveryAddress {
  String _placeName;
  String _phoneNo;
  String _houseNo;
  String _landmark;
  String _lat;
  String _lng;
  String _addressline1;
  String _addressline2;

  DeliveryAddress(
      {String placeName,
        String phoneNo,
        String houseNo,
        String landmark,
        String lat,
        String lng,
        String addressline1,
        String addressline2}) {
    this._placeName = placeName;
    this._phoneNo = phoneNo;
    this._houseNo = houseNo;
    this._landmark = landmark;
    this._lat = lat;
    this._lng = lng;
    this._addressline1 = addressline1;
    this._addressline2 = addressline2;
  }

  String get placeName => _placeName;
  set placeName(String placeName) => _placeName = placeName;
  String get phoneNo => _phoneNo;
  set phoneNo(String phoneNo) => _phoneNo = phoneNo;
  String get houseNo => _houseNo;
  set houseNo(String houseNo) => _houseNo = houseNo;
  String get landmark => _landmark;
  set landmark(String landmark) => _landmark = landmark;
  String get lat => _lat;
  set lat(String lat) => _lat = lat;
  String get lng => _lng;
  set lng(String lng) => _lng = lng;
  String get addressline1 => _addressline1;
  set addressline1(String addressline1) => _addressline1 = addressline1;
  String get addressline2 => _addressline2;
  set addressline2(String addressline2) => _addressline2 = addressline2;

  DeliveryAddress.fromJson(Map<String, dynamic> json) {
    _placeName = json['place_name'];
    _phoneNo = json['phone_no'];
    _houseNo = json['house_no'];
    _landmark = json['landmark'];
    _lat = json['lat'];
    _lng = json['lng'];
    _addressline1 = json['addressline1'];
    _addressline2 = json['addressline2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['place_name'] = this._placeName;
    data['phone_no'] = this._phoneNo;
    data['house_no'] = this._houseNo;
    data['landmark'] = this._landmark;
    data['lat'] = this._lat;
    data['lng'] = this._lng;
    data['addressline1'] = this._addressline1;
    data['addressline2'] = this._addressline2;
    return data;
  }
}
