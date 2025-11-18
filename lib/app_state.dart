import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool mph = false;
  final List<HistoryItem> history = [];

  void toggleUnit(bool useMph) {
    mph = useMph;
    notifyListeners();
  }

  void addHistory(HistoryItem h) {
    history.insert(0, h);
    notifyListeners();
  }
}

class HistoryItem {
  final DateTime date;
  final double maxG;
  final double minG;
  final int score;

  HistoryItem(this.date, this.maxG, this.minG, this.score);
}

class AppProvider extends InheritedNotifier<AppState> {
  const AppProvider({
    super.key,
    required AppState notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppProvider>()!.notifier!;
}
