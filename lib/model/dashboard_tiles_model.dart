import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/pages/business/b-notifs/b_notifications.dart';
import 'package:flutter_bzaru/ui/pages/business/business_pages.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/customers_list_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/invite/m_invite.dart';
import 'package:flutter_bzaru/ui/pages/personal/account-settings/c_account_settings.dart';
import 'package:flutter_bzaru/ui/pages/personal/c-notifs/c_notification.dart';
import 'package:flutter_bzaru/ui/pages/personal/help/c_help.dart';
import 'package:flutter_bzaru/ui/pages/personal/invite/c_invite.dart';
import 'package:flutter_bzaru/ui/pages/personal/orders/all-orders/c_orders.dart';

class DashboardTilesModel {
  final String title;
  final IconData icon;
  final Widget nextScreen;
  final String
      id; //ID is used to determine what will happen when the tile is pressed.

  DashboardTilesModel({
    this.title,
    this.icon,
    this.nextScreen,
    this.id,
  });

  ///`Dashboard Screen` Tiles List
  static final List<DashboardTilesModel> businessDashBoardTiles = [
    DashboardTilesModel(
      title: "Customers",
      icon: Icons.people,
      nextScreen: CustomerListScreen(),
    ),
  ];
}
