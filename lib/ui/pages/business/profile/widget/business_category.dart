import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/custom_text.dart';

class BusinessCategory extends StatefulWidget {
  final ValueChanged<int> selectedCategory;
  final int initalCat; //Use it Later as Value to change categories

  const BusinessCategory({Key key, this.selectedCategory, this.initalCat = 1})
      : super(key: key);

  @override
  _BusinessCategoryState createState() => _BusinessCategoryState();
}

class _BusinessCategoryState extends State<BusinessCategory> {
  @override
  void initState() {
    super.initState();
    widget.selectedCategory(1);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      height: 50,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: KColors.businessPrimaryColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: DropdownButton(
        underline: SizedBox(),
        iconEnabledColor: KColors.businessPrimaryColor,
        icon: Icon(Icons.keyboard_arrow_down),
        style: TextStyle(color: Colors.red),
        dropdownColor: Colors.white,
        value: 1,
        isExpanded: true,
        items: [
          DropdownMenuItem(
            child: BText(
              locale.getTranslatedValue(KeyConstants.grocery),
              variant: TypographyVariant.h2,
            ),
            onTap: () => widget.selectedCategory(1),
            value: 1,
          ),
        ],
        onChanged: (int value) {},
      ),
    );
  }
}
