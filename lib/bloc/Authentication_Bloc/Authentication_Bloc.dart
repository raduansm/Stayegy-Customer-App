import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stayegy/bloc/Authentication_Bloc/Authentication_Events.dart';
import 'package:stayegy/bloc/Authentication_Bloc/Authentication_States.dart';
import 'package:stayegy/constants/ConstantLists.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;

import '../Repository/User/UserRepository.dart';
import '../Repository/User/User_Details.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  final UserRepository _userRepository;

  AuthenticationBloc({UserRepository userRepository, UserDetails userDetails})
      : _userRepository = userRepository,
        super(InitialAuthenticationState());

  @override
  Stream<AuthenticationState> mapEventToState(AuthenticationEvent event) async* {
    if (event is AppStarted) {
      yield Uninitialized();
      auth.User user = await _userRepository.getUser();
      // final bool hasToken = await _userRepository.getUser() != null;
      final bool hasToken = user != null;
      if (hasToken) {
        userDetailsGlobal = await _userRepository.loadUserDetails(user.uid);
        homePageHotels = [];
        homePageHotels = await _userRepository.getHomePageHotels();
        homePageHotels.shuffle();
        yield Authenticated();
      } else {
        yield Unauthenticated();
      }
    }
    if (event is LoggedIn) {
      yield Loading();
      homePageHotels = [];
      homePageHotels = await _userRepository.getHomePageHotels();
      homePageHotels.shuffle();
      yield Authenticated();
    }
    if (event is LoggedOut) {
      yield Loading();
      _userRepository.logOut();
      yield Unauthenticated();
    }
  }

  @override
  void onEvent(AuthenticationEvent event) {
    super.onEvent(event);
    print(event);
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    print(stackTrace);
  }

  @override
  Future<void> close() {
    print('Bloc Closed');
    return super.close();
  }
}
