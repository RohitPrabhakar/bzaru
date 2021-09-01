import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class BFlatButton extends StatelessWidget {
  final String text;
  final bool isColored;
  final bool isWraped;
  final Function onPressed;
  final bool isBold;
  final EdgeInsetsGeometry padding;
  final Color color;
  final TextStyle textStyle;

  const BFlatButton({
    Key key,
    @required this.text,
    this.isColored = true,
    this.isWraped = false,
    @required this.onPressed,
    this.isBold = false,
    this.color,
    this.padding,
    this.textStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 40,
      width: isWraped ? null : double.infinity,
      decoration: BoxDecoration(
        color: color ?? KColors.customerPrimaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: FlatButton(
        onPressed: onPressed,
        padding:
            padding ?? const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        child: BText(
          text,
          variant: TypographyVariant.button,
          style: isBold
              ? TextStyle(fontWeight: FontWeight.w700, color: Colors.white)
                  .merge(textStyle)
              : null,
        ),
      ),
    );
  }
}

///`DELETE IF THIS IS NOT USED IN FUTURE`

class BFlatButton2 extends StatelessWidget {
  const BFlatButton2({
    Key key,
    this.onPressed,
    @required this.text,
    this.isLoading,
    this.isColored = true,
    this.isWraped = false,
    this.isBold = false,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    this.buttonColor,
    
  })  : assert(text != null),
        super(key: key);

  final Function onPressed;
  final String text;
  final bool isColored;
  final bool isWraped;
  final bool isBold;
  final EdgeInsetsGeometry padding;
  final ValueNotifier<bool> isLoading;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isWraped ? null : double.infinity,
      child: ValueListenableBuilder(
        valueListenable: isLoading,
        builder: (context, loading, child) {
          return FlatButton(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            disabledColor: KColors.disableButtonColor,
            padding: padding,
            textColor: !isColored ? Colors.white : KColors.primaryDarkColor,
            color: !isColored
                ? KColors.disableButtonColor
                : buttonColor ?? KColors.customerPrimaryColor,
            onPressed: loading ? null : onPressed,
            child: loading
                ? SizedBox(
                    height: 15,
                    width: 15,
                    child: FittedBox(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(KColors.primaryDarkColor),
                      ),
                    ),
                  )
                : child,
          );
        },
        child: BText(
          text,
          variant: TypographyVariant.button,
          style: isBold
              ? TextStyle(fontWeight: FontWeight.w700, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
