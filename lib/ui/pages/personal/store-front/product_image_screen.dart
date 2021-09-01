import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/product_model.dart';
import 'package:flutter_bzaru/providers/customer/c_store_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';
import 'package:flutter_bzaru/helper/enum.dart';

class ProductImageScreen extends StatefulWidget {
  final ProductModel productModel;

  const ProductImageScreen({Key key, this.productModel}) : super(key: key);

  @override
  _ProductImageScreenState createState() => _ProductImageScreenState();
}

class _ProductImageScreenState extends State<ProductImageScreen> {
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Colors.white,
        actions: [
          Icon(
            Icons.cancel,
            color: Colors.black,
            size: 30,
          ).ripple(() {
            Navigator.of(context).pop();
          }).pH(10)
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageView(context),
            SizedBox(height: 20),
            widget.productModel.imageUrl != null &&
                    widget.productModel.imageUrl.length > 1
                ? _buildDots(context)
                : SizedBox(),
            SizedBox(height: 20),
            _buildDetails(context),
          ],
        ).pH(20),
      ),
    );
  }

  Widget _buildDots(context) {
    return widget.productModel.imageUrl != null &&
            widget.productModel.imageUrl.isNotEmpty
        ? ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder: (context, selectedIndex, _) {
              return Container(
                height: 20,
                width: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.productModel.imageUrl.length,
                  itemBuilder: (context, index) => Container(
                    margin: EdgeInsets.symmetric(
                      horizontal: 8,
                      // index != widget.productModel.imageUrl.length - 1
                      // ? 10
                      // : 0,
                    ),
                    child: CircleAvatar(
                      radius: 6,
                      backgroundColor: selectedIndex == index
                          ? KColors.customerPrimaryColor
                          : Colors.grey[300],
                    ),
                  ),
                ),
              );
            })
        : SizedBox();
  }

  Widget _buildImageView(BuildContext context) {
    return Hero(
      tag: widget.productModel.id,
      child: Container(
        height: 300,
        child: widget.productModel.imageUrl != null &&
                widget.productModel.imageUrl.isNotEmpty
            ? PageView.builder(
                itemCount: widget.productModel.imageUrl?.length ?? 0,
                onPageChanged: (value) {
                  _selectedIndex.value = value;
                },
                itemBuilder: (context, index) {
                  return Center(
                    child: customNetworkImage(
                      widget.productModel.imageUrl[index],
                      fit: BoxFit.cover,
                      height: 300,
                      placeholder: BPlaceHolder(
                        height: 300,
                      ),
                    ),
                  );
                },
              )
            : Image.asset(
                KImages.intro2, //TODO: NOT AVAILABLE IMAGE
                height: 300,
              ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          "${widget.productModel.title.capitalize()}, ${widget.productModel.description.capitalize()}, ${widget.productModel?.size}${widget.productModel?.productSize?.asString()}",
          variant: TypographyVariant.titleSmall,
        ),
        SizedBox(height: 20),
        Container(
          height: 50,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BText(
                "₹ ${widget.productModel.price.toStringAsFixed(2)}",
                variant: TypographyVariant.h1,
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
              _buildAddButtonCounter(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddButtonCounter(BuildContext context) {
    final locale = AppLocalizations.of(context);
    final inStock = widget.productModel.inStock != null
        ? widget.productModel.inStock
        : true;

    return Consumer<CStoreState>(
      builder: (context, state, child) => widget.productModel.tempQty > 0
          ? Card(
              color: Colors.white,
              elevation: 10.0,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        state.updateItemQuantity(1, widget.productModel, false);
                      },
                      child: widget.productModel.tempQty == 1
                          ? Icon(
                              Icons.delete,
                              color: KColors.customerPrimaryColor,
                              size: 30,
                            )
                          : Icon(
                              Icons.remove,
                              color: KColors.customerPrimaryColor,
                              size: 30,
                            ),
                    ),
                    SizedBox(width: 10),
                    BText(
                      widget.productModel.tempQty.toString(),
                      variant: TypographyVariant.h2,
                    ),
                    SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        state.updateItemQuantity(1, widget.productModel, true);
                      },
                      child: Icon(
                        Icons.add,
                        color: KColors.customerPrimaryColor,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : BFlatButton(
              text: locale.getTranslatedValue(KeyConstants.addToCart),
              isWraped: true,
              isBold: true,
              color: inStock
                  ? KColors.customerPrimaryColor
                  : KColors.disableButtonColor,
              onPressed: inStock
                  ? () {
                      state.updateItemQuantity(1, widget.productModel, true);
                    }
                  : null,
            ),
    );
  }
}
