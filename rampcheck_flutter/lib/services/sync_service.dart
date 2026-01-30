import '../models/job.dart';
import '../models/inspection_item.dart';
import 'database_helper.dart';
import 'api_service.dart';

class SyncService {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final ApiService _apiService = ApiService();

  Future<SyncResult> syncAll() async {
    int successCount = 0;
    int failureCount = 0;
    List<String> errors = [];

    try {
      final jobsToSync = await _dbHelper.getJobsNeedingSync();
      final itemsToSync = await _dbHelper.getInspectionItemsNeedingSync();

      if (jobsToSync.isEmpty && itemsToSync.isEmpty) {
        return SyncResult(
          success: true,
          syncedJobs: 0,
          syncedItems: 0,
          message: 'Nothing to sync',
        );
      }

      for (final job in jobsToSync) {
        try {
          if (job.id != null && job.id! > 0) {
            await _apiService.updateJob(job);
          } else {
            final createdJob = await _apiService.createJob(job);
            if (createdJob.id != null) {
              await _dbHelper.updateJob(
                job.copyWith(id: createdJob.id, needsSync: 0),
              );
            }
          }

          final updatedJob = job.copyWith(needsSync: 0);
          await _dbHelper.updateJob(updatedJob);
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Job "${job.title}": $e');
        }
      }

      for (final item in itemsToSync) {
        try {
          if (item.id != null && item.id! > 0) {
            await _apiService.updateInspectionItem(item);
          } else {
            await _apiService.createInspectionItem(item);
          }

          final updatedItem = item.copyWith(needsSync: 0);
          await _dbHelper.updateInspectionItem(updatedItem);
          successCount++;
        } catch (e) {
          failureCount++;
          errors.add('Inspection item "${item.title}": $e');
        }
      }

      return SyncResult(
        success: failureCount == 0,
        syncedJobs: jobsToSync.length,
        syncedItems: itemsToSync.length,
        message: failureCount == 0
            ? 'Successfully synced ${successCount} items'
            : 'Synced ${successCount} items, ${failureCount} failed',
        errors: errors.isEmpty ? null : errors,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        syncedJobs: 0,
        syncedItems: 0,
        message: 'Sync failed: $e',
        errors: [e.toString()],
      );
    }
  }

  Future<bool> checkConnection() async {
    try {
      await _apiService.fetchJobs();
      return true;
    } catch (e) {
      return false;
    }
  }
}

class SyncResult {
  final bool success;
  final int syncedJobs;
  final int syncedItems;
  final String message;
  final List<String>? errors;

  SyncResult({
    required this.success,
    required this.syncedJobs,
    required this.syncedItems,
    required this.message,
    this.errors,
  });
}
