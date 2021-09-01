import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class ResendTextCounter extends StatefulWidget {
  final ValueChanged<bool> onResetTimer;

  const ResendTextCounter({Key key, this.onResetTimer}) : super(key: key);

  @override
  _ResendTextCounterState createState() => _ResendTextCounterState();
}

class _ResendTextCounterState extends State<ResendTextCounter> {
  ValueNotifier<int> _counter = ValueNotifier<int>(60);
  Timer _timer;

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    startTimer();
    widget.onResetTimer(false);
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
      (Timer timer) => setState(
        () {
          if (_counter.value < 1) {
            timer.cancel();
          } else {
            _counter.value--;
          }
        },
      ),
    );
  }

  //Build Counter
  Widget _buildCountDownTimer() {
    return ValueListenableBuilder<int>(
      valueListenable: _counter,
      builder: (context, value, child) {
        return Container(
          child: BText(
            value == 60
                ? "1:00"
                : value < 10
                    ? "0:0$value"
                    : "0:$value",
            variant: TypographyVariant.headerSmall,
            style: TextStyle(
              color: value < 1 ? KColors.primaryDarkColor : Colors.grey,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return ValueListenableBuilder(
      valueListenable: _counter,
      builder: (context, value, child) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                BIcon(
                  iconData: Icons.mail,
                  color: value < 1 ? KColors.primaryDarkColor : Colors.grey,
                  tapSize: 23,
                ),
                SizedBox(width: 5.0),
                Container(
                  height: 23,
                  alignment: Alignment.center,
                  child: BText(
                    locale.getTranslatedValue(KeyConstants.resendSMS),
                    variant: TypographyVariant.headerSmall,
                    style: TextStyle(
                      color: value < 1 ? KColors.primaryDarkColor : Colors.grey,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ).ripple(
                  value < 1
                      ? () {
                          _counter.value = 60; // *Reseting the counter
                          startTimer();
                          widget.onResetTimer(true);
                        }
                      : null,
                ),
              ],
            ),
          ),
          _buildCountDownTimer(),
        ],
      ),
    );
  }
}
