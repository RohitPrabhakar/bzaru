import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CartStoreTile extends StatefulWidget {
  final OrdersModel ordersModel;
  final ValueChanged<bool> onExpanded;
  final bool isFirst;

  const CartStoreTile({
    Key key,
    this.ordersModel,
    this.onExpanded,
    this.isFirst,
  }) : super(key: key);

  @override
  _CartStoreTileState createState() => _CartStoreTileState();
}

class _CartStoreTileState extends State<CartStoreTile> {
  TextEditingController _instructionsController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    intiliaze();
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  void intiliaze() {
    final state = Provider.of<COrderState>(context, listen: false);
    String instructions = state.getInstruction(widget.ordersModel.merchantId);
    if (instructions != null && instructions.isEmpty) {
      _instructionsController = TextEditingController(text: instructions);
    } else {
      _instructionsController = TextEditingController();
    }
  }

  void updateInstruction() {
    final state = Provider.of<COrderState>(context, listen: false);
    String instructions = state.getInstruction(widget.ordersModel.merchantId);
    if (instructions != null && instructions.isEmpty) {
      _instructionsController.text = instructions;
    }
  }

  @override
  void didUpdateWidget(covariant CartStoreTile oldWidget) {
    updateInstruction();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    updateInstruction();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      color: KColors.bgColor,
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            width: 80,
            color: Colors.white,
            child: customNetworkImage(
              widget.ordersModel?.merchantImage,
              fit: BoxFit.cover,
              placeholder: BPlaceHolder(
                height: 80,
                width: 80,
              ),
              height: 80,
              width: 80,
            ),
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        flex: 2,
                        child: BText(
                          widget.ordersModel?.merchantName ??
                              locale.getTranslatedValue(KeyConstants.storeName),
                          variant: TypographyVariant.titleSmall,
                          style: TextStyle(fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.loose,
                        child: BText(
                          "₹ ${widget.ordersModel.totalAmount.toStringAsFixed(2)}" ??
                              "₹ 00.00",
                          variant: TypographyVariant.titleSmall,
                          style: TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Consumer<COrderState>(builder: (context, state, child) {
                    String instructions =
                        state.getInstruction(widget.ordersModel.merchantId);

                    return Form(
                      key: _formKey,
                      child: Flexible(
                        child: instructions != null && instructions.isNotEmpty
                            ? Row(
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalSheetForInstruction();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.info,
                                            color: KColors.customerPrimaryColor,
                                            size: 18,
                                          ),
                                          SizedBox(width: 2.0),
                                          Flexible(
                                            child: BText(
                                              instructions,
                                              variant: TypographyVariant.h2,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: widget.isFirst
                                        ? GestureDetector(
                                            onTap: () {
                                              widget.onExpanded(true);
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color:
                                                  KColors.customerPrimaryColor,
                                              size: 30,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              widget.onExpanded(true);
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_up,
                                              color:
                                                  KColors.customerPrimaryColor,
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Flexible(
                                    flex: 4,
                                    child: GestureDetector(
                                      onTap: () {
                                        showModalSheetForInstruction();
                                      },
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_circle,
                                            color: KColors.customerPrimaryColor,
                                            size: 18,
                                          ),
                                          SizedBox(width: 2.0),
                                          BText(
                                            locale.getTranslatedValue(
                                                KeyConstants.addInstructions),
                                            variant: TypographyVariant.h2,
                                            maxLines: 2,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  KColors.customerPrimaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Flexible(
                                    child: widget.isFirst
                                        ? GestureDetector(
                                            onTap: () {
                                              widget.onExpanded(true);
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_down,
                                              color:
                                                  KColors.customerPrimaryColor,
                                              size: 30,
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () {
                                              widget.onExpanded(true);
                                            },
                                            child: Icon(
                                              Icons.keyboard_arrow_up,
                                              color:
                                                  KColors.customerPrimaryColor,
                                              size: 30,
                                            ),
                                          ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void showModalSheetForInstruction() {
    final locale = AppLocalizations.of(context);

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
      isDismissible: false,
      isScrollControlled: true,
      builder: (context) => Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BText(
              locale.getTranslatedValue(KeyConstants.addInstructions),
              variant: TypographyVariant.h1,
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom),
              child: BTextField(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 5.0,
                  horizontal: 5.0,
                ),
                controller: _instructionsController,
                choice: Labels.optionalText,
                textInputAction: TextInputAction.done,
                borderColor: KColors.customerPrimaryColor,
                maxLines: 3,
                maxLengthEnforced: true,
                validations: (value) {
                  if (value.length > 120) {
                    return locale
                        .getTranslatedValue(KeyConstants.instructionLessThan);
                  } else {
                    return null;
                  }
                },
              ),
            ),
            SizedBox(height: 10),
            BFlatButton(
              text: locale.getTranslatedValue(KeyConstants.addText),
              isWraped: true,
              onPressed: () {
                final state = Provider.of<COrderState>(context, listen: false);
                _formKey.currentState.save();
                if (_formKey.currentState.validate()) {
                  state.setInstruction(
                      _instructionsController.text, widget.ordersModel);

                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
