import 'package:connectivity_plus/connectivity_plus.dart';

import '../repositories/app_repository.dart';

enum SyncStatus { offline, syncing, synced }

/// Offline-first sync. Hive is the source of truth. Writes also land in a
/// Firestore-shaped mirror box (`users/{id}/…`). When a network path exists
/// the pending flag is cleared — swap `_pushRemote` for `cloud_firestore`
/// once a Firebase project is linked. Collection paths stay the same.
class SyncService {
  SyncService(this.repo);

  final AppRepository repo;
  SyncStatus status = SyncStatus.synced;

  Future<bool> get isOnline async {
    final result = await Connectivity().checkConnectivity();
    return result.any((r) => r != ConnectivityResult.none);
  }

  Future<SyncStatus> syncNow() async {
    status = SyncStatus.syncing;
    final online = await isOnline;
    if (!online) {
      status = SyncStatus.offline;
      return status;
    }
    await repo.flushPending();
    status = repo.pendingCount() == 0 ? SyncStatus.synced : SyncStatus.offline;
    return status;
  }
}
