import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'internet_state.dart';

class InternetCubit extends Cubit<InternetStates> {
  InternetCubit() : super(InternetInitial());
  static InternetCubit get(context) => BlocProvider.of(context);

  late StreamSubscription internetListnerSubscription;
  bool isOffline = false;

  void checkInternetAvailability() {
    emit(InternetConnectionLoadingState());
    internetListnerSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      if (result == ConnectivityResult.wifi ||
          result == ConnectivityResult.mobile) {
        isOffline = false;

        emit(InternetConnectionAvailableState());
      } else {
        isOffline = true;
        emit(InternetConnectionNoState());
      }

      // Future.delayed(Duration(seconds: 15)).then((value) {
      //   if (result == ConnectivityResult.none) {
      //     emit(InternetConnectionNoState());
      //   }
      // });
    });
  }

  @override
  Future<void> close() {
    internetListnerSubscription.cancel();
    return super.close();
  }
}
