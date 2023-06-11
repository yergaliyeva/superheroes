// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:rxdart/rxdart.dart';

class MainBloc {
  static const minSymbols = 3;
  final BehaviorSubject<MainPageState> stateSubject =
      BehaviorSubject(); // Controller
  final favoriteSuperheroesSubject =
      BehaviorSubject<List<SuperheroInfo>>.seeded(SuperheroInfo.mocked);
  StreamSubscription<MainPageState>? stateSubscription;
  final searchedSuperheroesSubject = BehaviorSubject<List<SuperheroInfo>>();
  final currentTextSubject = BehaviorSubject<String>.seeded('');

  StreamSubscription? textSubscription;
  StreamSubscription? searchSubscription;

  MainBloc() {
    stateSubject.add(MainPageState.noFavorites);
    textSubscription =
        Rx.combineLatest2<String, List<SuperheroInfo>, MainPageStateInfo>(
                currentTextSubject.distinct().debounceTime(
                      const Duration(milliseconds: 500),
                    ),
                favoriteSuperheroesSubject,
                (searchedText, favorites) =>
                    MainPageStateInfo(searchedText, favorites.isNotEmpty))
            .listen((value) {
      searchSubscription?.cancel();
      if (value.searchText.isEmpty) {
        if (value.haveFavorites) {
          stateSubject.add(MainPageState.favorites);
        } else {
          stateSubject.add(MainPageState.noFavorites);
        }
      } else if (value.searchText.length < minSymbols) {
        stateSubject.add(MainPageState.minSymbols);
      } else {
        searchForSuperheroes(value.searchText);
      }
    });
  }
  void searchForSuperheroes(final String text) {
    stateSubject.add(MainPageState.loading);
    searchSubscription = search(text).asStream().listen((searchResults) {
      if (searchResults.isEmpty) {
        stateSubject.add(MainPageState.nothingFound);
      } else {
        searchedSuperheroesSubject.add(searchResults);
        stateSubject.add(MainPageState.searchResults);
      }
    }, onError: (error, stackTrace) {
      stateSubject.add(MainPageState.loadingError);
    });
  }

  Future<List<SuperheroInfo>> search(final String text) async {
    await Future.delayed(const Duration(seconds: 1));
    return SuperheroInfo.mocked
        .where((superheroInfo) =>
            superheroInfo.name.toLowerCase().contains(text.toLowerCase()))
        .toList();
  }

  void removeFavorite() {
    final List<SuperheroInfo> currentFavorites =
        favoriteSuperheroesSubject.value;
    if (currentFavorites.isEmpty) {
      favoriteSuperheroesSubject.add(SuperheroInfo.mocked);
    } else {
      favoriteSuperheroesSubject
          .add(currentFavorites.sublist(0, currentFavorites.length - 1));
    }
  }

  Stream<List<SuperheroInfo>> observeFavoritesHeroes() =>
      favoriteSuperheroesSubject;
  Stream<List<SuperheroInfo>> observeSearchedHeroes() =>
      searchedSuperheroesSubject;

  Stream<MainPageState> observeMainPageState() => stateSubject;

  void nextState() {
    final currentState = stateSubject.value;
    final nextState = MainPageState.values[
        (MainPageState.values.indexOf(currentState) + 1) %
            MainPageState.values.length];
    stateSubject.sink.add(nextState);
  }

  void updateText(final String? text) {
    currentTextSubject.add(text ?? '');
  }

  void dispose() {
    stateSubject.close();
    stateSubscription?.cancel();
    textSubscription?.cancel();
    currentTextSubject.close();
  }
}

enum MainPageState {
  noFavorites,
  minSymbols,
  loading,
  nothingFound,
  loadingError,
  searchResults,
  favorites
}

class SuperheroInfo {
  final String name;
  final String realName;
  final String imageUrl;

  SuperheroInfo({
    required this.name,
    required this.realName,
    required this.imageUrl,
  });

  @override
  String toString() =>
      'SuperheroInfo(name: $name, realName: $realName, imageUrl: $imageUrl)';

  @override
  bool operator ==(covariant SuperheroInfo other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.realName == realName &&
        other.imageUrl == imageUrl;
  }

  @override
  int get hashCode => name.hashCode ^ realName.hashCode ^ imageUrl.hashCode;

  static final mocked = [
    SuperheroInfo(
      name: 'Batman',
      realName: 'Bruce Wayne',
      imageUrl:
          'https://www.superherodb.com/pictures2/portraits/10/100/639.jpg',
    ),
    SuperheroInfo(
      name: 'Ironman',
      realName: 'Tony Stark',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/85.jpg',
    ),
    SuperheroInfo(
      name: 'Venom',
      realName: 'Eddie Brock',
      imageUrl: 'https://www.superherodb.com/pictures2/portraits/10/100/22.jpg',
    ),
  ];
}

class MainPageStateInfo {
  final String searchText;
  final bool haveFavorites;

  MainPageStateInfo(this.searchText, this.haveFavorites);

  @override
  String toString() =>
      'MainPageStateInfo(searchText: $searchText, haveFavorites: $haveFavorites)';

  @override
  bool operator ==(covariant MainPageStateInfo other) {
    if (identical(this, other)) return true;

    return other.searchText == searchText &&
        other.haveFavorites == haveFavorites;
  }

  @override
  int get hashCode => searchText.hashCode ^ haveFavorites.hashCode;
}
