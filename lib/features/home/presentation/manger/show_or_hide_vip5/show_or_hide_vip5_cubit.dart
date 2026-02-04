import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lklk/core/services/api_service.dart';

part 'show_or_hide_vip5_state.dart';

class ShowOrHideVip5Cubit extends Cubit<ShowOrHideVip5State> {
  ShowOrHideVip5Cubit() : super(ShowOrHideVip5Initial());

  Future<void> showOrHideVIP5() async {
    emit(ShowOrHideVip5Loading());
    try {
      // إرسال الطلب باستخدام ApiService بدون queryParameters
      final response = await ApiService().get('/user/display');
      final data = response.data;
      if (data == 'done') {
        emit(ShowOrHideVip5Done()); // عرض VIP5 إذا كانت الاستجابة 'done'
      } else {
        emit(ShowOrHideVip5Error()); // إخفاء VIP5 إذا كانت الاستجابة أي شيء آخر
      }
    } catch (error) {
      emit(ShowOrHideVip5Error()); // في حال حدوث خطأ
    }
  }
}
