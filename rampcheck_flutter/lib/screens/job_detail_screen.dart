import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/inspection_item.dart';
import '../services/database_helper.dart';

class JobDetailScreen extends StatefulWidget {
  final int jobId;

  const JobDetailScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Job? _job;
  List<InspectionItem> _inspectionItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobDetails();
  }

  Future<void> _loadJobDetails() async {
    setState(() => _isLoading = true);
    try {
      final job = await _dbHelper.getJob(widget.jobId);
      final items = await _dbHelper.getInspectionItemsForJob(widget.jobId);
      setState(() {
        _job = job;
        _inspectionItems = items;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading job details: $e')));
    }
  }

  Future<void> _toggleInspectionItem(InspectionItem item) async {
    try {
      final updatedItem = item.copyWith(
        isCompleted: !item.isCompleted,
        completedAt: !item.isCompleted ? DateTime.now() : null,
        updatedAt: DateTime.now(),
        needsSync: 1,
      );
      await _dbHelper.updateInspectionItem(updatedItem);
      _loadJobDetails();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating item: $e')));
    }
  }

  Future<void> _updateJobStatus(String newStatus) async {
    if (_job == null) return;
    try {
      final updatedJob = _job!.copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
        completedAt: newStatus == 'completed' ? DateTime.now() : null,
        needsSync: 1,
      );
      await _dbHelper.updateJob(updatedJob);
      _loadJobDetails();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Job status updated to $newStatus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Job Details')),
        body: const Center(child: Text('Job not found')),
      );
    }

    final completedItems = _inspectionItems.where((i) => i.isCompleted).length;
    final totalItems = _inspectionItems.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
        actions: [
          PopupMenuButton<String>(
            onSelected: _updateJobStatus,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'open', child: Text('Mark as Open')),
              const PopupMenuItem(
                value: 'in_progress',
                child: Text('Mark as In Progress'),
              ),
              const PopupMenuItem(
                value: 'completed',
                child: Text('Mark as Completed'),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: _getStatusColor(_job!.status).withOpacity(0.1),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _job!.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_job!.aircraftRegistration != null)
                    Text(
                      'Aircraft: ${_job!.aircraftRegistration}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_job!.status),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _job!.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_job!.description != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(_job!.description!),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Inspection Checklist',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '$completedItems / $totalItems',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0 ? Colors.green : Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_inspectionItems.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('No inspection items yet'),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _inspectionItems.length,
                      itemBuilder: (context, index) {
                        final item = _inspectionItems[index];
                        return Card(
                          child: CheckboxListTile(
                            title: Text(item.title),
                            subtitle: item.description != null
                                ? Text(item.description!)
                                : null,
                            value: item.isCompleted,
                            onChanged: (value) => _toggleInspectionItem(item),
                            secondary: item.isCompleted
                                ? const Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                  )
                                : const Icon(Icons.radio_button_unchecked),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
