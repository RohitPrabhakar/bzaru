import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/pages/common/profile/helper/profile_helpers.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/user_profile_image.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class BusinessProfileImage extends StatefulWidget {
  final ValueChanged<File> onProfilechanged;
  final ValueChanged<File> onBannerechanged;

  const BusinessProfileImage(
      {Key key, this.onProfilechanged, this.onBannerechanged})
      : super(key: key);
  @override
  _BusinessProfileImageState createState() => _BusinessProfileImageState();
}

class _BusinessProfileImageState extends State<BusinessProfileImage> {
  File _bannerImage;

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setState(() {
      _bannerImage = File(image.path);
      widget.onBannerechanged(_bannerImage);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileState>(
      builder: (context, state, child) {
        return Container(
          height: 230,
          child: Stack(
            children: [
              Container(
                height: 200,
                width: double.infinity,
                child: _bannerImage != null
                    ? Image.file(
                        _bannerImage,
                        fit: BoxFit.fitWidth,
                      )
                    : state.merchantProfileModel?.coverImage != null
                        ? customNetworkImage(
                            state.merchantProfileModel?.coverImage,
                            fit: BoxFit.fitWidth)
                        : Container(color: KColors.businessPrimaryColor),
              ).ripple(() async {
                await pickFromGallery();
              }),
              ProfileHelper.checkIfMerchant(context) &&
                      state.merchantProfileModel.coverImage != null
                  ? SizedBox()
                  : _bannerImage != null
                      ? SizedBox()
                      : Align(
                          alignment: Alignment.center,
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 30,
                          ).ripple(() async {
                            await pickFromGallery();
                          }),
                        ),
              Positioned(
                left: 20,
                bottom: 0.0,
                child: UserProfileImage(
                  radius: 45,
                  profilePath: state.merchantProfileModel?.avatar,
                  onFileSelected: (file) {
                    widget.onProfilechanged(file);
                  },
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.camera_alt),
                  radius: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
