import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:googleapis/drive/v3.dart' as drive;

import '../../models/document.dart';
import '../../repositories/sync_repository.dart';

part 'sync_state.dart';

part 'sync_provider.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncRepository syncRepository;

  SyncCubit({required this.syncRepository}) : super(SyncInitial());

  void load() async {
    final offlineDocs = await syncRepository.loadOffline();
    emit(SyncLoaded(offlineDocs));
    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoaded(onlineDocs));
    } on drive.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
      rethrow;
    } catch (e, s) {
      print(e);
      print(s);
      emit(SyncLoaded(offlineDocs, offline: true));
    }
  }

  void addDocument(Document document) async {
    final s = state;
    if (s is SyncLoaded) {
      try {
        final docs = await syncRepository.addDocument(s.documents, document);
        emit(SyncLoaded(docs));
      } on drive.DetailedApiRequestError catch (e) {
        print(e.jsonResponse);
      }
    }
  }

  void deleteDocument(Document document) async {
    final s = state;
    if (s is SyncLoaded) {
      try {
        final docs = await syncRepository.deleteDocument(s.documents, document);
        emit(SyncLoaded(docs));
      } on drive.DetailedApiRequestError catch (e) {
        print(e.jsonResponse);
      }
    }
  }

  @override
  void onChange(Change<SyncState> change) {
    super.onChange(change);
    print(change.toString());
    print(change.currentState.toString());
    print(change.nextState.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    print(error.toString());
  }
}
