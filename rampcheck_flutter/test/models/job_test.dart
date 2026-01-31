import 'package:flutter_test/flutter_test.dart';
import 'package:rampcheck_flutter/models/job.dart';

void main() {
  group('Job Model Tests', () {
    test('Job toMap converts correctly', () {
      final job = Job(
        id: 1,
        title: 'Test Job',
        description: 'Test Description',
        aircraftRegistration: 'G-TEST',
        status: 'open',
        priority: 'high',
        createdBy: 1,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        needsSync: 1,
      );

      final map = job.toMap();

      expect(map['id'], 1);
      expect(map['title'], 'Test Job');
      expect(map['description'], 'Test Description');
      expect(map['aircraft_registration'], 'G-TEST');
      expect(map['status'], 'open');
      expect(map['priority'], 'high');
      expect(map['needs_sync'], 1);
    });

    test('Job fromMap converts correctly', () {
      final map = {
        'id': 1,
        'title': 'Test Job',
        'description': 'Test Description',
        'aircraft_registration': 'G-TEST',
        'status': 'open',
        'priority': 'high',
        'assigned_technician_id': null,
        'created_by': 1,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-02T00:00:00.000',
        'completed_at': null,
        'needs_sync': 1,
      };

      final job = Job.fromMap(map);

      expect(job.id, 1);
      expect(job.title, 'Test Job');
      expect(job.description, 'Test Description');
      expect(job.aircraftRegistration, 'G-TEST');
      expect(job.status, 'open');
      expect(job.priority, 'high');
      expect(job.needsSync, 1);
    });

    test('Job copyWith creates new instance with updated values', () {
      final job = Job(
        id: 1,
        title: 'Original Title',
        status: 'open',
        priority: 'low',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updatedJob = job.copyWith(
        title: 'Updated Title',
        status: 'completed',
      );

      expect(updatedJob.id, 1);
      expect(updatedJob.title, 'Updated Title');
      expect(updatedJob.status, 'completed');
      expect(updatedJob.priority, 'low'); // Unchanged
    });

    test('Job with null optional fields', () {
      final job = Job(
        title: 'Minimal Job',
        status: 'open',
        priority: 'medium',
        createdBy: 1,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(job.id, null);
      expect(job.description, null);
      expect(job.aircraftRegistration, null);
      expect(job.completedAt, null);
    });
  });
}
