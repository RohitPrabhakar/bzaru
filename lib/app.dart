import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/drivers/errors.dart';
import 'package:flutter_bzaru/helper/routes.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/language_constants.dart';
import 'package:flutter_bzaru/providers/business/m_customer_state.dart';
import 'package:flutter_bzaru/providers/business/m_dashboard_state.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/providers/chat_state.dart';
import 'package:flutter_bzaru/providers/customer/c_explore_state.dart';
import 'package:flutter_bzaru/providers/help_state.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/providers/customer/c_time_state.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/providers/providers.dart';
import 'package:flutter_bzaru/providers/theme_state.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class BzaruApp extends StatefulWidget {
  final Widget home;

  const BzaruApp({
    Key key,
    @required this.home,
  }) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _BzaruAppState state = context.findAncestorStateOfType<_BzaruAppState>();
    state.setLocale(newLocale);
  }

  @override
  _BzaruAppState createState() => _BzaruAppState();
}

class _BzaruAppState extends State<BzaruApp> {
  final _key = ErrorHandlerKey();
  final _navigatorKey = GlobalKey<NavigatorState>();
  ThemeData appThemeData;
  // final _bloc = ErrorsBloc();

  @override
  void initState() {
    super.initState();

    GetIt.instance<ErrorsProducer>().registerErrorHandler(
      _key,
      (error, stackTrace) {
        log(error, stackTrace: stackTrace, name: "BzaruApp");
        // _bloc.add(OnError(error, stackTrace));
        // _navigatorKey.currentState.push(ErrorPageRoute());
        return false;
      },
    );

    getAppTheme();
  }

  @override
  void dispose() {
    GetIt.instance<ErrorsProducer>().unregisterErrorHandler(_key);
    // _bloc.close();
    super.dispose();
  }

  Future<void> getAppTheme() async {
    final primaryprofile = await SharedPrefrenceHelper().getPrimaryProfile();
    appThemeData = primaryprofile == "UserRole.MERCHANT"
        ? AppThemes.merchantTheme
        : AppThemes.customerTheme;
  }

  Locale _locale;
  setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  void didChangeDependencies() {
    getLocale().then((locale) {
      setState(() {
        this._locale = locale;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, //top bar color
      statusBarIconBrightness: Brightness.dark, //top bar icons
    ));
    return ChangeNotifierProvider<ErrorState>(
      create: (context) => ErrorState(),
      child: this._locale == null
          ? Container(
              color: Color(0xFFffffff),
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
              ),
            )
          : MultiProvider(
              providers: [
                ChangeNotifierProvider<AuthState>(
                  create: (context) => AuthState(),
                ),
                ChangeNotifierProvider<ProfileState>(
                    create: (context) => ProfileState()),
                ChangeNotifierProvider<ProductProvider>(
                    create: (context) => ProductProvider()),
                ChangeNotifierProvider<ThemeState>(
                    create: (context) => ThemeState(appThemeData)),
                ChangeNotifierProvider<MOrderState>(
                    create: (context) => MOrderState()),
                ChangeNotifierProvider<COrderState>(
                    create: (context) => COrderState()),
                ChangeNotifierProvider<MCustomerState>(
                    create: (context) => MCustomerState()),
                ChangeNotifierProvider<HelpState>(
                    create: (context) => HelpState()),
                ChangeNotifierProvider<CStoreState>(
                    create: (context) => CStoreState()),
                ChangeNotifierProvider<ChatState>(
                    create: (context) => ChatState()),
                ChangeNotifierProvider<CTimeState>(
                    create: (context) => CTimeState()),
                ChangeNotifierProvider<CExploreState>(
                    create: (context) => CExploreState()),
                ChangeNotifierProvider<MDashboardState>(
                    create: (context) => MDashboardState()),
              ],
              child: MaterialAppWithTheme(
                navigatorKey: _navigatorKey,
                home: widget.home,
                locale: _locale,
              ),
            ),
    );
  }
}

class MaterialAppWithTheme extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;
  final Locale locale;
  final Widget home;

  const MaterialAppWithTheme({
    Key key,
    @required this.navigatorKey,
    @required this.locale,
    @required this.home,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<ThemeState>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      onGenerateTitle: (BuildContext context) => "Bzaru",
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        for (var supportedLocale in supportedLocales) {
          if (supportedLocale.languageCode == locale.languageCode) {
            return supportedLocale;
          }
        }
        return supportedLocales.first;
      },
      locale: locale,
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('hi', 'IN '),
        // !ADD LOCALES HERE
      ],
      theme: themeState.theme,
      home: home,
      // routes: Routes.routes,
      onGenerateRoute: Routes.onGenerateRoute,
      onUnknownRoute: Routes.onUnknownRoute,
    );
  }
}
