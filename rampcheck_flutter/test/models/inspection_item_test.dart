import 'package:flutter_test/flutter_test.dart';
import 'package:rampcheck_flutter/models/inspection_item.dart';

void main() {
  group('InspectionItem Model Tests', () {
    test('InspectionItem toMap converts correctly', () {
      final item = InspectionItem(
        id: 1,
        jobId: 10,
        title: 'Test Item',
        description: 'Test Description',
        isCompleted: true,
        notes: 'Test Notes',
        completedAt: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        needsSync: 1,
      );

      final map = item.toMap();

      expect(map['id'], 1);
      expect(map['job_id'], 10);
      expect(map['title'], 'Test Item');
      expect(map['description'], 'Test Description');
      expect(map['is_completed'], 1); // Boolean stored as int
      expect(map['notes'], 'Test Notes');
      expect(map['needs_sync'], 1);
    });

    test('InspectionItem fromMap converts correctly', () {
      final map = {
        'id': 1,
        'job_id': 10,
        'title': 'Test Item',
        'description': 'Test Description',
        'is_completed': 1,
        'notes': 'Test Notes',
        'completed_at': '2024-01-01T00:00:00.000',
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-02T00:00:00.000',
        'needs_sync': 1,
      };

      final item = InspectionItem.fromMap(map);

      expect(item.id, 1);
      expect(item.jobId, 10);
      expect(item.title, 'Test Item');
      expect(item.isCompleted, true); // Int converted to boolean
      expect(item.notes, 'Test Notes');
      expect(item.needsSync, 1);
    });

    test('InspectionItem copyWith updates values correctly', () {
      final item = InspectionItem(
        id: 1,
        jobId: 10,
        title: 'Original',
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = item.copyWith(title: 'Updated', isCompleted: true);

      expect(updated.id, 1);
      expect(updated.title, 'Updated');
      expect(updated.isCompleted, true);
      expect(updated.jobId, 10); // Unchanged
    });

    test('InspectionItem boolean conversion (0 = false, 1 = true)', () {
      final mapFalse = {
        'id': 1,
        'job_id': 10,
        'title': 'Test',
        'is_completed': 0,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
        'needs_sync': 0,
      };

      final itemFalse = InspectionItem.fromMap(mapFalse);
      expect(itemFalse.isCompleted, false);

      final mapTrue = {
        'id': 2,
        'job_id': 10,
        'title': 'Test',
        'is_completed': 1,
        'created_at': '2024-01-01T00:00:00.000',
        'updated_at': '2024-01-01T00:00:00.000',
        'needs_sync': 1,
      };

      final itemTrue = InspectionItem.fromMap(mapTrue);
      expect(itemTrue.isCompleted, true);
    });
  });
}
