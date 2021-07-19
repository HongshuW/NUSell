import 'package:flutter/cupertino.dart';

class imageDeletionProvider with ChangeNotifier {
  List<String> _deleted = [];

  List<String> get deleted => _deleted;

  set deleted(List<String> removed) {
    _deleted = removed;
    notifyListeners();
  }

  delete(String img) {
    _deleted.add(img);
    notifyListeners();
  }

  resume(String img) {
    _deleted.remove(img);
    notifyListeners();
  }
}