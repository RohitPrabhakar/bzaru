import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/AddressData.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/Address/address_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/add_timimg_page.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/widget/business_category.dart';
import 'package:flutter_bzaru/ui/pages/common/profile/helper/profile_helpers.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'widget/business_profile_image.dart';

class BusinessProfile extends StatefulWidget {
  const BusinessProfile({Key key, @required this.model}) : super(key: key);

  final ProfileModel model;

  @override
  _BusinessProfileState createState() => _BusinessProfileState();
}

class _BusinessProfileState extends State<BusinessProfile> {
  File bannerImage;
  String categoryOfBusiness;
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  File profileImage;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TextEditingController _address1Controller;
  TextEditingController _address2Controller;
  TextEditingController _businessEmailController;
  TextEditingController _businessPhoneController;
  TextEditingController _cityController;
  TextEditingController _descriptionController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController;
  TextEditingController _phoneNumberController;
  TextEditingController _pinCodeController;
  TextEditingController _stateController;
  AddressData _addressData;
  List<CustomerAddressModel> addresses = [];
  var addressController = TextEditingController();

  @override
  void didUpdateWidget(BusinessProfile oldWidget) {
    if (oldWidget.model != widget.model) {
      updateScreen(widget.model);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _descriptionController.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _nameController.dispose();
    _businessEmailController.dispose();
    _businessPhoneController.dispose();
    _pinCodeController.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    _address1Controller = TextEditingController();
    _address2Controller = TextEditingController();
    _descriptionController = TextEditingController();
    _phoneNumberController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _nameController = TextEditingController();
    _businessEmailController = TextEditingController();
    _businessPhoneController = TextEditingController();
    _pinCodeController = TextEditingController();
    getCustomerProfileDetails();
    updateScreen(widget.model);
  }

  void updateScreen(ProfileModel model) {
    if (model == null) {
      return;
    }
    _nameController.text = widget.model.name;
    _address1Controller.text = widget.model.address1;
    _address2Controller.text = widget.model.address2;
    _phoneNumberController.text = widget.model.contactPrimary;
    _descriptionController.text = widget.model.description;
    _cityController.text = widget.model.city;
    _businessEmailController.text = widget.model.businessEmail;
    _businessPhoneController.text = widget.model.businessPhoneNumber;
    _stateController.text = widget.model.state;
    _pinCodeController.text = widget.model.pinCode;
    try {
      addressController.text = widget.model.customerAddress[0].address1;
      print(widget.model.customerAddress.length.toString());
      addresses.addAll(widget.model.customerAddress);
    } catch (e) {}
    log("Update Merchant screen");
  }



  void updateProfile() async {
    final locale = AppLocalizations.of(context);

    if (_addressData != null) {
      CustomerAddressModel data = CustomerAddressModel(
          address1: _addressData.address1,
          address2: _addressData.address2,
          longitude: _addressData.longi,
          landmark: _addressData.landMark,
          shopNumber: _addressData.shopNumber,
          latitude: _addressData.lat);
      addresses.add(data);
    }

    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      final state = Provider.of<ProfileState>(context, listen: false);
      ProfileModel model = state.merchantProfileModel != null
          ? state.merchantProfileModel.copyWith(
              name: _nameController.text.trim(),
              id: state.customerProfileModel.id.trim(),
              createdAt: DateTime.now(),
              pinCode: _pinCodeController.text.trim(),
              email: state.customerProfileModel.email.trim(),
              categoryOfBusiness: categoryOfBusiness.trim(),
              contactPrimary: _phoneNumberController.text.trim(),
              businessPhoneNumber: _businessPhoneController.text.trim(),
              businessEmail: _businessEmailController.text.trim(),
              description: _descriptionController.text.trim(),
              address1: _address1Controller.text.trim(),
              address2: _address2Controller.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              role: UserRole.MERCHANT,
              customerAddress: addresses)
          : ProfileModel(
              name: _nameController.text.trim(),
              id: state.customerProfileModel.id.trim(),
              createdAt: DateTime.now(),
              pinCode: _pinCodeController.text.trim(),
              email: state.customerProfileModel.email.trim(),
              categoryOfBusiness: categoryOfBusiness.trim(),
              contactPrimary: _phoneNumberController.text.trim(),
              businessPhoneNumber: _businessPhoneController.text.trim(),
              businessEmail: _businessEmailController.text.trim(),
              description: _descriptionController.text.trim(),
              address1: _address1Controller.text.trim(),
              address2: _address2Controller.text.trim(),
              city: _cityController.text.trim(),
              state: _stateController.text.trim(),
              role: UserRole.MERCHANT,
              activityStatus: UserActivityStatus.ACTIVE,
              isPaidCustomer: false,
              maxItems: 200,
              maxProductImages: 8,
              customerAddress: addresses);
      loading.value = true;

      /// upload profile to firebase storage
      if (profileImage != null) {
        final profileUrl = await state.uploadFile(profileImage);
        model.avatar = profileUrl;
        print(profileUrl);
      }

      /// upload profile to firebase storage
      if (bannerImage != null) {
        final profileUrl = await state.uploadFile(bannerImage);
        model.coverImage = profileUrl;
        print(profileUrl);
      }

      //Validations
      _formKey.currentState.save();
      final isValidated = _formKey.currentState.validate();
      print(isValidated);
      if (isValidated) {
        await state.updateProfile(model);
        await state.updateMerchantTimings(state.timingsList);

        await state.getMerchantProfile();
        await state.getMerchantTimings();

        Navigator.pop(context, "Profile updated successfully");
        // BNavigation.popNavigate(context);
      }
      loading.value = false;
    }
  }

  /// Getting Customer profile details to pre fill form when the user creates the
  /// business profile for the first time.
  void getCustomerProfileDetails() {
    final customerProfile =
        Provider.of<ProfileState>(context, listen: false).customerProfileModel;
    if (customerProfile != null) {
      _nameController.text = customerProfile.name;
      _phoneNumberController.text = customerProfile.contactPrimary;
      _descriptionController.text = customerProfile.description;
      _address1Controller.text = customerProfile.address1;
      _address2Controller.text = customerProfile.address2;
      _cityController.text = customerProfile.city;
      _stateController.text = customerProfile.state;
    }
  }

  ///Building Timing Field
  Widget _buildTimingField() {
    final locale = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          locale.getTranslatedValue(KeyConstants.timing),
          style: KStyles.fieldTextStyle,
        ),
        Container(
          width: 50,
          // color: Colors.red,
          alignment: Alignment.centerRight,
          child: BIcon(
            iconData: Icons.schedule,
            iconSize: 30,
            color: KColors.businessPrimaryColor,
          ).ripple(() {
            Navigator.push(context, AddTimimgPage.getRoute());
          }),
        ),
      ],
    );
  }

  Widget _buildCateogry() {
    return BusinessCategory(
      initalCat: 1,
      selectedCategory: (value) {
        if (value == 1)
          categoryOfBusiness = "Grocery"; //TODO: ADD MORE CHECKS LATER
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.editBusinessProfile),
        bgColor: KColors.businessPrimaryColor,
      ),
      body: Consumer<ProfileState>(
        builder: (context, state, child) => state.isBusy
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      BusinessProfileImage(
                        onProfilechanged: (file) {
                          profileImage = file;
                        },
                        onBannerechanged: (file) {
                          bannerImage = file;
                        },
                      ),
                      SizedBox(height: 20),
                      Column(
                        children: [
                          BTextField(
                            choice: Labels.name,
                            borderColor: KColors.businessPrimaryColor,
                            hintText:
                                locale.getTranslatedValue(KeyConstants.name),
                            controller: _nameController,
                          ),
                          _buildCateogry(),
                          SizedBox(height: 20),
                          BTextField(
                            choice: Labels.text,
                            borderColor: KColors.businessPrimaryColor,
                            hintText: locale
                                .getTranslatedValue(KeyConstants.description),
                            maxLines: 3,
                            maxLengthEnforced: true,
                            contentPadding: EdgeInsets.symmetric(
                                vertical: 2.0, horizontal: 10.0),
                            controller: _descriptionController,
                          ),
                          _buildTimingField(),
                          SizedBox(height: 20),
                          BTextField(
                            choice: Labels.text,
                            borderColor: KColors.businessPrimaryColor,
                            hintText: locale
                                .getTranslatedValue(KeyConstants.phoneNumber),
                            controller: _phoneNumberController,
                            isEnabled: false,
                          ),
                          BTextField(
                            choice: Labels.phone,
                            borderColor: KColors.businessPrimaryColor,
                            hintText: locale.getTranslatedValue(
                                KeyConstants.businessPhoneNumber),
                            controller: _businessPhoneController,
                          ),
                          BTextField(
                            choice: Labels.email,
                            borderColor: KColors.businessPrimaryColor,
                            hintText: locale
                                .getTranslatedValue(KeyConstants.businessEmail),
                            controller: _businessEmailController,
                          ),
                          // BTextField(
                          //   choice: Labels.address,
                          //   borderColor: KColors.businessPrimaryColor,
                          //   hintText: locale
                          //       .getTranslatedValue(KeyConstants.address1),
                          //   controller: _address1Controller,
                          // ),
                          // BTextField(
                          //   choice: Labels.address,
                          //   borderColor: KColors.businessPrimaryColor,
                          //   hintText: locale
                          //       .getTranslatedValue(KeyConstants.address2),
                          //   controller: _address2Controller,
                          // ),
                          // BTextField(
                          //   choice: Labels.address,
                          //   borderColor: KColors.businessPrimaryColor,
                          //   hintText:
                          //       locale.getTranslatedValue(KeyConstants.city),
                          //   controller: _cityController,
                          // ),
                          // BTextField(
                          //   choice: Labels.address,
                          //   borderColor: KColors.businessPrimaryColor,
                          //   hintText:
                          //       locale.getTranslatedValue(KeyConstants.state),
                          //   controller: _stateController,
                          // ),
                          // BTextField(
                          //   choice: Labels.pin,
                          //   borderColor: KColors.businessPrimaryColor,
                          //   hintText:
                          //       locale.getTranslatedValue(KeyConstants.pinCode),
                          //   controller: _pinCodeController,
                          //   textInputAction: TextInputAction.done,
                          // ),

                          GestureDetector(
                            onTap: () async {
                              final result = await Navigator.push(
                                  context,
                                  // Create the SelectionScreen in the next step.
                                  AddressScreen.getRoute());

                              try {
                                if (result != null) {
                                  _addressData = result;
                                  print(_addressData.address2);
                                }
                              } catch (e) {}
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(5),
                                  ),
                                  border: Border.all(
                                      color: KColors.businessPrimaryColor,
                                      width: 1.5)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 9,
                                    child: Container(
                                      child: TextFormField(
                                        enabled: false,
                                        controller: addressController,
                                        style: KStyles.hintTextStyle,
                                        decoration: new InputDecoration(
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                            contentPadding:
                                                EdgeInsets.only(left: 5),
                                            hintText: locale.getTranslatedValue(
                                                KeyConstants.addAddresses)),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Icon(
                                      Icons.arrow_forward_ios,
                                      color: KColors.businessPrimaryColor,
                                      size: 15,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          BFlatButton2(
                            text: ProfileHelper.checkIfMerchant(context)
                                ? locale.getTranslatedValue(KeyConstants.done)
                                : locale.getTranslatedValue(
                                    KeyConstants.createBusinessAccount),
                            isWraped: true,
                            isLoading: loading,
                            onPressed: updateProfile,
                            isBold: true,
                            buttonColor: KColors.businessPrimaryColor,
                          ),
                          SizedBox(height: 40),
                        ],
                      ).pH(30)
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
