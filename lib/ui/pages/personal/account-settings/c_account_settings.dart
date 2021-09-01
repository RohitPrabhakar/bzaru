import 'package:flutter/material.dart';
import 'package:flutter_bzaru/model/dashboard_tiles_model.dart';
import 'package:flutter_bzaru/ui/pages/business/dashboard/widgets/dashboard_tiles.dart';
import 'package:flutter_bzaru/ui/pages/personal/c-notifs/c_notification.dart';
import 'package:flutter_bzaru/ui/widgets/custom_list_tile.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CAccountSettings extends StatelessWidget {
  final _accountSettingsTile = [
    DashboardTilesModel(
      title: "Account Info", //TODO: ADD LOCALE
      icon: Icons.lock,
      nextScreen: null,
      id: "info",
    ),
    DashboardTilesModel(
      title: "Personal Info", //TODO: ADD LOCALE
      icon: Icons.account_circle,
      nextScreen: null,
      id: "personal",
    ),
    DashboardTilesModel(
      title: "Address", //TODO: ADD LOCALE
      icon: Icons.location_on,
      nextScreen: null,
      id: "contact",
    ),
    DashboardTilesModel(
      title: "Notification", //TODO: ADD LOCALE
      icon: Icons.notifications,
      nextScreen: CustomerNotifications(),
      id: "notifications",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: BAppBar(
        title: "Account Settings", //TODO: ADD LOCALE
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 2.0),
        child: Column(
          children: _accountSettingsTile
              .map(
                (model) => Column(
                  children: [
                    Container(
                      color: Colors.grey[100],
                      child: BListTile(
                        leadingIcon: model.icon,
                        title: model.title,
                        onTap: onTapFunctions(context, model.id),
                        nextScreen: model.nextScreen,
                      ),
                    ),
                    SizedBox(height: 2.0),
                  ],
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

Function onTapFunctions(BuildContext context, String id) {
  switch (id) {
    case "info":
      return () {};
    case "personal":
      return () {};
      break;
    case "contact":
      return () {};
      break;
    default:
      return () {};
  }
}
