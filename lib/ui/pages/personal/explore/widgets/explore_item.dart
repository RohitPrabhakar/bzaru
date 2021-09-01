import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class ExploreItem extends StatelessWidget {
  final String imageLink;
  final String title;
  final String emptyImageLink;

  const ExploreItem({Key key, this.imageLink, this.title, this.emptyImageLink})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Container(
      width: 80,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: customNetworkImage(
              imageLink ?? emptyImageLink,
              height: 60,
              width: 60,
              placeholder: BPlaceHolder(
                height: 60,
                width: 60,
              ),
            ),
          ),
          SizedBox(height: 5.0),
          BText(
            title ?? locale.getTranslatedValue(KeyConstants.title),
            variant: TypographyVariant.h3,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontWeight: FontWeight.w300, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
