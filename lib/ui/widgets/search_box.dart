import 'package:flutter/material.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class SearchBox extends StatelessWidget {
  final Function onTap;

  const SearchBox({Key key, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 23,
              color: Colors.grey[600],
            ),
            SizedBox(width: 5.0),
            BText(
              "Search...",
              variant: TypographyVariant.h2,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.grey[600], fontWeight: FontWeight.w300),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}
