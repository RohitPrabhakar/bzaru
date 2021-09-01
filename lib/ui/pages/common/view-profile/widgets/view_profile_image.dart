import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/business/profile/widget/qr_code_generator.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class ViewBusinessProfileImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, state, child) {
        return Container(
          height: 230,
          padding: EdgeInsets.only(bottom: 10.0),
          child: Stack(
            children: [
              Container(
                height: 170,
                width: double.infinity,
                child: state.merchantProfileModel?.coverImage != null
                    ? customNetworkImage(
                        state.merchantProfileModel?.coverImage,
                        fit: BoxFit.fitWidth,
                      )
                    : Container(color: KColors.businessPrimaryColor),
              ),
              _buildEditProfileRow(context),
              // _buildQRCode(context),
              Positioned(
                left: 20,
                bottom: 0.0,
                child: CircleAvatar(
                  radius: 45,
                  backgroundImage: state.merchantProfileModel?.avatar != null
                      ? CachedNetworkImageProvider(
                          state.merchantProfileModel?.avatar,
                        )
                      : AssetImage(KImages.userIcon),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  ///`DEVELOPER PROPOSAL`
  Widget _buildEditProfileRow(BuildContext context) {
    final state = Provider.of<ProfileState>(context, listen: false);
    return Positioned(
      left: 120,
      bottom: 2.0,
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: BText(
                state.merchantProfileModel.name,
                variant: TypographyVariant.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            Flexible(child: _buildQRCode(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildQRCode(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      alignment: Alignment.bottomRight,
      child: Icon(
        Icons.qr_code,
        color: Colors.black,
      ),
    ).ripple(() {
      Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => QRCodeGenerator(),
            fullscreenDialog: true,
          ));
    });
  }
}
