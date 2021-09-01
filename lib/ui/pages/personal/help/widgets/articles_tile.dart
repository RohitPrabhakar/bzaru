import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/model/help_model.dart';
import 'package:flutter_bzaru/ui/pages/common/webview/webview.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticlesTile extends StatelessWidget {
  final HelpModel model;
  const ArticlesTile({
    Key key,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (await canLaunch(model.redirectUrl)) {
          // Navigator.of(context).push(CupertinoPageRoute(
          //     builder: (_) => SectionWebView(
          //           url: "https://bzaru.com",
          //           className: "col-sm-7",
          //         )));
          await launch(model.redirectUrl, forceWebView: true);
        } else {
          Utility.displaySnackbar(context,
              msg: 'Could not launch ${model.redirectUrl}');
        }
      },
      child: Column(
        children: [
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BText(
                  model.title,
                  variant: TypographyVariant.h2,
                  style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 15,
                  ),
                ),
                Icon(
                  Icons.navigate_next,
                  size: 40,
                  color: Theme.of(context).primaryColor,
                )
              ],
            ),
          ).pH(20),
          Divider(
            color: Colors.grey[400],
            thickness: 1.0,
          )
        ],
      ),
    );
  }
}
