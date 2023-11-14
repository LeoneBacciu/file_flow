part of 'user_cubit.dart';

abstract class UserState extends Equatable {
  const UserState();
}

class UserSignedOut extends UserState {
  @override
  List<Object> get props => [];
}

class UserSignedIn extends UserState {
  final GoogleSignInAccount account;

  const UserSignedIn(this.account);

  @override
  List<Object> get props => [];
}

class UserSignInError extends UserState {
  @override
  List<Object> get props => [];
}
