import 'package:flutter_bloc/flutter_bloc.dart';

enum WeeklyTab { thisWeek, bouns }

class WeeklyTabCubit extends Cubit<WeeklyTab> {
  WeeklyTabCubit() : super(WeeklyTab.thisWeek);

  void select(WeeklyTab tab) {
    if (state != tab) emit(tab);
  }
}
