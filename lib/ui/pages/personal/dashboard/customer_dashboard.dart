import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/DeliveryAddress.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/dashboard_tiles_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';
import 'package:flutter_bzaru/ui/pages/Address/CustomerAddress.dart';
import 'package:flutter_bzaru/ui/pages/business/delivery/delivery_setting.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/widgets/c_articles.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/widgets/c_dash_app_bar.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/widgets/c_store_short_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/orders/all-orders/c_orders.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get_it/get_it.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

class CustomerDashboard extends StatefulWidget {
  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  String customerImage = "";
  String customerName = "";
  List<DashboardTilesModel> _customerDashboardTiles = [];
  List<DeliveryAddress> _customerAddresses = [];
  DeliveryAddress _selectedAddress = DeliveryAddress();
  String langCode;
  String address = '';
  String LocationName = "";
  List<DropdownMenuItem<ListItem>> _distanceMenuItems;
  LatLng _currentAddress;
  ListItem _selectedDistanceItem;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  List<ListItem> _distanceItems = [
    ListItem(1, "1 km radius"),
    ListItem(2, "5 km radius"),
    ListItem(3, "10 km radius"),
    ListItem(4, "15 km radius"),
  ];

  @override
  void initState() {
    _distanceMenuItems = buildDropDownMenuItems(_distanceItems);
    _selectedDistanceItem = _distanceMenuItems[0].value;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      await getUserName();
      await getCustomerAddress();


    });
    super.initState();
  }

  setLocation(LatLng newPosition) async {
    var addresses = await Geocoder.local.findAddressesFromCoordinates(
        Coordinates(newPosition.latitude, newPosition.longitude));
    var first = addresses.first;

    return '${first.locality}, ${first.adminArea},${first.subLocality}';
  }

  void _getUserLocation() async {
    var position = await GeolocatorPlatform.instance.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String value =
        await setLocation(LatLng(position.latitude, position.longitude));
    setState(() {
      address = value;
      _currentAddress = LatLng(position.latitude, position.longitude);

      LocationName = "Current Location";
    });
  }

  Future<void> getCustomerStores() async {
    await Provider.of<CStoreState>(context, listen: false).getCustomerStores();
  }

  List<DropdownMenuItem<ListItem>> buildDropDownMenuItems(List listItems) {
    List<DropdownMenuItem<ListItem>> items = List();
    for (ListItem listItem in listItems) {
      items.add(
        DropdownMenuItem(
          child: Text(listItem.name),
          value: listItem,
        ),
      );
    }
    return items;
  }

  Future<void> getUserName() async {
    _isLoading.value = true;
    langCode = await SharedPrefrenceHelper().getLanguageCode();
    final state = Provider.of<ProfileState>(context, listen: false);

    List<DeliveryAddress> addresses = [];
    try {
      addresses.addAll(state.customerProfileModel.deliveryAddress);
      setState(() {
        _customerAddresses = addresses;

        _selectedAddress = _customerAddresses[0];
        address = _customerAddresses[0].addressline1;
        LocationName = _customerAddresses[0].placeName;
        _currentAddress = LatLng(double.parse(_selectedAddress.lat),
            double.parse(_selectedAddress.lng));
      });
    } catch (e) {
      print(e);
    }
    await state.getCustomerProfile();
    await getCustomerStores();
    await state.getCustomerArticles();
    await state.getAds();

    customerName = state.customerProfileModel.name;
    customerImage = state.customerProfileModel.avatar;

    _isLoading.value = false;
  }

  Future<void> getCustomerAddress() async {
    final repo = GetIt.instance.get<CustomerRepository>();
    final pref = GetIt.instance.get<SharedPrefrenceHelper>();
    final customer = await pref.getUserProfile();
    final list = await repo.getCustomerAddress(customer.id);
  }

  void getDashBoardTiles() {
    final locale = AppLocalizations.of(context);

    _customerDashboardTiles = [
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.myOrders),
        icon: Icons.shopping_cart,
        nextScreen: COrders(),
      ),
      // DashboardTilesModel(
      //   title: "PAYMENT",
      //   icon: Icons.payment,
      //   nextScreen: PaymentScreen(),
      // ),
    ];
  }

  Widget _buildAds() {
    final state = Provider.of<ProfileState>(context, listen: false);

    return state.customerAdsList != null && state.customerAdsList.isNotEmpty
        ? Column(
            children: state.customerAdsList
                .map(
                  (model) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    height: sizeConfig.safeHeight * 20,
                    width: double.infinity,
                    child: customNetworkImage(
                      model.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: BPlaceHolder(),
                    ),
                  ),
                )
                .toList(),
          )
        : SizedBox();
  }

  Widget _buildArticles() {
    final locale = AppLocalizations.of(context);

    return Consumer<ProfileState>(
      builder: (context, state, child) => state.customerArticlesList != null &&
              state.customerArticlesList.isNotEmpty
          ? Column(
              children: [
                BText(
                  locale.getTranslatedValue(KeyConstants.bestForYou),
                  variant: TypographyVariant.titleSmall,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                Divider(color: Colors.grey[400], thickness: 1.2),
                SizedBox(height: 20),
                Column(
                  children: state.customerArticlesList
                      .map(
                        (model) => CDashArticlesTile(
                          articlesModel: model,
                          langCode: langCode,
                        ),
                      )
                      .toList(),
                )
              ],
            )
          : SizedBox(),
    );
  }

  Widget _buildYourStores() {
    final locale = AppLocalizations.of(context);

    return Consumer<CStoreState>(
      builder: (context, state, child) => Column(
        children: [
          BText(
            locale.getTranslatedValue(KeyConstants.yourStores),
            variant: TypographyVariant.titleSmall,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          Divider(color: Colors.grey[400], thickness: 1.2),
          SizedBox(height: 20),
          state.yourStoreList != null && state.yourStoreList.length > 0
              ? Container(
                  height: sizeConfig.safeHeight * 11,
                  width: double.infinity,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: state.yourStoreList
                        .map(
                          (model) => CStoreShortTile(
                            profileModel: model,
                          ),
                        )
                        .toList(),
                  ),
                )
              : Container(
                  height: sizeConfig.safeHeight * 11,
                  child: Center(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.shopToHaveStore),
                      variant: TypographyVariant.h2,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildNearestStores() {
    final locale = AppLocalizations.of(context);

    return Consumer<CStoreState>(
      builder: (context, state, child) => Column(
        children: [
          BText(
            'Nearest Stores',
            variant: TypographyVariant.titleSmall,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.all(2.0),
            child: Container(
              width: MediaQuery.of(context).size.width,
              child: Align(
                alignment: Alignment.centerRight,
                child: DropdownButton<ListItem>(
                    underline: Container(),
                    isDense: true,
                    value: _selectedDistanceItem,
                    items: _distanceMenuItems,
                    dropdownColor: Colors.white,
                    style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 25,
                      color: Theme.of(context).primaryColor,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _selectedDistanceItem = value;
                      });
                    }),
              ),
            ),
          ),
          SizedBox(height: 20),
          state.yourStoreList != null && state.yourStoreList.length > 0
              ? Container(
                  height: sizeConfig.safeHeight * 11,
                  width: double.infinity,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: state.yourStoreList
                        .map(
                          (model) => CStoreShortTile(
                            profileModel: model,
                          ),
                        )
                        .toList(),
                  ),
                )
              : Container(
                  height: sizeConfig.safeHeight * 11,
                  child: Center(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.shopToHaveStore),
                      variant: TypographyVariant.h2,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  Widget _buildMoreStores() {
    final locale = AppLocalizations.of(context);

    return Consumer<CStoreState>(
      builder: (context, state, child) => Column(
        children: [
          BText(
            locale.getTranslatedValue(KeyConstants.moreStores),
            variant: TypographyVariant.titleSmall,
            style: TextStyle(fontWeight: FontWeight.w400),
          ),
          Divider(color: Colors.grey[400], thickness: 1.2),
          SizedBox(height: 20),
          state.moreStoresList != null && state.moreStoresList.length > 0
              ? Container(
                  height: sizeConfig.safeHeight * 11,
                  width: double.infinity,
                  child: ListView(
                    padding: EdgeInsets.only(right: 10),
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    children: state.moreStoresList
                        .map(
                          (model) => CStoreShortTile(
                            profileModel: model,
                          ),
                        )
                        .toList(),
                  ),
                )
              : Container(
                  height: 100,
                  child: Center(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.noStores),
                      variant: TypographyVariant.h2,
                    ),
                  ),
                )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    sizeConfig.init(context);
    getDashBoardTiles();
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) => isLoading
          ? Center(child: CircularProgressIndicator())
          : Scaffold(
              appBar: CDashAppBar(
                customerName: customerName,
                customerProfileImage: customerImage,
              ),
              body: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: 30),
                child: Column(
                  children: [
                    // DashBoardTiles(
                    //   dashboardTiles: _customerDashboardTiles,
                    // ),
                    Container(
                      color: Colors.grey[300],
                      child: ListTile(
                        dense: true,
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            builder: (context) => Container(
                              height: 250,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      "Choose your location",
                                      style: TextStyle(fontSize: 20),
                                    ),
                                    subtitle: Text(
                                      "Select a delivery location to see the nearest stores",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  Container(
                                    height: 100,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: _customerAddresses.length,
                                      itemBuilder: (context, index) => Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                _selectedAddress =
                                                    _customerAddresses[index];
                                                address =
                                                    _customerAddresses[index]
                                                        .addressline1;
                                                LocationName =
                                                    _customerAddresses[index]
                                                        .placeName;
                                              });
                                              Navigator.pop(context);
                                            },
                                            child: Container(
                                              height: 90,
                                              width: 90,
                                              margin: const EdgeInsets.all(8.0),
                                              decoration: BoxDecoration(
                                                  border: Border.all(),
                                                  borderRadius:
                                                      BorderRadius.circular(8)),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      _customerAddresses[index]
                                                          .placeName,
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.black),
                                                    ),
                                                    SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      _customerAddresses[index]
                                                          .addressline1,
                                                      style: TextStyle(
                                                          fontSize: 10),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          index == _customerAddresses.length - 1
                                              ? GestureDetector(
                                                  onTap: () async {
                                                    final result =
                                                        await Navigator.push(
                                                            context,
                                                            // Create the SelectionScreen in the next step.
                                                            CustomerAddress
                                                                .getRoute());

                                                    try {
                                                      if (result != null) {
                                                        print(result);
                                                      }
                                                    } catch (e) {}
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    decoration: BoxDecoration(
                                                        border: Border.all(),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8)),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .center,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .center,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .add_circle_outline_sharp,
                                                            color: KColors
                                                                .customerPrimaryColor,
                                                            size: 35,
                                                          ),
                                                          Text(
                                                            "Add new address",
                                                            style: TextStyle(
                                                                fontSize: 10),
                                                          )
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      _getUserLocation();

                                      Navigator.pop(context);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(children: [
                                        Icon(
                                          Icons.my_location_outlined,
                                          color: KColors.customerPrimaryColor,
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Text(
                                          "Use my current location",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 17),
                                        ),
                                      ]),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        leading: Icon(Icons.location_pin),
                        title: Text(LocationName),
                        subtitle: Text(address ?? ""),
                        trailing: Icon(Icons.arrow_drop_down),
                      ),
                    ),
                    SizedBox(height: 20),
                    _buildNearestStores(),
                    SizedBox(height: 20),
                    _buildYourStores(),
                    SizedBox(height: 20),
                    _buildAds(),
                    SizedBox(height: 20),
                    _buildMoreStores(),
                    SizedBox(height: 20),
                    _buildArticles(),
                  ],
                ),
              ),
            ),
    );
  }
}

//Google API KEY-  AIzaSyCN4Y0uWd7sfPrQit_lR1ur_xAEz4PMLH4
