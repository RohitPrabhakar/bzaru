import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';

class CountryCodeBox extends StatefulWidget {
  final TextStyle textStyle;

  const CountryCodeBox({Key key, this.textStyle}) : super(key: key);
  @override
  _CountryCodeBoxState createState() => _CountryCodeBoxState();
}

class _CountryCodeBoxState extends State<CountryCodeBox> {
  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    return Container(
      height: 100,
      width: 70,
      alignment: Alignment.center,
      child: DropdownButton(
        dropdownColor: Colors.white,
        value: 1,
        items: [
          DropdownMenuItem(
            child: Text(
              locale.getTranslatedValue(KeyConstants.countryCodeInd),
              style: widget.textStyle ??
                  KStyles.hintTextStyle.copyWith(
                    fontSize: 18,
                    height: 1,
                    letterSpacing: 1.2,
                  ),
            ),
            value: 1,
          ),
        ],
        onChanged: (value) {
          print(value);
        },
        underline: SizedBox(),
        icon: Icon(Icons.keyboard_arrow_down),
      ),
      //
    );
  }
}
