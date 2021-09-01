import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/ui/pages/business/products/widgets/counter_button.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class OrderProductTile extends StatelessWidget {
  const OrderProductTile({Key key, @required this.productModel})
      : super(key: key);

  final ProductModel productModel;

  @override
  Widget build(BuildContext context) {
    final title = productModel.title != null
        ? productModel.title ?? "Product Title"
        : "Product Title";

    final desc = productModel.description != null
        ? productModel.description ?? "Product Desc"
        : "Product Desc";

    final image =
        productModel.imageUrl != null && productModel.imageUrl.isNotEmpty
            ? customNetworkImage(
                productModel.imageUrl[0],
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
                      flex: 2,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          BText(
                            productModel.price != null
                                ? "₹ ${productModel.price.toStringAsFixed(2)}"
                                : "₹ 0.00",
                            variant: TypographyVariant.h1,
                            style: TextStyle(
                              color: KColors.businessPrimaryColor,
                            ),
                          ),
                          CounterButton(
                            key: ValueKey<String>(
                                productModel.id), //TO Maintain Count
                            productModel: productModel,
                          ),
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
