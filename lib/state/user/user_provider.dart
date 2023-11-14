part of 'user_cubit.dart';

final sl = GetIt.instance;

class UserCubitProvider {
  static List<BlocProvider> getProviders() {
    return [
      BlocProvider<UserCubit>(
        create: (context) => UserCubit(driveRepository: sl()),
      ),
    ];
  }
}
