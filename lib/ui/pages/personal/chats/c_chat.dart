import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/chat_state.dart';
import 'package:flutter_bzaru/ui/pages/business/chats/widgets/b_chat_tile.dart';
import 'package:flutter_bzaru/ui/pages/personal/chats/widgets/c_chat_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class CustomerChatScreen extends StatefulWidget {
  @override
  _CustomerChatScreenState createState() => _CustomerChatScreenState();
}

class _CustomerChatScreenState extends State<CustomerChatScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getChatsList();
      isLoading.value = false;
    });
    super.initState();
  }

  Future<void> getChatsList() async {
    final state = Provider.of<ChatState>(context, listen: false);

    await state.getChatsForCustomer();
    final len = state.allMessageList.length;
    print("LEN-> $len");
    await SharedPrefrenceHelper().setMessageLength(len ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.chats),
        bgColor: KColors.customerPrimaryColor,
        removeLeadingIcon: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, loading, _) =>
            Consumer<ChatState>(builder: (context, state, child) {
          print(state.lastMessageChat);
          return loading
              ? Center(child: CircularProgressIndicator())
              : state.lastMessageChat != null &&
                      state.lastMessageChat.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: state.lastMessageChat.length,
                      itemBuilder: (context, index) => CChatTile(
                            chatModel: state.lastMessageChat[index],
                          ))
                  : Center(
                      child: BText(
                        locale.getTranslatedValue(KeyConstants.noChatsFound),
                        variant: TypographyVariant.titleSmall,
                      ),
                    );
        }),
      ),
    );
  }
}
