import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bzaru/resource/repository/repository.dart';
import 'package:get_it/get_it.dart';

class BaseState extends ChangeNotifier {
  bool _isBusy = false;

  bool get isBusy => _isBusy;
  final getit = GetIt.instance;

  set isBusy(bool val) {
    _isBusy = val;
    notifyListeners();
  }

  Future<T> execute<T>(Future<T> Function() handler,{String label = "Error", Function(dynamic) onError,Function(T) onSucess}) async {
    try {
      final data = await handler();
      if(onSucess != null){
       return onSucess(data);
      }
      return data;
    } catch (error, strackTrace) {
      log(label,error: error, stackTrace: strackTrace);
      if(onError != null){
       return onError(error);
      }
      return null;
    }
  }
  Future<String> uploadFile(File file) async {
    final repo = getit.get<Repository>();
    return await execute(() async {
      return await repo.uploadFile(file);
    }, label: "uploadFile");
  }
}
