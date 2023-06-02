import 'dart:async';
import 'package:rxdart/rxdart.dart';

class MainBloc {
  final BehaviorSubject<MainPageState> stateSubject = BehaviorSubject();
  StreamSubscription<MainPageState>? stateSubscription;

  MainBloc() {
    stateSubject.add(MainPageState.notFavorites);
  }

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        MainPageState.values.indexOf(currentState) +
            1 % MainPageState.values.length];
    stateSubject.sink.add(nextState);
  }

  void dispose() {
    stateSubject.close();
    stateSubscription?.cancel();
  }
}

enum MainPageState {
  notFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites
}
