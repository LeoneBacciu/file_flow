part of 'sync_cubit.dart';

final sl = GetIt.instance;

class SyncCubitProvider {
  static List<BlocProvider> getProviders() {
    return [
      BlocProvider<SyncCubit>(
        create: (context) => SyncCubit(syncRepository: sl()),
      ),
    ];
  }
}
