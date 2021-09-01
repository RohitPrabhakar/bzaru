import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/chat_state.dart';
import 'package:flutter_bzaru/ui/pages/business/chats/widgets/b_chat_tile.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/custom_app_bar.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class MerchantChatScreen extends StatefulWidget {
  @override
  _MerchantChatScreenState createState() => _MerchantChatScreenState();
}

class _MerchantChatScreenState extends State<MerchantChatScreen> {
  ValueNotifier<bool> isLoading = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
    isLoading.value = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await getChatsList();
      isLoading.value = false;
    });
  }

  Future<void> getChatsList() async {
    final state = Provider.of<ChatState>(context, listen: false);
    await state.getChatsForMerchant();
    final len = state.allMessageList.length;
    await SharedPrefrenceHelper().setMessageLength(len ?? 0);
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.chats),
        bgColor: KColors.businessPrimaryColor,
        removeLeadingIcon: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, loading, _) =>
            Consumer<ChatState>(builder: (context, state, child) {
          return loading
              ? Center(child: CircularProgressIndicator())
              : state.lastMessageChat != null &&
                      state.lastMessageChat.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      itemCount: state.lastMessageChat.length,
                      itemBuilder: (context, index) => BChatTile(
                        chatModel: state.lastMessageChat[index],
                      ),
                    )
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
