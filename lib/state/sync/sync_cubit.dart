import 'dart:developer' as dev;

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../core/optimistic_call.dart';
import '../../models/document.dart';
import '../../repositories/sync_repository.dart';

part 'sync_provider.dart';
part 'sync_state.dart';

class SyncCubit extends Cubit<SyncState> {
  final SyncRepository syncRepository;
  final DocumentList emptyList = <Document>[].frozen();

  SyncCubit({required this.syncRepository}) : super(SyncUnsynced());

  void load() async {
    final lastState = state;
    emit(SyncLoadedSyncing(
        lastState is SyncLoaded ? lastState.documents : emptyList));

    final offlineDocs = await syncRepository.loadOffline();
    emit(SyncLoadedSyncing(offlineDocs));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoaded(onlineDocs));
    } catch (e, s) {
      dev.log(e.toString());
      dev.log(s.toString());
      emit(SyncLoadedOffline(offlineDocs));
    }
  }

  void addDocument(Document document) async {
    final lastState = state;
    emit(SyncLoadedSyncing(
        lastState is SyncLoaded ? lastState.documents : emptyList));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoadedSyncing(onlineDocs));

      final optimisticCall =
          await syncRepository.addDocument(onlineDocs, document);
      emit(SyncLoadedSyncing(optimisticCall.getValue()));
      final (docs, state) = await optimisticCall.getResult();
      if (state == OptimisticResultState.success) {
        emit(SyncLoaded(docs));
      } else {
        emit(SyncLoadedOffline(docs));
      }
    } catch (e, s) {
      dev.log(e.toString());
      dev.log(s.toString());
      emit(SyncLoadedOffline(
          lastState is SyncLoaded ? lastState.documents : emptyList));
    }
  }

  void editDocument(Document document) async {
    final lastState = state;
    emit(SyncLoadedSyncing(
        lastState is SyncLoaded ? lastState.documents : emptyList));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoadedSyncing(onlineDocs));

      final optimisticCall =
          await syncRepository.editDocument(onlineDocs, document);
      emit(SyncLoadedSyncing(optimisticCall.getValue()));
      final (docs, state) = await optimisticCall.getResult();
      if (state == OptimisticResultState.success) {
        emit(SyncLoaded(docs));
      } else {
        emit(SyncLoadedOffline(docs));
      }
    } catch (e, s) {
      dev.log(e.toString());
      dev.log(s.toString());
      emit(SyncLoadedOffline(
          lastState is SyncLoaded ? lastState.documents : emptyList));
    }
  }

  void deleteDocument(Document document) async {
    final lastState = state;
    emit(SyncLoadedSyncing(
        lastState is SyncLoaded ? lastState.documents : emptyList));

    try {
      final onlineDocs = await syncRepository.loadOnline();
      emit(SyncLoadedSyncing(onlineDocs));

      final optimisticCall = await syncRepository.deleteDocument(
          onlineDocs, onlineDocs.getUuid(document.uuid)!);
      emit(SyncLoadedSyncing(optimisticCall.getValue()));
      final (docs, state) = await optimisticCall.getResult();
      if (state == OptimisticResultState.success) {
        emit(SyncLoaded(docs));
      } else {
        emit(SyncLoadedOffline(docs));
      }
    } catch (e, s) {
      dev.log(e.toString());
      dev.log(s.toString());
      emit(SyncLoadedOffline(
          lastState is SyncLoaded ? lastState.documents : emptyList));
    }
  }

  @override
  void onChange(Change<SyncState> change) {
    super.onChange(change);
    dev.log(change.toString());
  }

  @override
  void onError(Object error, StackTrace stackTrace) {
    super.onError(error, stackTrace);
    dev.log(error.toString());
  }
}
