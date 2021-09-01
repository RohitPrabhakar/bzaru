import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_order_state.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ItemsCheckoutTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final images = Provider.of<COrderState>(context, listen: false).itemImages;
    final locale = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_box,
                  size: 30,
                  color: KColors.customerPrimaryColor,
                ),
                SizedBox(width: 10),
                Flexible(
                    child: Consumer<COrderState>(
                  builder: (context, state, child) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      BText(
                        state.totalItems > 1
                            ? "${state.totalItems} ${locale.getTranslatedValue(KeyConstants.items)}"
                            : "${state.totalItems} ${locale.getTranslatedValue(KeyConstants.item)}",
                        variant: TypographyVariant.h1,
                        style: TextStyle(fontWeight: FontWeight.w400),
                      ),
                      SizedBox(height: 5),
                      images != null && images.isNotEmpty
                          ? Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width,
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.horizontal,
                                children: images
                                    .map((imageUrl) => _buildImage(imageUrl))
                                    .toList(),
                              ),
                            )
                          : SizedBox()
                    ],
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return customNetworkImage(
      imageUrl,
      height: 40,
      width: 40,
      fit: BoxFit.contain,
      placeholder: BPlaceHolder(height: 40, width: 60),
    );
  }
}
