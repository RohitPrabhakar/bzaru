import 'package:flutter/cupertino.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/providers/theme_state.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class BFunctionsHelper {
  static ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  ///`Intialize Theme`
  static Future<void> initalizeAppTheme(BuildContext context) async {
    isLoading.value = true;
    final state = Provider.of<ProfileState>(context, listen: false);
    final themeState = Provider.of<ThemeState>(context, listen: false);

    await state.getCustomerProfile();
    await state.getMerchantProfile();

    final userRole = await SharedPrefrenceHelper().getPrimaryProfile();

    if (userRole == "UserRole.MERCHANT") {
      state.setPrimaryProfile(UserRole.MERCHANT);
      state.setSelectedProfile(UserRole.MERCHANT);
      themeState.setTheme(UserRole.MERCHANT);
    } else {
      state.setPrimaryProfile(UserRole.CUSTOMER);
      state.setSelectedProfile(UserRole.CUSTOMER);
      themeState.setTheme(UserRole.CUSTOMER);
    }

    final customerModel = state.customerProfileModel;
    final merchantModel = state.customerProfileModel;

    state.updateProfile(customerModel.copyWith(
      lastLogin: DateTime.now().toString(),
    ));
    state.updateProfile(merchantModel.copyWith(
      lastLogin: DateTime.now().toString(),
    ));

    isLoading.value = false;
  }

  static String timeFromDateTime(DateTime dateTime) {
    final minutes = DateFormat("mm").format(dateTime);

    String time = "";
    int hour = dateTime.hour;

    if (hour >= 12) {
      switch (hour) {
        case 12:
          time = "12:$minutes p.m";
          break;
        case 13:
          time = "01:$minutes p.m";
          break;
        case 14:
          time = "02:$minutes p.m";
          break;
        case 15:
          time = "03:$minutes p.m";
          break;
        case 16:
          time = "04:$minutes p.m";
          break;
        case 17:
          time = "05:$minutes p.m";
          break;
        case 18:
          time = "06:$minutes p.m";
          break;
        case 19:
          time = "07:$minutes p.m";
          break;
        case 20:
          time = "08:$minutes p.m";
          break;
        case 21:
          time = "09:$minutes p.m";
          break;
        case 22:
          time = "10:$minutes p.m";
          break;
        case 23:
          time = "11:$minutes p.m";
          break;
      }
    } else {
      time = hour == 0 ? "12:$minutes a.m" : "$hour:$minutes a.m";
    }

    return time;
  }
}
