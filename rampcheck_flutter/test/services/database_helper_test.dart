import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:rampcheck_flutter/services/database_helper.dart';
import 'package:rampcheck_flutter/models/job.dart';
import 'package:rampcheck_flutter/models/inspection_item.dart';

void main() {
  // Initialize FFI for testing
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('DatabaseHelper Tests', () {
    late DatabaseHelper dbHelper;

    setUp(() async {
      dbHelper = DatabaseHelper.instance;
      // Clear any existing data
      final jobs = await dbHelper.getAllJobs();
      for (var job in jobs) {
        if (job.id != null) {
          await dbHelper.deleteJob(job.id!);
        }
      }
    });

    test('Create and retrieve job', () async {
      final job = Job(
        title: 'Test Job',
        description: 'Test Description',
        status: 'open',
        priority: 'high',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jobId = await dbHelper.createJob(job);
      expect(jobId, greaterThan(0));

      final retrievedJob = await dbHelper.getJob(jobId);
      expect(retrievedJob, isNotNull);
      expect(retrievedJob!.title, 'Test Job');
      expect(retrievedJob.status, 'open');
    });

    test('Update job', () async {
      final job = Job(
        title: 'Original Title',
        status: 'open',
        priority: 'medium',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jobId = await dbHelper.createJob(job);
      final createdJob = await dbHelper.getJob(jobId);

      final updatedJob = createdJob!.copyWith(
        title: 'Updated Title',
        status: 'completed',
      );

      await dbHelper.updateJob(updatedJob);
      final retrieved = await dbHelper.getJob(jobId);

      expect(retrieved!.title, 'Updated Title');
      expect(retrieved.status, 'completed');
    });

    test('Delete job', () async {
      final job = Job(
        title: 'Job to Delete',
        status: 'open',
        priority: 'low',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jobId = await dbHelper.createJob(job);
      await dbHelper.deleteJob(jobId);

      final retrieved = await dbHelper.getJob(jobId);
      expect(retrieved, isNull);
    });

    test('Get all jobs returns list', () async {
      final job1 = Job(
        title: 'Job 1',
        status: 'open',
        priority: 'high',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final job2 = Job(
        title: 'Job 2',
        status: 'completed',
        priority: 'low',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await dbHelper.createJob(job1);
      await dbHelper.createJob(job2);

      final allJobs = await dbHelper.getAllJobs();
      expect(allJobs.length, greaterThanOrEqualTo(2));
    });

    test('Create and retrieve inspection item', () async {
      final job = Job(
        title: 'Test Job',
        status: 'open',
        priority: 'medium',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final jobId = await dbHelper.createJob(job);

      final item = InspectionItem(
        jobId: jobId,
        title: 'Test Item',
        description: 'Test Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final itemId = await dbHelper.createInspectionItem(item);
      expect(itemId, greaterThan(0));

      final items = await dbHelper.getInspectionItemsForJob(jobId);
      expect(items.length, 1);
      expect(items.first.title, 'Test Item');
    });

    test('Jobs needing sync are tracked', () async {
      final job = Job(
        title: 'Unsynced Job',
        status: 'open',
        priority: 'high',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        needsSync: 1,
      );

      await dbHelper.createJob(job);

      final unsyncedJobs = await dbHelper.getJobsNeedingSync();
      expect(unsyncedJobs.length, greaterThan(0));
      expect(unsyncedJobs.any((j) => j.title == 'Unsynced Job'), true);
    });
  });
}
