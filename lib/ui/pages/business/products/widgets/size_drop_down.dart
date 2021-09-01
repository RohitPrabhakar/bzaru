import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/enum.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class SizeDropDown extends StatefulWidget {
  final ValueChanged<ProductSize> productSize;
  final ValueChanged<String> size;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String predefinedSize;
  final ProductSize predefinedProductSize;

  const SizeDropDown({
    Key key,
    this.productSize,
    this.scaffoldKey,
    this.predefinedSize,
    this.size,
    this.predefinedProductSize,
  }) : super(key: key);

  @override
  _SizeDropDownState createState() => _SizeDropDownState();
}

class _SizeDropDownState extends State<SizeDropDown> {
  int selectedIndex = 0;
  ValueNotifier<int> _selectedValue;
  TextEditingController _sizeController;

  List<String> sizeList = [];

  @override
  void dispose() {
    _selectedValue.dispose();
    _sizeController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initalize();
  }

  void initalize() {
    sizeList = ProductModel.sizeList;

    if (widget.predefinedSize != null && widget.predefinedProductSize != null) {
      final index = sizeList.indexOf(widget.predefinedProductSize.asString());
      _sizeController = TextEditingController(text: widget.predefinedSize);
      _selectedValue = ValueNotifier<int>(index);
      widget.size(widget.predefinedSize);
      widget.productSize(widget.predefinedProductSize);
    } else {
      widget.size("");
      widget.productSize(ProductSize.KG);
      _sizeController = TextEditingController();
      _selectedValue = ValueNotifier<int>(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(
            color: KColors.businessPrimaryColor,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(5.0),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Flexible(
              child: Container(
                height: 70,
                alignment: Alignment.center,
                child: TextFormField(
                  autocorrect: false,
                  controller: _sizeController,
                  decoration: InputDecoration(
                    helperText: "",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                    border: InputBorder.none,
                  ),
                  style: KStyles.fieldTextStyle,
                  textInputAction: TextInputAction.next,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      widget.size(value);
                    }
                  },
                  validator: (String value) {
                    if (value.isEmpty) {
                      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          locale.getTranslatedValue(
                              KeyConstants.quantityCantBeEmpty),
                        ),
                      ));
                      return "";
                    }
                    if (value.startsWith("0")) {
                      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          locale.getTranslatedValue(
                              KeyConstants.quantityNotStart),
                        ),
                      ));
                      return "";
                    }
                    if (!RegExp(r"^(?:-?[1-9]\d*$)|(?:^0)$").hasMatch(value)) {
                      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
                        content: Text(
                          locale.getTranslatedValue(
                              KeyConstants.quantityShoubleBe),
                        ),
                      ));

                      return "";
                    } else {
                      return null;
                    }
                  },
                ),
              ),
            ),
            Flexible(
              child: Container(
                height: 50,
                width: 50,
                child: ValueListenableBuilder(
                  valueListenable: _selectedValue,
                  builder: (context, value, _) => DropdownButton(
                    underline: SizedBox(),
                    isExpanded: true,
                    iconEnabledColor: KColors.businessPrimaryColor,
                    icon: Icon(Icons.keyboard_arrow_down),
                    style: TextStyle(color: Colors.red),
                    dropdownColor: Colors.white,
                    value: value,
                    items: sizeList
                        .asMap()
                        .entries
                        .map((mE) => _buildDropDownItem(mE.key, mE.value))
                        .toList(),
                    onChanged: (value) {
                      if (value != 0) {
                        _selectedValue.value = value;
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  DropdownMenuItem _buildDropDownItem(int value, String size) {
    return DropdownMenuItem(
      child: BText(
        size,
        variant: TypographyVariant.h2,
      ),
      onTap: () => widget.productSize(SizeOfProduct.fromString(size)),
      value: value,
    );
  }
}
