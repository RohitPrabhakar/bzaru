import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/providers.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bzaru/helper/constants.dart';

class FindContactsPage extends StatefulWidget {
  @override
  _FindContactsPageState createState() => _FindContactsPageState();
}

class _FindContactsPageState extends State<FindContactsPage> {
  @override
  void initState() {
    super.initState();
    getContacts();
  }

  void getContacts() async {
    final state = Provider.of<AuthState>(context, listen: false);
    if (state.contacts != null && state.contacts.isNotEmpty) {
      return;
    } else {
      await state.getContacts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
      appBar: BAppBar(
        title: locale.getTranslatedValue(KeyConstants.contacts),
        centerTitle: true,
      ),
      body: Consumer<AuthState>(
        builder: (context, state, child) => state.isLoading
            ? Center(child: CircularProgressIndicator())
            : state.contacts != null && state.contacts.isNotEmpty
                ? ListView.builder(
                    itemCount: state.contacts?.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      Contact contact = state.contacts?.elementAt(index);
                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 2, horizontal: 18),
                        leading: (contact.avatar != null &&
                                contact.avatar.isNotEmpty)
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(contact.avatar),
                              )
                            : CircleAvatar(
                                child: Text(contact.initials()),
                                backgroundColor: Theme.of(context).primaryColor,
                              ),
                        title: Text(contact.displayName ?? ''),
                        // This can be further expanded to showing contacts detail
                        // onPressed().
                        onTap: () async {
                          final customerContact =
                              contact.phones.toList()[0].value;
                          final body = Constants.appLink;
                          try {
                            String _result = await sendSMS(
                                message: body, recipients: [customerContact]);
                          } catch (error) {
                            Utility.displaySnackbar(context,
                                msg: "Cannot send the message at the moment");
                          }

                          // final url = "sms:$customerContact?body=$body";

                          // await launch(url);
                        },
                      );
                    },
                  )
                : Center(
                    child: BText(
                      locale.getTranslatedValue(KeyConstants.noContactsFound),
                      variant: TypographyVariant.h1,
                    ),
                  ),
      ),
    );
  }
}
