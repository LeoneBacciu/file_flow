import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:file_flow/repositories/drive_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/document.dart';

part 'sync_state.dart';

part 'sync_provider.dart';

class SyncCubit extends Cubit<SyncState> {
  SyncCubit() : super(SyncInitial());

  void load() async {
    final docs = await DriveRepository.loadSpec();
    emit(SyncLoaded(docs));
  }
}
