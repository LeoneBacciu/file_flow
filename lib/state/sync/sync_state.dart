part of 'sync_cubit.dart';

abstract class SyncState extends Equatable {
  const SyncState();
}

class SyncInitial extends SyncState {
  @override
  List<Object> get props => [];
}

class SyncLoaded extends SyncState {
  final DocumentList documents;

  const SyncLoaded(this.documents);

  @override
  List<Object?> get props => [documents.length, documents];
}

class SyncLoadedSyncing extends SyncLoaded {
  const SyncLoadedSyncing(super.documents);
}

class SyncLoadedOffline extends SyncLoaded {
  const SyncLoadedOffline(super.documents);
}
