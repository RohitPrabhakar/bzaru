import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/model/category_model.dart';
import 'package:flutter_bzaru/providers/business/product_provider.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:provider/provider.dart';

class SubCategoryDropDown extends StatefulWidget {
  final ValueChanged<CategoryModel> onSelectedCategory;
  final String preDefinedCategory;
  final String langCode;

  const SubCategoryDropDown(
      {Key key,
      this.onSelectedCategory,
      this.preDefinedCategory,
      this.langCode})
      : super(key: key);

  @override
  _SubCategoryDropDownState createState() => _SubCategoryDropDownState();
}

class _SubCategoryDropDownState extends State<SubCategoryDropDown> {
  List<CategoryModel> categories;
  int selectedIndex = 0;
  ValueNotifier<int> _selectedValue;
  String langCode;

  @override
  void dispose() {
    _selectedValue.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getLocale();
    getCategories();
    super.initState();
  }

  void getLocale() async {
    langCode = await SharedPrefrenceHelper().getLanguageCode();
  }

  void getCategories() {
    final cat = Provider.of<ProductProvider>(context, listen: false).categories;
    categories = List.from(cat);
    if (widget.preDefinedCategory != null) {
      // print(widget.preDefinedCategory);
      selectedIndex = categories
          .indexWhere((model) => model.category == widget.preDefinedCategory);
      // print(selectedIndex);
      _selectedValue = ValueNotifier<int>(selectedIndex);
      widget.onSelectedCategory(categories[selectedIndex]);
    } else {
      categories.insert(
          0,
          CategoryModel(
            category: "select a category",
            lang: {"en": "select a category", "hi": "एक वर्ग का चयन करें"},
          ));
      _selectedValue = ValueNotifier<int>(0);
      widget.onSelectedCategory(categories[0]);
    }

    // }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(
          color: KColors.businessPrimaryColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(5.0),
        color: Colors.white,
      ),
      child: ValueListenableBuilder(
        valueListenable: _selectedValue,
        builder: (context, value, _) => DropdownButton(
          underline: SizedBox(),
          iconEnabledColor: KColors.businessPrimaryColor,
          icon: Icon(Icons.keyboard_arrow_down),
          style: TextStyle(color: Colors.red),
          dropdownColor: Colors.white,
          value: value,
          isExpanded: true,
          items: categories
              .asMap()
              .entries
              .map((mE) => _buildDropDownItem(mE.key, mE.value))
              .toList(),
          onChanged: (value) {
            if (value != 0) {
              _selectedValue.value = value;
            }
          },
        ),
      ),
    );
  }

  DropdownMenuItem _buildDropDownItem(int value, CategoryModel category) {
    // print(langCode);
    // print(category.lang[widget.langCode]);
    return DropdownMenuItem(
      child: BText(
        widget.langCode != null
            ? category.lang[widget.langCode].capitalize()
            : category.category.capitalize(),
        variant: TypographyVariant.h2,
      ),
      onTap: () =>
          category.category != "Select a category" //TODO: TEST CATEGORY
              ? widget.onSelectedCategory(category)
              : null,
      value: value,
    );
  }
}
