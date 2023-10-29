part of 'sync_cubit.dart';

abstract class SyncState extends Equatable {
  const SyncState();
}

class SyncInitial extends SyncState {
  @override
  List<Object> get props => [];
}

class SyncLoaded extends SyncState {
  final List<Document> documents;

  const SyncLoaded(this.documents);

  @override
  List<Object?> get props => [documents];
}