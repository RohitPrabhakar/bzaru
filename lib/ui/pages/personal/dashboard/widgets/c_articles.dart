import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/articles_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/store_front.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CDashArticlesTile extends StatelessWidget {
  final ArticlesModel articlesModel;
  final String langCode;

  const CDashArticlesTile({
    Key key,
    @required this.articlesModel,
    this.langCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //     context,
        //     CupertinoPageRoute(
        //       builder: (context) =>
        //     ));
      },
      child: Card(
        margin: EdgeInsets.symmetric(vertical: 5.0),
        elevation: 10.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                color: Colors.white,
                child: customNetworkImage(
                  articlesModel.imageUrl,
                  fit: BoxFit.cover,
                  placeholder: BPlaceHolder(
                    height: 70,
                    width: 70,
                  ),
                  height: 70,
                  width: 70,
                ),
              ),
              SizedBox(width: 20),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: BText(
                        langCode != null
                            ? articlesModel.lang[langCode ?? "en"]
                            : articlesModel.title ?? "Article Title",
                        variant: TypographyVariant.h1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.w400),
                        maxLines: 2,
                      ),
                    ),
                    Icon(
                      Icons.navigate_next,
                      size: 40,
                      color: KColors.customerPrimaryColor,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
