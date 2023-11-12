import 'package:get_it/get_it.dart';

import 'drive_repository.dart';
import 'sync_repository.dart';

final sl = GetIt.instance;

void loadLocators() {
  sl.registerLazySingleton<DriveRepository>(
    () => DriveRepository(),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepository(driveRepository: sl()),
  );
}
