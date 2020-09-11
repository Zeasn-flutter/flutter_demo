import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

class HomeViewModel extends BaseViewModel {

  String title = "default";

  void initTitle() {
    title = "initTitle";
    notifyListeners();
  }

  int counter = 0;

  void updateTitle() {
    counter++;
    title = "updateTitle" + '$counter';
    notifyListeners();
  }
}