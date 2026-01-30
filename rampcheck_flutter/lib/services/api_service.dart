import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job.dart';
import '../models/inspection_item.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api/v1';
  static const String apiKey = 'api_warehouse_student_key_1234567890abcdef';

  Map<String, String> _getHeaders() {
    return {'Content-Type': 'application/json', 'X-API-Key': apiKey};
  }

  Future<List<Job>> fetchJobs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Job.fromMap(json)).toList();
      } else {
        throw Exception('Failed to load jobs: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching jobs: $e');
    }
  }

  Future<Map<String, dynamic>> fetchJobDetails(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/jobs/$jobId'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'job': Job.fromMap(data['job']),
          'inspection_items': (data['inspection_items'] as List)
              .map((json) => InspectionItem.fromMap(json))
              .toList(),
        };
      } else {
        throw Exception('Failed to load job details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job details: $e');
    }
  }

  Future<Job> createJob(Job job) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/jobs'),
        headers: _getHeaders(),
        body: json.encode(job.toMap()),
      );

      if (response.statusCode == 201) {
        return Job.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to create job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating job: $e');
    }
  }

  Future<Job> updateJob(Job job) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/jobs/${job.id}'),
        headers: _getHeaders(),
        body: json.encode(job.toMap()),
      );

      if (response.statusCode == 200) {
        return Job.fromMap(json.decode(response.body));
      } else {
        throw Exception('Failed to update job: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating job: $e');
    }
  }

  Future<InspectionItem> createInspectionItem(InspectionItem item) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inspection_items'),
        headers: _getHeaders(),
        body: json.encode(item.toMap()),
      );

      if (response.statusCode == 201) {
        return InspectionItem.fromMap(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to create inspection item: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error creating inspection item: $e');
    }
  }

  Future<InspectionItem> updateInspectionItem(InspectionItem item) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/inspection_items/${item.id}'),
        headers: _getHeaders(),
        body: json.encode(item.toMap()),
      );

      if (response.statusCode == 200) {
        return InspectionItem.fromMap(json.decode(response.body));
      } else {
        throw Exception(
          'Failed to update inspection item: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error updating inspection item: $e');
    }
  }

  Future<Map<String, dynamic>> syncData({
    required List<Job> jobs,
    required List<InspectionItem> inspectionItems,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sync'),
        headers: _getHeaders(),
        body: json.encode({
          'jobs': jobs.map((j) => j.toMap()).toList(),
          'inspection_items': inspectionItems.map((i) => i.toMap()).toList(),
        }),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to sync data: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error syncing data: $e');
    }
  }
}
