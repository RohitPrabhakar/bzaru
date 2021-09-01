import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/constants.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/providers/theme_state.dart';
import 'package:flutter_bzaru/ui/pages/business/business_pages.dart';
import 'package:flutter_bzaru/ui/pages/common/common_pages.dart';
import 'package:flutter_bzaru/ui/pages/common/settings/settings.dart';
import 'package:flutter_bzaru/ui/pages/personal/chats/c_chat.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/customer_dashboard.dart';
import 'package:flutter_bzaru/ui/pages/personal/explore/explore_screen.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key key, this.selectedIndex, this.selectedUserProfile})
      : super(key: key);

  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(builder: (_) => BottomNavBar());
  }

  final int selectedIndex; //For Special cases.
  final UserRole selectedUserProfile; //Use it for special cases

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final GlobalKey<ScaffoldState> _scaffoldKeyMerchant =
      GlobalKey<ScaffoldState>();
  final GlobalKey<ScaffoldState> _scaffoldKeyCustomer =
      GlobalKey<ScaffoldState>();

  List<Map<String, IconData>> _merchantIcons = [];

  List<Map<String, IconData>> _customerIcons = [];
  int prevMerchantOrderLen;
  int prevMerchantMessageLen;
  int prevMerchantNotiLen;
  int prevCustomerNotifLen;

  int _merchantSelectedIndex = 0;
  int _customerSelectedIndex = 0;
  String merchantId;
  String customerId;

  void initLengths() async {
    print("GETTING LENSSSS");
    prevMerchantOrderLen = await SharedPrefrenceHelper().getOrderLength() ?? 0;
    prevMerchantMessageLen =
        await SharedPrefrenceHelper().getMessageLength() ?? 0;
    prevMerchantNotiLen =
        await SharedPrefrenceHelper().getMerchantNotifLen() ?? 0;
    prevCustomerNotifLen =
        await SharedPrefrenceHelper().getCustomerNotifLen() ?? 0;
  }

  List<Widget> _merchantPages = [
    BusinessDashboard(),
    MerchantChatScreen(),
    OrdersScreen(),
    MyProductsScreen(),
    SettingScreen(),
  ];

  List<Widget> _customerPages = [
    CustomerDashboard(),
    ExploreScreen(),
    CustomerChatScreen(),
    SettingScreen(),
  ];

  getMerchantAndCustomerIcons() {
    final locale = AppLocalizations.of(context);

    _merchantIcons = [
      {locale.getTranslatedValue(KeyConstants.home): Icons.home},
      {locale.getTranslatedValue(KeyConstants.chat): Icons.chat},
      {locale.getTranslatedValue(KeyConstants.orders): Icons.shopping_cart},
      {locale.getTranslatedValue(KeyConstants.products): Icons.shopping_bag},
      {locale.getTranslatedValue(KeyConstants.settings): Icons.settings},
    ];

    _customerIcons = [
      {locale.getTranslatedValue(KeyConstants.home): Icons.home},
      {locale.getTranslatedValue(KeyConstants.explore): Icons.search},
      {locale.getTranslatedValue(KeyConstants.chat): Icons.chat},
      {locale.getTranslatedValue(KeyConstants.settings): Icons.settings},
    ];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getMerchantAndCustomerIcons();
      await getIndex();
      await changeTheme();
      await setPersonalCartFromSharedPref();
    });
  }

  Future<void> setPersonalCartFromSharedPref() async {
    // await Provider.of<CStoreState>(context, listen: false)
    //       .setPersonalCartFromSharedPref();
  }

  Future<void> changeTheme() async {
    final state = Provider.of<ProfileState>(context, listen: false);
    final themeState = Provider.of<ThemeState>(context, listen: false);

    if (widget.selectedUserProfile != null) {
      print("SELECTED PROFILE NOT NULLLLLLLLL $widget.selectedUserProfile");
      state.setSelectedProfile(widget.selectedUserProfile);
      themeState.setTheme(widget.selectedUserProfile);
    }
  }

  Future<void> getIndex() async {
    final state = Provider.of<ProfileState>(context, listen: false);
    merchantId = state.merchantProfileModel?.id ?? "";
    customerId = state.customerProfileModel?.id ?? "";

    if (state.selectedProfile == UserRole.MERCHANT) {
      _customerSelectedIndex = widget.selectedIndex ?? 3;
      _merchantSelectedIndex = widget.selectedIndex ?? 0;
    } else {
      _customerSelectedIndex = widget.selectedIndex ?? 0;
      _merchantSelectedIndex = widget.selectedIndex ?? 4;
    }
    await Future.delayed(Duration(milliseconds: 500), () {});
  }

  ///Building Bottom Navigation Bar Item `Merchant`
  BottomNavigationBarItem _buildMerchantIcons(
      int index, String label, IconData iconData,
      {bool hasOrderUpdated = false,
      bool hasMessageUpdated = false,
      bool hasNotifUpdated = false}) {
    final locale = AppLocalizations.of(context);
    return BottomNavigationBarItem(
      label: label,
      icon: Consumer<ProfileState>(
        builder: (context, state, child) => Stack(
          children: [
            Icon(
              iconData,
              size: 30,
              color: state.selectedProfile == UserRole.MERCHANT
                  ? _merchantSelectedIndex == index
                      ? KColors.activeBNBIconColor
                      : Theme.of(context).primaryColor
                  : _customerSelectedIndex == index
                      ? KColors.activeBNBIconColor
                      : Theme.of(context).primaryColor,
            ),
            label == locale.getTranslatedValue(KeyConstants.orders)
                ? hasOrderUpdated
                    ? CircleAvatar(
                        radius: 4.0,
                        backgroundColor: Colors.red,
                      )
                    : SizedBox(width: 0.0)
                : SizedBox(width: 0.0),
            label == locale.getTranslatedValue(KeyConstants.chat)
                ? hasMessageUpdated
                    ? CircleAvatar(
                        radius: 4.0,
                        backgroundColor: Colors.red,
                      )
                    : SizedBox(width: 0.0)
                : SizedBox(width: 0.0),
            label == locale.getTranslatedValue(KeyConstants.settings)
                ? hasNotifUpdated
                    ? CircleAvatar(
                        radius: 4.0,
                        backgroundColor: Colors.red,
                      )
                    : SizedBox(width: 0.0)
                : SizedBox(width: 0.0),
          ],
        ),
      ),
    );
  }

  ///`Customer Icons`
  BottomNavigationBarItem _buildCustomerIcons(
      int index, String label, IconData iconData,
      {bool hasMessageUpdated = false, bool hasNotifUpdated = false}) {
    final locale = AppLocalizations.of(context);
    return BottomNavigationBarItem(
      label: label,
      icon: Consumer<ProfileState>(
        builder: (context, state, child) => Stack(
          children: [
            Icon(
              iconData,
              size: 30,
              color: state.selectedProfile == UserRole.MERCHANT
                  ? _merchantSelectedIndex == index
                      ? KColors.activeBNBIconColor
                      : Theme.of(context).primaryColor
                  : _customerSelectedIndex == index
                      ? KColors.activeBNBIconColor
                      : Theme.of(context).primaryColor,
            ),
            label == locale.getTranslatedValue(KeyConstants.chat)
                ? hasMessageUpdated
                    ? CircleAvatar(
                        radius: 4.0,
                        backgroundColor: Colors.red,
                      )
                    : SizedBox(width: 0.0)
                : SizedBox(width: 0.0),
            label == locale.getTranslatedValue(KeyConstants.settings)
                ? hasNotifUpdated
                    ? CircleAvatar(
                        radius: 4.0,
                        backgroundColor: Colors.red,
                      )
                    : SizedBox(width: 0.0)
                : SizedBox(width: 0.0),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    initLengths();
    return Consumer<ProfileState>(
      builder: (context, state, child) {
        getMerchantAndCustomerIcons();
        return state.selectedProfile == UserRole.MERCHANT
            ? Scaffold(
                key: _scaffoldKeyMerchant,
                body: _merchantPages[_merchantSelectedIndex],
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(-2.0, -1.0),
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  child: merchantId != null && merchantId.isNotEmpty
                      ? StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection(Constants.merchantCollection)
                              .doc(merchantId)
                              .collection(Constants.orderCollection)
                              .snapshots(),
                          builder: (context, snapshot) {
                            bool orderUpdated = snapshot.data != null &&
                                    prevMerchantOrderLen != null &&
                                    snapshot.data.docChanges != null &&
                                    snapshot.data.docChanges.length != 0 &&
                                    prevMerchantOrderLen !=
                                        snapshot.data.docChanges.length
                                ? true
                                : false;

                            return StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection(
                                        Constants.messagesUsersCollection)
                                    .doc(merchantId)
                                    .collection(
                                        Constants.messagesUsersCollection)
                                    .snapshots(),
                                builder: (context, snapshotMess) {
                                  bool messageUpdated = snapshot.data != null &&
                                          prevMerchantMessageLen != null &&
                                          snapshot.data.docChanges != null &&
                                          snapshot.data.docChanges.length !=
                                              0 &&
                                          prevMerchantMessageLen !=
                                              snapshotMess
                                                  .data.docChanges.length
                                      ? true
                                      : false;

                                  return StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection(
                                              Constants.merchantCollection)
                                          .doc(merchantId)
                                          .collection(
                                              Constants.notificationsCollection)
                                          .snapshots(),
                                      builder: (context, notifications) {
                                        bool notificationUpdated = notifications
                                                        .data !=
                                                    null &&
                                                prevMerchantNotiLen != null &&
                                                notifications.data.docChanges !=
                                                    null &&
                                                notifications.data.docChanges
                                                        .length !=
                                                    0 &&
                                                prevMerchantNotiLen !=
                                                    notifications
                                                        .data.docChanges.length
                                            ? true
                                            : false;
                                        return BottomNavigationBar(
                                          type: BottomNavigationBarType.fixed,
                                          selectedLabelStyle:
                                              KStyles.h1.copyWith(fontSize: 11),
                                          unselectedLabelStyle:
                                              KStyles.h1.copyWith(fontSize: 11),
                                          selectedItemColor:
                                              KColors.activeBNBIconColor,
                                          backgroundColor: Colors.white,
                                          currentIndex: _merchantSelectedIndex,
                                          onTap: (index) {
                                            setState(() {
                                              _merchantSelectedIndex = index;
                                            });
                                          },
                                          items: _merchantIcons
                                              .asMap()
                                              .entries
                                              .map(
                                                (mapEntry) =>
                                                    _buildMerchantIcons(
                                                  mapEntry.key,
                                                  mapEntry.value.keys.first,
                                                  mapEntry.value.values.first,
                                                  hasOrderUpdated: orderUpdated,
                                                  hasMessageUpdated:
                                                      messageUpdated,
                                                  hasNotifUpdated:
                                                      notificationUpdated,
                                                ),
                                              )
                                              .toList(),
                                        );
                                      });
                                });
                          })
                      : SizedBox(),
                ),
              )
            : Scaffold(
                key: _scaffoldKeyCustomer,
                body: _customerPages[_customerSelectedIndex],
                bottomNavigationBar: Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        offset: Offset(-2.0, -1.0),
                        blurRadius: 10.0,
                        spreadRadius: 1.0,
                      )
                    ],
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection(Constants.messagesUsersCollection)
                          .doc(customerId)
                          .collection(Constants.messagesUsersCollection)
                          .snapshots(),
                      builder: (context, snapshotMess) {
                        bool messageUpdated = snapshotMess.data != null &&
                                prevMerchantMessageLen != null &&
                                snapshotMess.data.docChanges != null &&
                                snapshotMess.data.docChanges.length != 0 &&
                                prevMerchantMessageLen !=
                                    snapshotMess.data.docChanges.length
                            ? true
                            : false;
                        return StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection(Constants.customerCollection)
                                .doc(customerId)
                                .collection(Constants.notificationsCollection)
                                .snapshots(),
                            builder: (context, notifications) {
                              bool notificationUpdated = notifications.data !=
                                          null &&
                                      prevCustomerNotifLen != null &&
                                      notifications.data.docChanges != null &&
                                      notifications.data.docChanges.length !=
                                          0 &&
                                      prevCustomerNotifLen !=
                                          notifications.data.docChanges.length
                                  ? true
                                  : false;
                              return BottomNavigationBar(
                                type: BottomNavigationBarType.fixed,
                                selectedLabelStyle:
                                    KStyles.h1.copyWith(fontSize: 11),
                                unselectedLabelStyle:
                                    KStyles.h1.copyWith(fontSize: 11),
                                selectedItemColor: KColors.activeBNBIconColor,
                                backgroundColor: Colors.white,
                                currentIndex: _customerSelectedIndex,
                                onTap: (index) {
                                  setState(() {
                                    _customerSelectedIndex = index;
                                  });
                                },
                                items: _customerIcons
                                    .asMap()
                                    .entries
                                    .map(
                                      (mapEntry) => _buildCustomerIcons(
                                        mapEntry.key,
                                        mapEntry.value.keys.first,
                                        mapEntry.value.values.first,
                                        hasMessageUpdated: messageUpdated,
                                        hasNotifUpdated: notificationUpdated,
                                      ),
                                    )
                                    .toList(),
                              );
                            });
                      }),
                ),
              );
      },
    );
  }
}
