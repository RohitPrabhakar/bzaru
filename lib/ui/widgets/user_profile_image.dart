import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:image_picker/image_picker.dart';

class UserProfileImage extends StatefulWidget {
  final ValueChanged<File> onFileSelected;
  final String profilePath;
  final double radius;

  const UserProfileImage({
    Key key,
    this.onFileSelected,
    this.profilePath,
    this.radius = 55.0,
  }) : super(key: key);

  @override
  _UserProfileImageState createState() => _UserProfileImageState();
}

class _UserProfileImageState extends State<UserProfileImage> {
  File _image;

  Future<void> takePicture() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
      source: ImageSource.camera,
      imageQuality: 50,
    );
    setSelectedImage(image);
  }

  Future<void> pickFromGallery() async {
    final picker = ImagePicker();
    final image = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    setSelectedImage(image);
  }

  void setSelectedImage(PickedFile image) {
    setState(() {
      _image = File(image.path);
      if (widget.onFileSelected != null) widget.onFileSelected(_image);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // await pickFromGallery();
        await Utility.displayImagePicker(context, takePicture, pickFromGallery);
      },
      child: Stack(
        children: [
          CircleAvatar(
            radius: widget.radius,
            backgroundImage: _image != null
                ? FileImage(_image)
                : widget.profilePath != null
                    ? CachedNetworkImageProvider(widget.profilePath)
                    : AssetImage(KImages.userIcon),
          ),
          Positioned(
            right: widget.radius < 55 ? 30.0 : 40,
            bottom: widget.radius < 55 ? 25.0 : 40,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.camera_alt),
              radius: 15,
            ),
          )
        ],
      ),
    );
  }
}

class ImagePickSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

///`Original STACK Image with CamIcon`
// Stack(
//         children: [
//           Container(
//             height: 110,
//             width: 120,
//             // color: Colors.red,
//           ),
//           CircleAvatar(
//             radius: 55,
//             backgroundImage: _image != null
//                 ? FileImage(_image)
//                 : widget.profilePath != null
//                     ? CachedNetworkImageProvider(widget.profilePath)
//                     : AssetImage(KImages.userIcon),
//           ),

//           // Camera Icon
//           Positioned(
//             right: 0.0,
//             bottom: 15.0,
//             child: Container(
//               height: 30,
//               width: 30,
//               decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
//               child: Image.asset(
//                 KImages.camIcon,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           )
//         ],
//       ),
