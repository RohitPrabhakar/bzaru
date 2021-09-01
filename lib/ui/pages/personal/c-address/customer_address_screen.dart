import 'dart:async';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/customer_address_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CustomerAddressScreen extends StatefulWidget {
  final CustomerAddressModel customerAddressModel;

  const CustomerAddressScreen({Key key, this.customerAddressModel})
      : super(key: key);

  @override
  _CustomerAddressScreenState createState() => _CustomerAddressScreenState();
}

class _CustomerAddressScreenState extends State<CustomerAddressScreen> {
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TextEditingController _address1Controller;
  TextEditingController _address2Controller;
  TextEditingController _cityController;
  TextEditingController _countryController;
  TextEditingController _nameController;
  TextEditingController _phoneNumberController;
  TextEditingController _pinCodeController;
  TextEditingController _stateController;

  @override
  void dispose() {
    super.dispose();
    _address1Controller.dispose();
    _address2Controller.dispose();
    _phoneNumberController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _nameController.dispose();
    _pinCodeController.dispose();
    _countryController.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    final model = widget.customerAddressModel;
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);

    if (model != null) {
      _address1Controller = TextEditingController(text: model.address1);
      _address2Controller = TextEditingController(text: model.address2);
      _phoneNumberController = TextEditingController(text: model.mobileNumber);
      _cityController = TextEditingController(text: model.city);
      _stateController = TextEditingController(text: model.state);
      _nameController = TextEditingController(text: model.fullName);
      _countryController = TextEditingController(text: model.country);
      _pinCodeController = TextEditingController(text: model.pinCode);
    } else {
      _address1Controller = TextEditingController();
      _address2Controller = TextEditingController();
      _phoneNumberController = TextEditingController();
      _cityController = TextEditingController();
      _stateController = TextEditingController();
      _nameController = TextEditingController();
      _countryController = TextEditingController();
      _pinCodeController = TextEditingController();
    }
  }

  ///`Update Address`
  void updateAddress() async {
    _formKey.currentState.save();

    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      if (_formKey.currentState.validate()) {
        loading.value = true;
        final state = Provider.of<COrderState>(context, listen: false);

        final customerAddress = CustomerAddressModel(
          id: widget.customerAddressModel.id,
          fullName: _nameController.text,
          address1: _address1Controller.text,
          address2: _address2Controller.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          pinCode: _pinCodeController.text,
          mobileNumber: _phoneNumberController.text,
        );

        state.addCustomerAddress(customerAddress);

        await state.saveCustomerAddress();
        await state.getCustomerAddress();

        Navigator.of(context).pop();
        loading.value = false;
      }
    }
  }

  ///`add address`
  void addAddress() async {
    _formKey.currentState.save();

    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      if (_formKey.currentState.validate()) {
        loading.value = true;
        final state = Provider.of<COrderState>(context, listen: false);
        final createdAt = DateTime.now();
        final timeStamp = "${createdAt.microsecondsSinceEpoch}";

        final customerAddress = CustomerAddressModel(
          id: timeStamp,
          fullName: _nameController.text,
          address1: _address1Controller.text,
          address2: _address2Controller.text,
          city: _cityController.text,
          state: _stateController.text,
          country: _countryController.text,
          pinCode: _pinCodeController.text,
          mobileNumber: _phoneNumberController.text,
        );

        state.addCustomerAddress(customerAddress);

        await state.saveCustomerAddress();
        await state.getCustomerAddress();

        Navigator.of(context).pop();
        loading.value = false;
      }
    }
  }

  ///`delete address`
  void deleteAddress() async {
    _formKey.currentState.save();

    final locale = AppLocalizations.of(context);
    if (Utility.connectionCode == 0) {
      Utility.displaySnackbar(
        context,
        key: _scaffoldKey,
        msg: locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
      );
    } else {
      loading.value = true;
      final state = Provider.of<COrderState>(context, listen: false);

      await state.deleteCustomerAddress(widget.customerAddressModel);
      await state.getCustomerAddress();

      Navigator.of(context).pop();
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      appBar: BAppBar(
        title: widget.customerAddressModel != null
            ? locale.getTranslatedValue(KeyConstants.editAddress)
            : locale.getTranslatedValue(KeyConstants.addAddress),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              Column(
                children: [
                  BTextField(
                    choice: Labels.name,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.name),
                    controller: _nameController,
                  ),
                  BTextField(
                    choice: Labels.address,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.address1),
                    controller: _address1Controller,
                  ),
                  BTextField(
                    choice: Labels.address,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.address2),
                    controller: _address2Controller,
                  ),
                  BTextField(
                    choice: Labels.address,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.city),
                    controller: _cityController,
                  ),
                  BTextField(
                    choice: Labels.address,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.state),
                    controller: _stateController,
                  ),
                  BTextField(
                    choice: Labels.address,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.country),
                    controller: _countryController,
                  ),
                  BTextField(
                    choice: Labels.pin,
                    borderColor: KColors.customerPrimaryColor,
                    hintText: locale.getTranslatedValue(KeyConstants.pinCode),
                    controller: _pinCodeController,
                    textInputAction: TextInputAction.next,
                  ),
                  BTextField(
                    choice: Labels.phone,
                    borderColor: KColors.customerPrimaryColor,
                    hintText:
                        locale.getTranslatedValue(KeyConstants.phoneNumber),
                    controller: _phoneNumberController,
                    textInputAction: TextInputAction.done,
                  ),
                  SizedBox(height: 20),
                  widget.customerAddressModel != null
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            BFlatButton2(
                              text: locale
                                  .getTranslatedValue(KeyConstants.delete),
                              isWraped: true,
                              isLoading: loading,
                              onPressed: deleteAddress,
                              isBold: true,
                              buttonColor: KColors.redColor,
                            ),
                            BFlatButton2(
                              text: locale
                                  .getTranslatedValue(KeyConstants.update),
                              isWraped: true,
                              isLoading: loading,
                              onPressed: updateAddress,
                              isBold: true,
                              buttonColor: KColors.customerPrimaryColor,
                            ),
                          ],
                        )
                      : BFlatButton2(
                          text: locale
                              .getTranslatedValue(KeyConstants.addAddress),
                          isWraped: true,
                          isLoading: loading,
                          onPressed: addAddress,
                          isBold: true,
                          buttonColor: KColors.customerPrimaryColor,
                        ),
                  SizedBox(height: 60),
                ],
              ).pH(20)
            ],
          ),
        ),
      ),
    );
  }
}
