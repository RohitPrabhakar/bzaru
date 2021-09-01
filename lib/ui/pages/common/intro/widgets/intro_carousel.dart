import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/images.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/model/intro_model.dart';
import 'package:flutter_bzaru/ui/theme/colors.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';

class IntroCarousel extends StatefulWidget {
  @override
  _IntroCarouselState createState() => _IntroCarouselState();
}

class _IntroCarouselState extends State<IntroCarousel> {
  int _selectedindex = 0;
  List<IntroModel> introList = [];

  void getIntroList() async {
    final locale = AppLocalizations.of(context);

    introList = [
      IntroModel(
        title: locale.getTranslatedValue(KeyConstants.tapAButton),
        subTitle: locale.getTranslatedValue(KeyConstants.getGroceryDel),
        imagePath: KImages.intro1,
      ),
      IntroModel(
          title: locale.getTranslatedValue(KeyConstants.shopMoreDeals),
          subTitle: locale.getTranslatedValue(KeyConstants.saveWithExc),
          imagePath: KImages.intro2),
      IntroModel(
        title: locale.getTranslatedValue(KeyConstants.shopMoreDeals),
        subTitle: locale.getTranslatedValue(KeyConstants.saveWithExc),
        imagePath: KImages.intro3,
      ),
    ];
  }

  ///Building Single `Dot`
  Widget _buildDots(int index) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      child: Image.asset(
        _selectedindex == index ? KImages.dotActive : KImages.dotInactive,
        height: 12.0,
        width: 12.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.of(context).size.height * 0.45;
    getIntroList();
    return Column(
      children: [
        Container(
          // height: 400,
          height: maxHeight,
          // color: Colors.yellow,
          child: PageView.builder(
            itemCount: introList.length,
            onPageChanged: (value) {
              setState(() {
                _selectedindex = value;
              });
            },
            itemBuilder: (context, index) => Container(
              height: maxHeight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(height: 20),
                  Image.asset(
                    introList[index].imagePath,
                    height: maxHeight * 0.45,
                  ),
                  // SizedBox(height: 40),
                  Container(
                    constraints: BoxConstraints(maxWidth: 250, minWidth: 180),
                    child: BText(
                      introList[index].title,
                      variant: TypographyVariant.titleSmall,
                      style: TextStyle(
                          color: KColors.primaryDarkColor,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  // SizedBox(height: 10),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    // constraints: BoxConstraints(maxWidth: 280, minWidth: 200),
                    child: BText(
                      introList[index].subTitle,
                      variant: TypographyVariant.bodyLarge,
                      style: TextStyle(color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: introList
              .asMap()
              .entries
              .map((mapEntry) => _buildDots(mapEntry.key))
              .toList(),
        ),
        SizedBox(height: 20),
      ],
    );
  }
}
