import 'package:flutter/material.dart';
import 'package:flutter_bzaru/helper/shared_preference_helper.dart';
import 'package:flutter_bzaru/helper/utility.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/customer/c_explore_state.dart';
import 'package:flutter_bzaru/ui/theme/styles.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class ExploreSearchBar extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;

  const ExploreSearchBar({Key key, this.scaffoldKey}) : super(key: key);
  @override
  _ExploreSearchBarState createState() => _ExploreSearchBarState();
}

class _ExploreSearchBarState extends State<ExploreSearchBar> {
  TextEditingController _searchController;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  ValueNotifier<bool> _isEmptyText = ValueNotifier<bool>(true);

  @override
  void dispose() {
    _searchController.dispose();
    _isLoading.dispose();
    _isEmptyText.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<CExploreState>(context, listen: false);
    final locale = AppLocalizations.of(context);

    return Container(
      height: 50,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.black),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              _searchController.clear();
              _isEmptyText.value = true;
              state.clearState();
            },
            child: Icon(
              Icons.arrow_back_ios,
              size: 23,
              color: Colors.grey,
            ),
          ),
          SizedBox(width: 5),
          Expanded(
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText:
                    locale.getTranslatedValue(KeyConstants.searchForProduct),
                hintStyle: KStyles.hintTextStyle.copyWith(color: Colors.grey),
              ),
              autocorrect: false,
              cursorHeight: 23,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: KStyles.fieldTextStyle,
              onChanged: (value) {
                if (value.isEmpty) {
                  _isEmptyText.value = true;
                }
                _isEmptyText.value = false;
              },
              onFieldSubmitted: (value) async {
                if (Utility.connectionCode == 0) {
                  Utility.displaySnackbar(
                    context,
                    key: widget.scaffoldKey,
                    msg:
                        locale.getTranslatedValue(KeyConstants.pleaseConnectTo),
                  );
                } else {
                  if (value != null && value.isNotEmpty) {
                    state.setQuery(value);
                    await state.getSearchItemAndStore(value);
                  }
                }
              },
            ),
          ),
          SizedBox(width: 20),
          ValueListenableBuilder(
            valueListenable: _isEmptyText,
            builder: (context, isEmpty, child) => isEmpty
                ? SizedBox()
                : GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      _isEmptyText.value = true;
                      state.setQuery("");
                    },
                    child: Icon(
                      Icons.clear,
                      size: 26,
                      color: KColors.primaryDarkColor,
                    ),
                  ),
          )
        ],
      ),
    );
  }
}
