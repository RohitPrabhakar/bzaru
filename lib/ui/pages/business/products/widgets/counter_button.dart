import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class CounterButton extends StatefulWidget {
  final ProductModel productModel;

  const CounterButton({Key key, @required this.productModel}) : super(key: key);

  @override
  _CounterButtonState createState() => _CounterButtonState();
}

class _CounterButtonState extends State<CounterButton> {
  int _count;

  @override
  void initState() {
    super.initState();
    intializeCount();
  }

  void intializeCount() {
    _count = widget.productModel.quantity ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Consumer<MOrderState>(builder: (context, state, child) {
      return Row(
        children: [
          GestureDetector(
            onTap: () {
              bool isLastElement =
                  state.displayOrderProductList.length == 1 ? true : false;

              if (!isLastElement) {
                _count--;
                if (_count >= 1) {
                  state.changeQuantity(_count, widget.productModel);
                } else {
                  state.removeItemFromDisplayList(widget.productModel);
                }
              } else {
                if (_count > 1) {
                  _count--;

                  state.changeQuantity(_count, widget.productModel);
                } else {
                  Utility.displaySnackbar(context,
                      msg: locale
                          .getTranslatedValue(KeyConstants.youCannotRemove));
                }
              }
            },
            child: Container(
              color: KColors.businessPrimaryColor,
              child: Icon(
                Icons.remove,
                color: Colors.white,
                size: 23,
              ),
            ),
          ),
          SizedBox(width: 5),
          Text(
            "$_count",
            style: KStyles.h1.copyWith(color: Colors.black, fontSize: 18),
          ),
          SizedBox(width: 5),
          GestureDetector(
            onTap: () {
              _count++;
              state.changeQuantity(_count, widget.productModel);
            },
            child: Container(
              color: KColors.businessPrimaryColor,
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 23,
              ),
            ),
          )
        ],
      );
    });
  }
}
