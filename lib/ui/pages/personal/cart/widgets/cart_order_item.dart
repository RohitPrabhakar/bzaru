import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CartOrderItem extends StatelessWidget {
  final ProductModel productModel;

  const CartOrderItem({Key key, this.productModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      elevation: 5.0,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 80,
              width: 80,
              color: Colors.white,
              child: customNetworkImage(
                productModel.imageUrl != null &&
                        productModel.imageUrl.isNotEmpty
                    ? productModel?.imageUrl[0]
                    : null,
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
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: BText(
                              productModel.title.capitalize() ??
                                  locale.getTranslatedValue(
                                      KeyConstants.itemName),
                              variant: TypographyVariant.titleSmall,
                              maxLines: 2,
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Flexible(child: _buildAddButtonCounter()),
                        ],
                      ),
                    ),
                    Flexible(
                        child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(),
                        BText(
                          "₹ ${productModel.price.toStringAsFixed(2)}" ?? "N.A",
                          variant: TypographyVariant.h2,
                          style: TextStyle(fontSize: 14),
                        ),
                      ],
                    )),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddButtonCounter() {
    return Consumer<CStoreState>(
      builder: (context, state, child) => productModel.tempQty > 0
          ? Card(
              color: Colors.white,
              elevation: 10.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        state.updateItemQuantity(1, productModel, false);
                        state.updatePersonalCart();
                      },
                      child: productModel.tempQty == 1
                          ? Icon(
                              Icons.delete,
                              color: KColors.customerPrimaryColor,
                              size: 23,
                            )
                          : Icon(
                              Icons.remove,
                              color: KColors.customerPrimaryColor,
                              size: 23,
                            ),
                    ),
                    SizedBox(width: 10),
                    BText(
                      productModel.tempQty.toString(),
                      variant: TypographyVariant.h2,
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        state.updateItemQuantity(1, productModel, true);
                        state.updatePersonalCart();
                      },
                      child: Icon(
                        Icons.add,
                        color: KColors.customerPrimaryColor,
                        size: 23,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(),
    );
  }
}
