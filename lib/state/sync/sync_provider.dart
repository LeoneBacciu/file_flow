part of 'sync_cubit.dart';

class SyncCubitProvider {
  static List<BlocProvider> getProviders() {
    return [
      BlocProvider<SyncCubit>(
        create: (context) => SyncCubit(),
      ),
    ];
  }
}
