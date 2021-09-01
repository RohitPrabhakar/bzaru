import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/locale/language_constants.dart';
import 'package:flutter_bzaru/model/timing_model.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';
import 'package:provider/provider.dart';

class TimingCard extends StatelessWidget {
  const TimingCard({Key key, this.model, this.langCode}) : super(key: key);
  final TimingModel model;
  final String langCode;

  Widget _switch(BuildContext context) {
    return Switch(
      value: !model.isClosed ?? true,
      activeColor: KColors.businessPrimaryColor,
      onChanged: (val) {
        model.isClosed = !val;
        if (val) {
          model.startTime = "9:00 am";
          model.endTime = "6:00 pm";
        }
        updateTime(context);
      },
    );
  }

  Widget _hoursRow(BuildContext context) {
    return SizedBox(
      width: AppThemes.fullWidth(context) - 82,
      child: Row(children: <Widget>[
        _day(context, model.startTime, onPressed: () async {
          final time = await getTime(context);
          if (time != null) {
            model.startTime = langCode == "hi"
                ? (time.split(' ')[1].toLowerCase() +
                    " " +
                    time.split(' ')[0].toLowerCase())
                : time.toLowerCase();
            updateTime(context);
          }
        }, isStartTime: true),
        Text(" - "),
        _day(context, model.endTime, onPressed: () async {
          final time = await getTime(context);
          if (time != null) {
            model.endTime = langCode == "hi"
                ? (time.split(' ')[1].toLowerCase() +
                    " " +
                    time.split(' ')[0].toLowerCase())
                : time.toLowerCase();

            print(langCode);
            updateTime(context);
          }
        }, isStartTime: false)
      ]),
    );
  }

  Widget _day(BuildContext context, String text,
      {Function onPressed, Widget child, bool isStartTime}) {
    return Container(
      height: 25,
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: child != null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(text),
                SizedBox(height: 5),
                SizedBox(width: 60, child: Divider(height: 2, thickness: 2)),
              ],
            ),
    ).ripple(onPressed);
  }

  Future<String> getTime(BuildContext context) async {
    final time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time == null) {
      return null;
    }
    TimeOfDay selectedTime = time;
    MaterialLocalizations localizations = MaterialLocalizations.of(context);
    String formattedTime = localizations.formatTimeOfDay(selectedTime,
        alwaysUse24HourFormat: false);
    print(formattedTime);
    return formattedTime;
  }

  void updateTime(BuildContext context) {
    Provider.of<ProfileState>(context, listen: false).updateTimeingHours(model);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final localeDay = locale.getTranslatedValue(model.day.toLowerCase());

    return Column(
      children: <Widget>[
        ListTile(
            leading: SizedBox(),
            title: BText(localeDay, variant: TypographyVariant.body),
            subtitle: model.isClosed ?? true
                ? BText(
                    locale.getTranslatedValue(KeyConstants.closed),
                    variant: TypographyVariant.h2,
                    style: TextStyle(
                      color: KColors.disableButtonColor,
                    ),
                  )
                : _hoursRow(context),
            trailing: _switch(context)),
        Divider(
            thickness: model.index == 6 ? 0 : 1,
            height: model.index == 6 ? 0 : 1)
      ],
    );
  }
}
