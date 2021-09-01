import 'package:flutter/material.dart';
import 'package:flutter_bzaru/locale/app_localizations.dart';
import 'package:flutter_bzaru/locale/key_contants.dart';
import 'package:flutter_bzaru/providers/help_state.dart';
import 'package:flutter_bzaru/ui/pages/personal/help/widgets/articles_tile.dart';
import 'package:flutter_bzaru/ui/theme/app_themes.dart';
import 'package:flutter_bzaru/ui/widgets/overlay_loading.dart';
import 'package:flutter_bzaru/ui/widgets/widgets.dart';
import 'package:flutter_bzaru/ui/theme/themes.dart';
import 'package:provider/provider.dart';

class BGetHelp extends StatefulWidget {
  @override
  _BGetHelpState createState() => _BGetHelpState();
}

class _BGetHelpState extends State<BGetHelp> {
  TextEditingController _searchController;
  ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _searchController.dispose();
    _isLoading.dispose();
    super.dispose();
  }

  @override
  void initState() {
    getHelpArticles();
    _searchController = TextEditingController();
    super.initState();
  }

  Future<void> getHelpArticles() async {
    _isLoading.value = true;
    final state = Provider.of<HelpState>(context, listen: false);
    await state.getHelpArticles();
    _isLoading.value = false;
  }

  Widget _buildSearchBar(HelpState state) {
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
          Expanded(
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: locale.getTranslatedValue(KeyConstants.search),
                hintStyle: KStyles.hintTextStyle.copyWith(color: Colors.grey),
              ),
              autocorrect: false,
              cursorHeight: 23,
              textInputAction: TextInputAction.search,
              keyboardType: TextInputType.text,
              style: KStyles.fieldTextStyle,
              onChanged: (value) {
                if (value.isEmpty) {
                  state.clearSearchedList();
                }
                state.searchSearchedWord(value);
              },
            ),
          ),
          SizedBox(width: 20),
          Icon(
            Icons.search,
            size: 26,
            color: KColors.primaryDarkColor,
          )
        ],
      ),
    );
  }

  Widget _buildPopularArticles() {
    final state = Provider.of<HelpState>(context, listen: false);
    final popularArticles = state.popularArticles;
    final locale = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BText(
          locale.getTranslatedValue(KeyConstants.popularArticles),
          variant: TypographyVariant.titleSmall,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
        ).pH(20),
        SizedBox(height: 20),
        Container(
          child: ListView.builder(
            itemCount: popularArticles.length,
            shrinkWrap: true,
            itemBuilder: (context, index) =>
                ArticlesTile(model: popularArticles[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildSerachedArticles(HelpState state) {
    return Container(
      child: ListView.builder(
        itemCount: state.searchedArticles.length,
        shrinkWrap: true,
        itemBuilder: (context, index) =>
            ArticlesTile(model: state.searchedArticles[index]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context);

    return Scaffold(
        appBar: BAppBar(
          title: locale.getTranslatedValue(KeyConstants.helpCenter),
        ),
        body: ValueListenableBuilder(
          valueListenable: _isLoading,
          builder: (context, isLoading, _) => isLoading
              ? OverlayLoading(
                  showLoader: _isLoading,
                  bgScreenColor: Colors.white,
                  loadingMessage:
                      locale.getTranslatedValue(KeyConstants.gettingHelp),
                )
              : Consumer<HelpState>(
                  builder: (context, state, child) => SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 20),
                        BText(
                          locale.getTranslatedValue(KeyConstants.howCanweHelp),
                          variant: TypographyVariant.titleSmall,
                          style: TextStyle(fontSize: 18),
                        ).pH(20),
                        SizedBox(height: 10),
                        _buildSearchBar(state).pH(20),
                        SizedBox(height: 30),
                        state.searchedkeyWord.isEmpty
                            ? _buildPopularArticles()
                            : state.searchedArticles.isNotEmpty
                                ? _buildSerachedArticles(state)
                                : Container(
                                    height: 300,
                                    child: Center(
                                      child: BText(
                                        locale.getTranslatedValue(
                                            KeyConstants.searchSomethingElse),
                                        variant: TypographyVariant.titleSmall,
                                      ),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
        ));
  }
}
