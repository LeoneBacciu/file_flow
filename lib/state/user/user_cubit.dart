import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:equatable/equatable.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../repositories/drive_repository.dart';

part 'user_state.dart';

part 'user_provider.dart';

class UserCubit extends Cubit<UserState> {
  final DriveRepository driveRepository;

  UserCubit({required this.driveRepository}) : super(UserSignedOut());

  void signIn() async {
    final user = await driveRepository.signIn();
    if (user == null) {
      emit(UserSignInError());
    } else {
      emit(UserSignedIn(user));
    }
  }

  void signOut() async {
    await driveRepository.signOut();
    emit(UserSignedOut());
  }
}
