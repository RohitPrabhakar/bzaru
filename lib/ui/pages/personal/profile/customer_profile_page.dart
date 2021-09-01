import 'dart:async';
import 'dart:io';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/widgets/user_profile_image.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({Key key, @required this.model}) : super(key: key);

  final ProfileModel model;

  @override
  _CustomerProfilePageState createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  ValueNotifier<bool> loading = ValueNotifier<bool>(false);
  File profile;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<ConnectivityResult> _connectivitySubscription;

  TextEditingController _emailController;
  TextEditingController _firstNameController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _lastNameController;
  TextEditingController _phoneNumberController;

  @override
  void didUpdateWidget(CustomerProfilePage oldWidget) {
    if (oldWidget.model != widget.model) {
      updateScreen(widget.model);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    super.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneNumberController = TextEditingController();
    Utility.initConnectivity(_connectivity, mounted);
    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen(Utility.updateConnectionStatus);
    updateScreen(widget.model);
  }

  void updateScreen(ProfileModel model) {
    if (model == null) {
      return;
    }
    _firstNameController.text = model.name.split(" ")[0];
    _lastNameController.text = model.name.split(" ")[1];
    _phoneNumberController.text = model.contactPrimary;
    _emailController.text = model.email;
    print("Update profile screen");
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
      final String name =
          _firstNameController.text + " " + _lastNameController.text;

      ProfileModel model = state.customerProfileModel.copyWith(
        name: name.trim(),
        email: _emailController.text.trim(),
      );
      String profileUrl;
      loading.value = true;

      _formKey.currentState.save();
      final isValidated = _formKey.currentState.validate();

      if (isValidated) {
        /// `upload profile to firebase storage`
        if (profile != null) {
          profileUrl = await state.uploadFile(profile);
          model.avatar = profileUrl;
          print(profileUrl);
        }

        await state.updateProfile(model);
        await state.getCustomerProfile();
        Navigator.of(context).pop();
      }
      loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      key: _scaffoldKey,
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.editPersonalProfile),
      ),
      body: Consumer<ProfileState>(
        builder: (context, state, child) => state.isBusy
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 10),
                      UserProfileImage(
                        profilePath: Provider.of<ProfileState>(context)
                            .customerProfileModel
                            ?.avatar,
                        onFileSelected: (file) {
                          profile = file;
                        },
                      ),
                      SizedBox(height: 20),
                      BTextField(
                        choice: Labels.name,
                        controller: _firstNameController,
                        hintText:
                            locale.getTranslatedValue(KeyConstants.firstName),
                      ),
                      BTextField(
                        choice: Labels.name,
                        controller: _lastNameController,
                        hintText:
                            locale.getTranslatedValue(KeyConstants.lastName),
                      ),
                      BTextField(
                        choice: Labels.email,
                        controller: _emailController,
                        hintText: locale.getTranslatedValue(KeyConstants.email),
                      ),
                      BTextField(
                        choice: Labels.text,
                        controller: _phoneNumberController,
                        hintText:
                            locale.getTranslatedValue(KeyConstants.phoneNumber),
                        isEnabled: false,
                      ),
                      SizedBox(height: 10),
                      BFlatButton2(
                        text: locale.getTranslatedValue(KeyConstants.update),
                        isWraped: true,
                        isLoading: loading,
                        onPressed: updateProfile,
                        isBold: true,
                      ),
                      SizedBox(height: 40),
                    ],
                  ).pH(30),
                ),
              ),
      ),
    );
  }
}
