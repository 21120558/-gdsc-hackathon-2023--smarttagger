import 'dart:async';
import 'package:bloc/bloc.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial());

  // @override
  // Stream<SearchState> mapEventToState(SearchEvent event) async* {
  //   if (event is SearchTextChanged) {
  //     yield* _mapSearchTextChangedToState(event);
  //   }
  // }

  // Stream<SearchState> _mapSearchTextChangedToState(SearchTextChanged event) async* {
  //   if (event.searchText.isEmpty) {
  //     yield SearchInitial();
  //   } else {
  //     yield SearchLoading();

  //     try {
  //       // Thực hiện tìm kiếm
  //       final List<String> results = await searchItems(event.searchText);

  //       // Trả về kết quả tìm kiếm
  //       yield SearchSuccess(results: results);
  //     } catch (error) {
  //       // Trả về lỗi
  //       yield SearchFailure(error: error.toString());
  //     }
  //   }
  // }

  // Future<List<String>> searchItems(String searchText) async {

  // }
}