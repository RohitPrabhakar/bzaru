import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/business/m_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class AddProdTile extends StatefulWidget {
  const AddProdTile({Key key, this.model, this.isPresent}) : super(key: key);

  final ProductModel model;
  final bool isPresent;

  @override
  _AddProdTileState createState() => _AddProdTileState();
}

class _AddProdTileState extends State<AddProdTile> {
  bool val = false;

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    print("IS PRESENT ${widget.isPresent}");

    final title = widget.model.title != null
        ? widget.model.title ??
            locale.getTranslatedValue(KeyConstants.productTitle)
        : locale.getTranslatedValue(KeyConstants.productTitle);

    final desc = widget.model.description != null
        ? widget.model.description ??
            locale.getTranslatedValue(KeyConstants.productDesc)
        : locale.getTranslatedValue(KeyConstants.productDesc);

    final image =
        widget.model.imageUrl != null && widget.model.imageUrl.isNotEmpty
            ? customNetworkImage(
                widget.model.imageUrl[0],
                fit: BoxFit.cover,
                placeholder: BPlaceHolder(),
              )
            : Image.asset(
                KImages.intro2,
                fit: BoxFit.cover,
                // fit: BoxFit.contain,
              );

    return Card(
      margin: EdgeInsets.symmetric(vertical: 10),
      elevation: 10.0,
      shadowColor: Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 100,
              child: image,
            ),
            SizedBox(width: 20),
            Expanded(
              child: Container(
                height: 120,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BText(
                      title,
                      variant: TypographyVariant.titleSmall,
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                      textAlign: TextAlign.start,
                    ),
                    BText(
                      desc,
                      variant: TypographyVariant.h3,
                      maxLines: 3,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w300,
                        fontSize: 14,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BText(
                            widget.model.price != null
                                ? "₹ ${widget.model.price.toStringAsFixed(2)}"
                                : "₹ 0.00",
                            variant: TypographyVariant.h1,
                            style: TextStyle(
                              color: KColors.businessPrimaryColor,
                            ),
                          ),
                          widget.isPresent
                              ? Container(
                                  height: 23,
                                  width: 23,
                                  color: Colors.grey,
                                  child: Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 23,
                                  ),
                                  alignment: Alignment.center,
                                ).pH(15)
                              : Container(
                                  height: 23,
                                  width: 23,
                                  child: Transform.scale(
                                    scale: 1.2,
                                    child: Theme(
                                      data: Theme.of(context).copyWith(
                                          unselectedWidgetColor:
                                              KColors.businessPrimaryColor),
                                      child: Checkbox(
                                          value: val,
                                          activeColor:
                                              KColors.businessPrimaryColor,
                                          checkColor: Colors.white,
                                          onChanged: (bool value) {
                                            final state =
                                                Provider.of<MOrderState>(
                                                    context,
                                                    listen: false);

                                            setState(() {
                                              val = value;
                                              if (val) {
                                                state.addItem(widget.model);
                                              } else {
                                                state.removeItem(widget.model);
                                              }
                                            });
                                          }),
                                    ),
                                  ),
                                ).pH(15),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
