import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/providers/profile_state.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class BListTile extends StatelessWidget {
  final IconData leadingIcon;
  final String title;
  final double tileHeight;
  final Widget nextScreen;
  final TextStyle textStyle;
  final Function onTap;

  const BListTile({
    Key key,
    this.leadingIcon,
    this.title,
    this.tileHeight = 50,
    this.nextScreen,
    this.textStyle,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: tileHeight,
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                leadingIcon ?? Icons.shop,
                size: 26,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 10.0),
              Consumer<ProfileState>(
                builder: (context, state, child) => BText(
                  title,
                  variant: TypographyVariant.title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ).merge(textStyle),
                ),
              ),
            ],
          ),
          Icon(
            Icons.navigate_next,
            size: 40,
            color: Theme.of(context).primaryColor,
          )
        ],
      ),
    ).ripple(
      nextScreen != null
          ? () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => nextScreen,
                  ));
            }
          : onTap ?? () {},
    );
  }
}
