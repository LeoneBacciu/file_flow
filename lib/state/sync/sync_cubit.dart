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
    final lastState = state;
    emit(SyncLoadedSyncing(lastState is SyncLoaded ? lastState.documents : []));

    final offlineDocs = await syncRepository.loadOffline();
    emit(SyncLoadedSyncing(offlineDocs));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoaded(onlineDocs));
    } on drive.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
      rethrow;
    } catch (e, s) {
      print(e);
      print(s);
      emit(SyncLoadedOffline(offlineDocs));
    }
  }

  void addDocument(Document document) async {
    final lastState = state;
    emit(SyncLoadedSyncing(lastState is SyncLoaded ? lastState.documents : []));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoadedSyncing(onlineDocs));

      final (newDocs, uploadedDocs) =
          await syncRepository.addDocument(onlineDocs, document);
      emit(SyncLoadedSyncing(newDocs));
      emit(SyncLoaded(await uploadedDocs));
    } on drive.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
      rethrow;
    } catch (e, s) {
      print(e);
      print(s);
      emit(SyncLoadedOffline(lastState is SyncLoaded ? lastState.documents : []));
    }
  }

  void deleteDocument(Document document) async {
    final lastState = state;
    emit(SyncLoadedSyncing(lastState is SyncLoaded ? lastState.documents : []));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoadedSyncing(onlineDocs));

      final (newDocs, uploadedDocs) = await syncRepository.deleteDocument(
          onlineDocs, onlineDocs.firstWhere((d) => d.uuid == document.uuid));
      emit(SyncLoadedSyncing(newDocs));
      emit(SyncLoaded(await uploadedDocs));
    } on drive.DetailedApiRequestError catch (e) {
      print(e.jsonResponse);
      rethrow;
    } catch (e, s) {
      print(e);
      print(s);
      emit(SyncLoadedOffline(lastState is SyncLoaded ? lastState.documents : []));
    }
  }

  @override
  void onChange(Change<SyncState> change) {
    super.onChange(change);
    print(change.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    print(error.toString());
  }
}
