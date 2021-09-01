import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';

class ArticlesTile extends StatelessWidget {
  final String title;
  const ArticlesTile({
    Key key,
    this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              BText(
                title,
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
    );
  }
}
