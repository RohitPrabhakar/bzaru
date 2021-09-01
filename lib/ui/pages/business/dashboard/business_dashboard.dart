import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/dashboard_tiles_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/c-details/customers_list_screen.dart';
import 'package:flutter_bzaru/ui/pages/business/dashboard/widgets/dashboard_chart.dart';
import 'package:flutter_bzaru/ui/pages/business/dashboard/widgets/dashboard_tiles.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/widget/qr_code_generator.dart';
import 'package:flutter_bzaru/ui/pages/personal/dashboard/widgets/c_articles.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class BusinessDashboard extends StatefulWidget {
  @override
  _BusinessDashboardState createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  List<DashboardTilesModel> _businessDashBoardTiles = [];
  String langCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getMerchantArticles();
    });
  }

  void getMerchantArticles() async {
    final state = Provider.of<ProfileState>(context, listen: false);
    langCode = await SharedPrefrenceHelper().getLanguageCode();
    await state.getMerchantArticles();
  }

  void getDashboardTiles() {
    final locale = AppLocalizations.of(context);
    _businessDashBoardTiles = [
      DashboardTilesModel(
        title: locale.getTranslatedValue(KeyConstants.customers),
        icon: Icons.people,
        nextScreen: CustomerListScreen(),
      ),
    ];
  }

  Widget _buildArticles() {
    final locale = AppLocalizations.of(context);

    return Consumer<ProfileState>(
      builder: (context, state, child) => state.merchantArticlesList != null &&
              state.merchantArticlesList.isNotEmpty
          ? Column(
              children: [
                BText(
                  locale.getTranslatedValue(KeyConstants.bestForYou),
                  variant: TypographyVariant.titleSmall,
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                Divider(color: Colors.grey[400], thickness: 1.2),
                SizedBox(height: 20),
                Column(
                  children: state.merchantArticlesList
                      .map(
                        (model) => CDashArticlesTile(
                          articlesModel: model,
                          langCode: langCode,
                        ),
                      )
                      .toList(),
                )
              ],
            )
          : SizedBox(),
    );
  }

  Widget _barChart() {
    return DashboardChart(
      lang: langCode,
    );
  }

  ///Building `QR Code`
  Widget _buildQRCode(BuildContext context) {
    return Icon(
      Icons.qr_code,
      color: Colors.white,
      size: 23,
    ).p(12);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    getDashboardTiles();
    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.dashBoard),
        removeLeadingIcon: true,
        leadingIcon: _buildQRCode(context).ripple(() {
          Navigator.push(
              context,
              CupertinoPageRoute(
                  builder: (context) => QRCodeGenerator(),
                  fullscreenDialog: true));
        }),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30),
        child: Column(
          children: [
            DashBoardTiles(dashboardTiles: _businessDashBoardTiles),
            Divider(height: 2, thickness: 0.2, color: Colors.black),
            SizedBox(height: 20),
            _barChart(),
            SizedBox(height: 30),
            _buildArticles(),
          ],
        ),
      ),
    );
  }
}
