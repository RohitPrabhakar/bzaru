import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/chat_message_model.dart';
import 'package:flutter_bzaru/model/order_model.dart';
import 'package:flutter_bzaru/model/profile_model.dart';
import 'package:flutter_bzaru/providers/chat_state.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/custom_cached_image.dart';
import 'package:flutter_bzaru/ui/widgets/custom_icon.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

///Screen for only when customer interacts
///with any chat for Business, before it used to be a single screen
///now divided into two.

class CChatScreen extends StatefulWidget {
  final OrdersModel ordersModel;
  final ChatMessage chatMessageModel;

  const CChatScreen({Key key, this.ordersModel, this.chatMessageModel})
      : super(key: key);

  static CupertinoPageRoute getRoute(
      OrdersModel ordersModel, ChatMessage chatMessageModel) {
    return CupertinoPageRoute(
        builder: (_) => CChatScreen(
              ordersModel: ordersModel,
              chatMessageModel: chatMessageModel,
            ));
  }

  @override
  _CChatScreenState createState() => _CChatScreenState();
}

class _CChatScreenState extends State<CChatScreen> {
  ValueNotifier<bool> displayMic = ValueNotifier<bool>(true);
  TextEditingController messageController;
  ProfileModel profileModel;
  String senderId;
  String userImage;

  // ChatState state;
  ScrollController _controller;

  GlobalKey<ScaffoldMessengerState> _scaffoldKey;

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    messageController = new TextEditingController()..addListener(textListner);
    _scaffoldKey = GlobalKey<ScaffoldMessengerState>();
    _controller = ScrollController();
    final chatState = Provider.of<ChatState>(context, listen: false);
    chatState.setChatUser = ProfileModel(
      id: widget.ordersModel?.merchantId ?? widget.chatMessageModel?.receiverId,
      name: widget.ordersModel?.merchantName ??
          widget.chatMessageModel?.receiverName,
    );
    final pref = GetIt.instance<SharedPrefrenceHelper>();
    senderId =
        widget.ordersModel?.customerId ?? widget.chatMessageModel?.senderId;
    chatState.databaseInit(
      widget.ordersModel?.merchantId ?? widget.chatMessageModel?.receiverId,
      widget.ordersModel?.customerId ?? widget.chatMessageModel?.senderId,
    );
    pref.getUserProfile().then((model) {
      profileModel = model;
      chatState.getchatDetailAsync();
    });

    super.initState();
  }

  void textListner() {
    if (messageController.text.isEmpty) {
      displayMic.value = true;
    } else {
      displayMic.value = false;
    }
  }

  Widget _chatScreenBody() {
    final state = Provider.of<ChatState>(context);
    final locale = AppLocalizations.of(context);

    if (state.messageList == null || state.messageList.isEmpty) {
      return Center(
        child: Text(
          locale.getTranslatedValue(KeyConstants.noMessage),
          style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
        ),
      );
    }
    return ListView.builder(
      controller: _controller,
      shrinkWrap: true,
      reverse: true,
      physics: BouncingScrollPhysics(),
      itemCount: state.messageList.length,
      itemBuilder: (context, index) {
        return chatMessage(state.messageList[index]);
      },
    );
  }

  Widget chatMessage(ChatMessage message) {
    if (senderId == null) {
      return Container();
    }
    if (message.senderId == senderId)
      return _message(message, true);
    else
      return _message(message, false);
  }

  Widget _message(ChatMessage chat, bool myMessage) {
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment:
          myMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisAlignment:
          myMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(
              width: 15,
            ),
            // myMessage
            //     ? SizedBox()
            //     : CircleAvatar(
            //         // backgroundColor: Colors.transparent,
            //         child: Text("N/A")
            //         // backgroundImage: customAdvanceNetworkImage(userImage),
            //         ),
            Expanded(
              child: Container(
                alignment:
                    myMessage ? Alignment.centerRight : Alignment.centerLeft,
                margin: EdgeInsets.only(
                  right: myMessage ? 10 : (AppThemes.fullWidth(context) / 4),
                  top: 20,
                  left: myMessage ? (AppThemes.fullWidth(context) / 4) : 10,
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: getBorder(myMessage),
                        color: myMessage
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade100,
                      ),
                      child: Text(
                        chat.message,
                        style: TextStyle(
                          fontSize: 16,
                          color: myMessage ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      bottom: 0,
                      right: 0,
                      left: 0,
                      child: InkWell(
                        borderRadius: getBorder(myMessage),
                        onLongPress: () {
                          var text = ClipboardData(text: chat.message);
                          Clipboard.setData(text);
                          _scaffoldKey.currentState.hideCurrentSnackBar();
                          _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              backgroundColor: KColors.bgColor,
                              content: Text(
                                locale.getTranslatedValue(
                                    KeyConstants.messageCopied),
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                          );
                        },
                        child: SizedBox(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        // Padding(
        //   padding: EdgeInsets.only(right: 10, left: 10),
        //   child: Text(
        //     Utility.getChatTime(chat.createdAt),
        //     style: Theme.of(context).textTheme.caption.copyWith(fontSize: 12),
        //   ),
        // )
      ],
    );
  }

  BorderRadius getBorder(bool myMessage) {
    return BorderRadius.only(
      topLeft: myMessage ? Radius.circular(10) : Radius.circular(0),
      topRight: myMessage ? Radius.circular(0) : Radius.circular(10),
      bottomRight: Radius.circular(10),
      bottomLeft: Radius.circular(10),
    );
  }

  Widget _bottomEntryField() {
    final locale = AppLocalizations.of(context);

    return Align(
      alignment: Alignment.bottomLeft,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Divider(
            thickness: 0,
            height: 1,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  onSubmitted: (val) async {
                    submitMessage();
                  },
                  controller: messageController,
                  decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 13),
                    alignLabelWithHint: true,
                    hintText:
                        '${locale.getTranslatedValue(KeyConstants.startWithMessage)}...',
                    // suffixIcon: IconButton(icon: Icon(Icons.send), onPressed: submitMessage),
                    // fillColor: Colors.black12, filled: true
                  ),
                ),
              ),
              if (messageController.text.isEmpty)
                ValueListenableBuilder<bool>(
                  valueListenable: displayMic,
                  builder: (BuildContext context, bool value, Widget child) {
                    return IconButton(
                      icon: Icon(value ? Icons.send : Icons.send),
                      onPressed: () {
                        if (!value) {
                          submitMessage();
                        }
                      },
                    );
                  },
                ),
            ],
          )
        ],
      ),
    );
  }

  void submitMessage() {
    var state = Provider.of<ChatState>(context, listen: false);
    // var authstate = Provider.of<AuthState>(context, listen: false);
    ChatMessage message;
    message = ChatMessage(
      message: messageController.text,
      createdAt: DateTime.now().toString(),
      senderId: profileModel.id,
      receiverId: state.chatUser.id,
      seen: false,
      timeStamp: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
      senderName: profileModel.name,
      receiverName: widget.ordersModel?.merchantName ??
          widget.chatMessageModel?.receiverName,
      receiverImage: widget.ordersModel?.merchantCoverImage ??
          widget.chatMessageModel?.receiverImage,
    );
    if (messageController.text == null || messageController.text.isEmpty) {
      return;
    }
    ProfileModel myUser = ProfileModel(
        name: profileModel.name,
        id: profileModel.id,
        avatar: profileModel.avatar);
    ProfileModel secondUser = ProfileModel(
      name: state.chatUser.name,
      id: state.chatUser.id,
      avatar: state.chatUser.avatar,
    );
    print("----------");

    state.onMessageSubmitted(message, myUser: myUser, secondUser: secondUser);
    Future.delayed(Duration(milliseconds: 50)).then((_) {
      messageController.clear();
    });

    Provider.of<ChatState>(context, listen: false).getChatsForCustomer();

    try {
      // final state = Provider.of<ChatUserState>(context,listen: false);
      if (state.messageList != null &&
          state.messageList.length > 1 &&
          _controller.offset > 0) {
        _controller.animateTo(
          0.0,
          curve: Curves.easeOut,
          duration: const Duration(milliseconds: 300),
        );
      }
    } catch (e) {
      print("[Error] $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<ChatState>(context, listen: false);
    userImage = state.chatUser.avatar;
    final locale = AppLocalizations.of(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return true;
      },
      child: Scaffold(
        key: _scaffoldKey,
        appBar: BAppBar(
          title: widget.ordersModel != null
              ? widget.ordersModel?.merchantName
              : widget.chatMessageModel?.receiverName ??
                  locale.getTranslatedValue(KeyConstants.message),
          removeLeadingIcon: true,
          centerTitle: false,
          titleAlignment: MainAxisAlignment.start,
          onLeadingPressed: null,
          leadingIcon: Row(
            children: [
              Container(
                width: 40,
                child: BIcon(
                  iconData: Icons.arrow_back_ios,
                  iconSize: 23,
                  color: Colors.white,
                  onTap: () {
                    Navigator.of(context).pop((result) => print(result));
                  },
                ),
              ),
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: customNetworkImage(
                    widget.ordersModel != null
                        ? widget.ordersModel?.merchantImage
                        : widget.chatMessageModel?.receiverImage,
                    fit: BoxFit.cover,
                    defaultHolder: Image.asset(KImages.noUserImage),
                  ),
                ),
              ),
              SizedBox(width: 16)
            ],
          ),
        ),
        body: SafeArea(
          child: Stack(
            children: <Widget>[
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: EdgeInsets.only(bottom: 50),
                  child: _chatScreenBody(),
                ),
              ),
              _bottomEntryField()
            ],
          ),
        ),
      ),
    );
  }
}
