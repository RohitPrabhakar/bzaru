import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/functions_helper.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/ui/pages/business/chats/widgets/b_chat_screen.dart';

import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_place_holder.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class BChatTile extends StatefulWidget {
  final ChatMessage chatModel;

  const BChatTile({Key key, this.chatModel}) : super(key: key);

  @override
  _BChatTileState createState() => _BChatTileState();
}

class _BChatTileState extends State<BChatTile> {
  String merchantId;
  String time;
  String receiverId;
  String senderId;
  String receiverName;
  String receiverImage;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isSender = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _isLoading.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      getInitialize();
    });
    super.initState();
  }

  void getInitialize() async {
    merchantId = await SharedPrefrenceHelper().getAccessToken();
    setIsSender();

    _isLoading.value = false;
  }

  void setIsSender() {
    _isSender.value = widget.chatModel.senderId == merchantId ? true : false;
  }

  void setUsersDetails() {
    senderId = widget.chatModel.senderId;
    receiverId = widget.chatModel.receiverId;
    receiverName = widget.chatModel.receiverName;
    receiverImage = widget.chatModel.receiverImage;

    print("SENDER ID -> $senderId");
    print("RECEIVER ID -> $receiverId");
    print("RECEIVER NAME -> $receiverName");
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);
    setUsersDetails();
    setIsSender();
    final dateTime = DateTime.tryParse(widget.chatModel.createdAt);
    time = BFunctionsHelper.timeFromDateTime(dateTime);
    return ValueListenableBuilder(
      valueListenable: _isLoading,
      builder: (context, isLoading, child) => isLoading
          ? BPlaceHolder(
              width: double.infinity,
              height: 50,
            )
          : ValueListenableBuilder<bool>(
              valueListenable: _isSender,
              builder: (context, isSender, child) => Column(
                children: [
                  Container(
                    width: double.infinity,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(40),
                          child: customNetworkImage(
                            widget.chatModel.receiverImage,
                            defaultHolder: Image.asset(
                              KImages.noUserImage,
                              height: 60,
                              width: 60,
                            ),
                            fit: BoxFit.cover,
                            placeholder: Container(
                              height: 60,
                              width: 60,
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[100], blurRadius: 5.0)
                                ],
                              ),
                            ),
                            height: 60,
                            width: 60,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: BText(
                                      widget.chatModel.receiverName
                                              .capitalize() ??
                                          locale.getTranslatedValue(
                                              KeyConstants.customerName),
                                      variant: TypographyVariant.h2,
                                      style: TextStyle(
                                        color: KColors.businessPrimaryColor,
                                        fontSize: 18,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  BText(
                                    time,
                                    variant: TypographyVariant.h2,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w300,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 5.0),
                              Row(
                                children: [
                                  isSender
                                      ? Transform.rotate(
                                          angle: pi * 1.7,
                                          child: Icon(
                                            Icons.arrow_right_alt,
                                            color: Colors.grey,
                                          ),
                                        )
                                      : SizedBox(),
                                  Flexible(
                                    child: BText(
                                      widget.chatModel.message,
                                      variant: TypographyVariant.h2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w300,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ).pH(10),
                  Divider(),
                ],
              ).ripple(
                () {
                  Navigator.push(
                    context,
                    BChatScreen.getRoute(
                      null,
                      ChatMessage(
                        senderId: isSender ? senderId : receiverId,
                        receiverId: isSender ? receiverId : senderId,
                        receiverImage: receiverImage,
                        receiverName: receiverName,
                      ),
                    ),
                  ); //Passing null Chat Message Model
                },
              ),
            ),
    );
  }
}
