import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/size_configs.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/ui/pages/personal/store-front/store_front.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class CStoreShortTile extends StatelessWidget {
  final ProfileModel profileModel;

  const CStoreShortTile({Key key, this.profileModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    sizeConfig.init(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => StoreFrontPage(
                profileModel: profileModel,
              ),
            ));
      },
      child: Container(
        alignment: profileModel.avatar != null && profileModel.avatar.isNotEmpty
            ? null
            : Alignment.center,
        width: sizeConfig.safeWidth * 22,
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: KColors.customerPrimaryColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: profileModel.avatar != null && profileModel.avatar.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: customNetworkImage(
                  profileModel.avatar,
                  fit: BoxFit.cover,
                  placeholder: BPlaceHolder(
                    width: sizeConfig.safeWidth * 22,
                  ),
                  width: sizeConfig.safeWidth * 22,
                ),
              )
            : BText(
                profileModel.name.capitalize(),
                variant: TypographyVariant.h1,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
      ),
    );
  }
}
