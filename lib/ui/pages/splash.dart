import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/functions_helper.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class SplashPage extends StatefulWidget {
  SplashPage({Key key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    internetCheck();
    super.initState();
  }

  Future<void> internetCheck() async {
    await Future.delayed(Duration(seconds: 2)).then((value) async {
      doAutoLogin();
    });
  }

  // Future<void> askPermission() async {
  //   final locale = AppLocalizations.of(context);

  //   PermissionStatus permissionStatus = await _getPermission();
  //   if (permissionStatus == PermissionStatus.granted) {
  //     Provider.of<AuthState>(context, listen: false).getContacts();
  //   }
  //   if (permissionStatus == PermissionStatus.denied ||
  //       permissionStatus == PermissionStatus.permanentlyDenied) {
  //     return;
  //   } else {
  //     showDialog(
  //         context: context,
  //         builder: (BuildContext context) => CupertinoAlertDialog(
  //               title: Text(
  //                   locale.getTranslatedValue(KeyConstants.permissionsError)),
  //               content: Text(
  //                   '${locale.getTranslatedValue(KeyConstants.enableContactAccess)}'
  //                   '${locale.getTranslatedValue(KeyConstants.inSettings)}'),
  //               actions: <Widget>[
  //                 CupertinoDialogAction(
  //                   child: Text('OK'),
  //                   onPressed: () => Navigator.of(context).pop(),
  //                 )
  //               ],
  //             ));
  //   }
  // }

  // Future<PermissionStatus> _getPermission() async {
  //   final PermissionStatus permission = await Permission.contacts.status;
  //   print(permission);
  //   if (permission.isUndetermined || permission.isPermanentlyDenied) {
  //     final Map<Permission, PermissionStatus> permissionStatus =
  //         await [Permission.contacts].request();
  //     return permissionStatus[Permission.contacts] ??
  //         PermissionStatus.undetermined;
  //   }
  //   if (permission != PermissionStatus.granted &&
  //       permission != PermissionStatus.denied) {
  //     final Map<Permission, PermissionStatus> permissionStatus =
  //         await [Permission.contacts].request();
  //     return permissionStatus[Permission.contacts] ??
  //         PermissionStatus.undetermined;
  //   } else {
  //     return permission;
  //   }
  // }

  void doAutoLogin() async {
    final getIt = GetIt.instance;
    final prefs = getIt<SharedPrefrenceHelper>();
    final accessToken = await prefs.getAccessToken();
    final profileState = Provider.of<ProfileState>(context, listen: false);
    // await askPermission();
    if (accessToken != null) {
      print("***************** Auto Login ***********************");
      await BFunctionsHelper.initalizeAppTheme(context);
      if (profileState.customerProfileModel.accountLoggedOut != null &&
          profileState.customerProfileModel.accountLoggedOut) {
        Navigator.pushReplacement(
          context,
          IntroScreen.getRoute(),
        );
      }

      Navigator.of(context)
          .pushAndRemoveUntil(BottomNavBar.getRoute(), (_) => false);
    } else {
      Navigator.pushReplacement(
        context,
        IntroScreen.getRoute(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          KImages.appLogo,
          width: MediaQuery.of(context).size.width * 0.80,
        ),
      ),
    );
  }
}
