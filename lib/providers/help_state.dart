import 'package:flutter_bzaru/model/help_model.dart';
import 'package:flutter_bzaru/providers/base_state.dart';
import 'package:flutter_bzaru/resource/repository/customer_repository.dart';

class HelpState extends BaseState {
  List<HelpModel> allArticles = [];
  List<HelpModel> popularArticles = [];
  List<HelpModel> searchedArticles = [];

  String searchedkeyWord = "";

  void searchSearchedWord(String value) {
    searchedArticles.clear();
    searchedkeyWord = value;

    allArticles.forEach((model) {
      if (model.title.toLowerCase().contains(searchedkeyWord.toLowerCase())) {
        searchedArticles.add(model);
      }
    });
    notifyListeners();
  }

  void clearSearchedList() {
    searchedArticles?.clear();
    searchedkeyWord = "";
    notifyListeners();
  }

  ///`Dividing articles on the basis of popular`
  Future<void> dividingArticles() async {
    popularArticles = List.from(allArticles); //TODO: REMOVE

    await Future.delayed(Duration(milliseconds: 500));
  }

  ///`Fetching all Articles`
  Future<void> getHelpArticles() async {
    final repo = getit.get<CustomerRepository>();
    isBusy = true;

    allArticles.clear();
    popularArticles.clear();
    searchedArticles.clear();
    final tempArticles = await execute(() async {
      return repo.getHelpArticles();
    });

    allArticles = List.from(tempArticles);
    await dividingArticles();

    isBusy = false;
    notifyListeners();
  }
}
