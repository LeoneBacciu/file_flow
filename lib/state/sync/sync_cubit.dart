import 'package:equatable/equatable.dart';
import 'package:file_flow/repositories/drive_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../models/document.dart';

part 'sync_state.dart';

part 'sync_provider.dart';

class SyncCubit extends Cubit<SyncState> {
  SyncCubit() : super(SyncInitial());

  void load() async {
    final docs = await DriveRepository().loadDocuments();
    emit(SyncLoaded(docs));
  }

  void addFile(Document document) async {
    final s = state;
    if (s is SyncLoaded) {
      final docs =
          await DriveRepository().updateDocuments(s.documents, document);
      emit(SyncLoaded(docs));
    }
  }
}
