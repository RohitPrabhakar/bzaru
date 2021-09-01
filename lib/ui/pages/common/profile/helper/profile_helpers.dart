import 'package:flutter/cupertino.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:provider/provider.dart';

class ProfileHelper {
  ProfileHelper._();

  ///`Checking` if the profile is for merchant.
  static bool checkIfMerchant(BuildContext context) {
    final state = Provider.of<ProfileState>(context, listen: false);
    if (state.merchantProfileModel == null) {
      return false;
    } else {
      return true;
    }
  }
}
