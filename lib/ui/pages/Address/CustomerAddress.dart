import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_bzaru/helper/utility.dart';

import 'package:flutter_bzaru/model/DeliveryAddress.dart';
import 'package:flutter_bzaru/model/places.dart';
import 'package:flutter_bzaru/model/places_search.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/resource/services/GoogleMapServices/PlacesService.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/pages/common/profile/helper/profile_helpers.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text_field.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:google_maps_webservice/places.dart';
import 'package:provider/provider.dart';

class CustomerAddress extends StatefulWidget {
  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(builder: (_) => CustomerAddress());
  }

  @override
  _CustomerAddressState createState() => _CustomerAddressState();
}

class _CustomerAddressState extends State<CustomerAddress> {
  Completer<GoogleMapController> _controller = Completer();
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  LatLng currentPostion;
  LatLng markerPosition;

  ScrollController _scrollController = new ScrollController();
  var firstLineText = 'Fetching location......';
  var secondLineText = 'Fetching location......';
  TextEditingController _shopNumberController = TextEditingController();
  TextEditingController _landMarkController = TextEditingController();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneNoController = TextEditingController();
  final placesService = PlacesService();

  List<PlaceSearch> searchResult;

  var _searchController = TextEditingController();

  DeliveryAddress parseAddress = DeliveryAddress();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  searchPlaces({String searchText}) async {
    searchResult = await placesService.getAutocomplete(searchText);
    if (searchResult != null) {
      if (searchResult.isEmpty) {
        this.setState(() {
          searchResult = null;
        });
      } else {
        this.setState(() {
          searchResult = searchResult;
        });
      }
    }
  }

  void updateProfile() async {
    final locale = AppLocalizations.of(context);

    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      final state = Provider.of<ProfileState>(context, listen: false);
      List<DeliveryAddress> addresses = [];
      try{
        addresses.addAll(state.customerProfileModel.deliveryAddress);

      }catch(e){
        print(e);
      }
      addresses.add(parseAddress);

      ProfileModel model =
          state.customerProfileModel.copyWith(deliveryAddress: addresses);

      loading.value = true;

      /// upload profile to firebase storage

      await state.updateProfile(model);
      await state.updateMerchantTimings(state.timingsList);

      await state.getMerchantProfile();
      await state.getMerchantTimings();

      Navigator.pop(context, "Profile updated successfully");
      // BNavigation.popNavigate(context);

      loading.value = false;
    }
  }

  searchData(String id) async {
    Place places = await placesService.getPlace(id);

    this.setState(() {
      markerPosition =
          LatLng(places.geometry.location.lat, places.geometry.location.lng);
      secondLineText = places.name;
    });

    _goToPlace(places);
  }

  setLocation(LatLng newPosition) async {
    var addresses = await Geocoder.google(Constants.kGoogleApiKey)
        .findAddressesFromCoordinates(
            Coordinates(newPosition.latitude, newPosition.longitude));
    var first = addresses.first;
    print(
        ' ${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}');
    this.setState(() {
      firstLineText =
          '${first.locality}, ${first.adminArea},${first.subLocality}';
      secondLineText = '${first.addressLine}, ${first.featureName}';
    });
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      currentPostion = LatLng(position.latitude, position.longitude);
      if (markerPosition == null) {
        markerPosition = currentPostion;
        setLocation(currentPostion);
      }
    });
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getUserLocation();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: Duration(milliseconds: 200),
              curve: Curves.fastOutSlowIn,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.location),
        bgColor: KColors.customerPrimaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  children: [
                    currentPostion == null
                        ? SizedBox(
                            child: Center(child: Text("Map Loading")),
                          )
                        : GoogleMap(
                            zoomControlsEnabled: false,
                            mapType: MapType.normal,
                            myLocationButtonEnabled: true,
                            myLocationEnabled: true,
                            onMapCreated: (GoogleMapController controller) {
                              _controller.complete(controller);
                            },
                            initialCameraPosition: CameraPosition(
                              target: markerPosition == null
                                  ? currentPostion
                                  : markerPosition,
                              zoom: 10,
                            ),
                            markers: Set<Marker>.of(
                              <Marker>[
                                Marker(
                                    onTap: () {
                                      print('Tapped');
                                    },
                                    draggable: true,
                                    icon: BitmapDescriptor.defaultMarkerWithHue(
                                        BitmapDescriptor.hueOrange),
                                    markerId: MarkerId('Marker'),
                                    position: markerPosition,
                                    onDragEnd: ((LatLng newPosition) async {
                                      this.setState(() {
                                        markerPosition = newPosition;
                                      });

                                      setLocation(newPosition);
                                    }))
                              ],
                            ),
                          ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Column(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            margin: EdgeInsets.only(
                                left: MediaQuery.of(context).size.width / 10,
                                right: MediaQuery.of(context).size.width / 10,
                                top: MediaQuery.of(context).size.width / 15),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0.0, 1.0), //(x,y)
                                    blurRadius: 6.0,
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: KColors.customerPrimaryColor,
                                  size: 30,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    onChanged: (text) {
                                      searchPlaces(searchText: text);
                                    },
                                    decoration: InputDecoration.collapsed(
                                        hintText: "Search Location"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          searchResult != null
                              ? Container(
                                  height: 150,
                                  width: MediaQuery.of(context).size.width * 6,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 5),
                                  color: Colors.white,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: searchResult.length,
                                    itemBuilder: (context, index) {
                                      return GestureDetector(
                                        onTap: () {
                                          this.setState(() {
                                            firstLineText =
                                                searchResult[index].description;
                                            _searchController.text = "";
                                            searchData(
                                                searchResult[index].placeId);
                                            searchResult = null;
                                          });
                                        },
                                        child: ListTile(
                                          title: Text(
                                              '${searchResult[index].description}'),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : SizedBox()
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Select your store address',
                          style: TextStyle(
                              color: Colors.black54,
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text("$firstLineText"),
                        SizedBox(
                          height: 10,
                        ),
                        Text("$secondLineText"),
                        SizedBox(
                          height: 20,
                        ),
                        BTextField(
                            controller: _nameController,
                            choice: Labels.address,
                            borderColor: KColors.customerPrimaryColor,
                            hintText: "Name"),
                        BTextField(
                            controller: _phoneNoController,
                            choice: Labels.phone,
                            borderColor: KColors.customerPrimaryColor,
                            hintText: "Phone number"),
                        BTextField(
                            controller: _shopNumberController,
                            choice: Labels.address,
                            borderColor: KColors.customerPrimaryColor,
                            hintText: "Shop number/ Colony Number"),
                        BTextField(
                          controller: _landMarkController,
                          choice: Labels.address,
                          borderColor: KColors.customerPrimaryColor,
                          hintText: 'Nearest Landmark',
                        ),
                        Align(
                          alignment: Alignment.center,
                          child: BFlatButton2(
                            text: locale.getTranslatedValue(KeyConstants.save),
                            isWraped: true,
                            isLoading: loading,
                            onPressed: () {
                              parseAddress.houseNo = _shopNumberController.text;
                              parseAddress.landmark = _landMarkController.text;
                              parseAddress.addressline1 = firstLineText;
                              parseAddress.addressline2 = secondLineText;
                              parseAddress.placeName = _nameController.text;
                              parseAddress.phoneNo = _phoneNoController.text;
                              if (markerPosition == null) {
                                parseAddress.lat =
                                    currentPostion.latitude.toString();
                                parseAddress.lng =
                                    currentPostion.longitude.toString();
                              } else {
                                parseAddress.lat =
                                    markerPosition.latitude.toString();
                                parseAddress.lng =
                                    markerPosition.longitude.toString();
                              }
                              updateProfile();

                            },
                            isBold: true,
                            buttonColor: KColors.customerPrimaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
