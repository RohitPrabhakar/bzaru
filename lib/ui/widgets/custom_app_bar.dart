import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/navigation_helper.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class BAppBar extends PreferredSize {
  final String title;
  final Function onLeadingPressed;
  final IconData trailingIcon;
  final Color bgColor;
  final TextStyle textStyle;
  final bool removeLeadingIcon;
  final Widget leadingIcon;
  final Color iconColor;
  final Function onTrailingPressed;
  final double elevation;
  final Function onPressed;
  final bool centerTitle;
  final MainAxisAlignment titleAlignment;
  const BAppBar({
    Key key,
    @required this.title,
    this.onLeadingPressed,
    this.trailingIcon,
    this.bgColor,
    this.removeLeadingIcon = false,
    this.textStyle,
    this.leadingIcon,
    this.iconColor,
    this.onTrailingPressed,
    this.elevation,
    this.onPressed,
    this.centerTitle = true,
    this.titleAlignment = MainAxisAlignment.spaceBetween,
  });

  @override
  Size get preferredSize => Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: elevation ?? 5.0,
      backgroundColor: bgColor ?? Theme.of(context).primaryColor,
      automaticallyImplyLeading: false,
      centerTitle: centerTitle,
      title: Container(
        height: preferredSize.height,
        child: Row(
          mainAxisAlignment: titleAlignment,
          children: [
            removeLeadingIcon
                ? leadingIcon ?? SizedBox(height: 40, width: 40)
                : Container(
                    width: 40,
                    child: BIcon(
                      iconData: Icons.arrow_back_ios,
                      iconSize: 23,
                      color: iconColor ?? Colors.white,
                      onTap: onLeadingPressed ??
                          onPressed ??
                          () {
                            if (Navigator.canPop(context))
                              Navigator.of(context).pop();
                          },
                    ),
                  ),
            Container(
              height: 40,
              width: MediaQuery.of(context).size.width * 0.55,
              alignment: Alignment.center,
              child: BText(
                title ?? "Bzaru App",
                variant: TypographyVariant.title,
                style: textStyle ?? TextStyle(color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            trailingIcon != null
                ? Container(
                    width: 40,
                    alignment: Alignment.centerRight,
                    child: BIcon(
                      iconData: trailingIcon,
                      iconSize: 23,
                      color: iconColor ?? Colors.white,
                    ),
                  ).ripple(onTrailingPressed ?? null)
                : SizedBox(width: 40)
          ],
        ),
      ),
    );
  }
}
