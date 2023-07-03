import 'package:flutter/foundation.dart';

class BaseProvider with ChangeNotifier {
  bool isLoading = false;
  setLoadingState(bool val) {
    isLoading = val;
    notifyListeners();
  }
}
