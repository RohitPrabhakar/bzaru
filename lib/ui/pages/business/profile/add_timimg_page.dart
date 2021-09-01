import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/widget/time_card.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_button.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AddTimimgPage extends StatefulWidget {
  const AddTimimgPage({Key key}) : super(key: key);
  static CupertinoPageRoute getRoute() {
    return CupertinoPageRoute(
      builder: (_) => AddTimimgPage(),
    );
  }

  @override
  _AddTimimgPageState createState() => _AddTimimgPageState();
}

class _AddTimimgPageState extends State<AddTimimgPage> {
  String languageCode;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getLangCode();
    getMerchantTimings();
  }

  Future<void> getLangCode() async {
    languageCode = await SharedPrefrenceHelper().getLanguageCode();
  }

  Future<void> getMerchantTimings() async {
    await Provider.of<ProfileState>(context, listen: false)
        .getMerchantTimings();
    setState(() {
      isLoading = false;
    });
  }

  Widget _titleBar(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return ListTile(
      leading: Container(
        height: 40,
        width: 30,
        child: Icon(
          Icons.access_time,
          color: KColors.businessPrimaryColor,
          size: 25,
        ),
      ),
      title: Text(
        locale.getTranslatedValue(KeyConstants.schedule),
        style: Theme.of(context)
            .textTheme
            .headline6
            .copyWith(color: KColors.businessPrimaryColor),
      ),
      subtitle: Text(
        locale.getTranslatedValue(KeyConstants.openForSelectedHours),
        style:
            Theme.of(context).textTheme.subtitle2.copyWith(color: Colors.grey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        print("WILL POP SCOP");
        Provider.of<ProfileState>(context, listen: false).clearTimingHours();
        Navigator.of(context).pop();

        return true;
      },
      child: Scaffold(
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.editBusinessHours),
          bgColor: KColors.businessPrimaryColor,
          onPressed: () {
            Provider.of<ProfileState>(context, listen: false)
                .clearTimingHours();
            Navigator.of(context).pop();
          },
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    _titleBar(context),
                    Divider(thickness: 1),
                    Consumer<ProfileState>(
                      builder: (context, state, child) {
                        return Column(
                          children: state.timingsList
                              .map(
                                (e) => TimingCard(
                                  model: e,
                                  langCode: languageCode,
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                    SizedBox(height: 30),
                    BFlatButton(
                        text: locale.getTranslatedValue(KeyConstants.save),
                        onPressed: () async {
                          print("Business hours saved HAHA");
                          Navigator.pop(context);
                        },
                        isWraped: true,
                        color: KColors.businessPrimaryColor),
                    SizedBox(height: 40),
                  ],
                ).pH(15),
              ),
      ),
    );
  }
}
