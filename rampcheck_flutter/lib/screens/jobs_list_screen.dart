import 'package:flutter/material.dart';
import '../models/job.dart';
import '../services/database_helper.dart';
import 'job_detail_screen.dart';
import 'add_job_screen.dart';
import '../services/sync_service.dart';

class JobsListScreen extends StatefulWidget {
  const JobsListScreen({super.key});

  @override
  State<JobsListScreen> createState() => _JobsListScreenState();
}

class _JobsListScreenState extends State<JobsListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  List<Job> _jobs = [];
  bool _isLoading = true;
  bool _isSyncing = false;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await _dbHelper.getAllJobs();
      setState(() {
        _jobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading jobs: $e')));
    }
  }

  Future<void> _syncData() async {
    setState(() => _isSyncing = true);

    final syncService = SyncService();

    final hasConnection = await syncService.checkConnection();
    if (!hasConnection) {
      setState(() => _isSyncing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No connection to server. Check your network.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final result = await syncService.syncAll();

      setState(() => _isSyncing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: result.success ? Colors.green : Colors.orange,
          ),
        );

        if (result.success) {
          _loadJobs();
        }
      }
    } catch (e) {
      setState(() => _isSyncing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildStatCard(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  List<Job> get _filteredJobs {
    switch (_selectedFilter) {
      case 'open':
        return _jobs.where((j) => j.status == 'open').toList();
      case 'in_progress':
        return _jobs.where((j) => j.status == 'in_progress').toList();
      case 'completed':
        return _jobs.where((j) => j.status == 'completed').toList();
      default:
        return _jobs;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/images/rampcheck_logo.png', height: 40),
            const SizedBox(width: 12),
            const Text('RampCheck - Maintenance Jobs'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.account_circle),
            onSelected: (value) async {
              if (value == 'logout') {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Logout'),
                    content: const Text(
                      'Are you sure you want to logout? Unsynced data will remain on device.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Logged out successfully')),
                  );
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
          IconButton(
            icon: _isSyncing
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.sync),
            onPressed: _isSyncing ? null : _syncData,
            tooltip: 'Sync with server',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Stats Dashboard
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[100],
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Total Jobs',
                          _jobs.length.toString(),
                          Colors.blue,
                          Icons.work,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Open',
                          _jobs
                              .where((j) => j.status == 'open')
                              .length
                              .toString(),
                          Colors.blue[700]!,
                          Icons.circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'In Progress',
                          _jobs
                              .where((j) => j.status == 'in_progress')
                              .length
                              .toString(),
                          Colors.orange,
                          Icons.engineering,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          'Completed',
                          _jobs
                              .where((j) => j.status == 'completed')
                              .length
                              .toString(),
                          Colors.green,
                          Icons.check_circle,
                        ),
                      ),
                    ],
                  ),
                ),
                // Filter Dropdown
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      const Text(
                        'Filter: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<String>(
                          value: _selectedFilter,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'all',
                              child: Text('All Jobs'),
                            ),
                            DropdownMenuItem(
                              value: 'open',
                              child: Text('Open Only'),
                            ),
                            DropdownMenuItem(
                              value: 'in_progress',
                              child: Text('In Progress Only'),
                            ),
                            DropdownMenuItem(
                              value: 'completed',
                              child: Text('Completed Only'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedFilter = value!);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Jobs List
                Expanded(
                  child: _filteredJobs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/images/rampcheck_logo.png',
                                width: 120,
                                height: 120,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No maintenance jobs yet',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to create your first job',
                                style: TextStyle(color: Colors.grey[500]),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadJobs,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredJobs.length,
                            itemBuilder: (context, index) {
                              final job = _jobs[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: _getPriorityColor(
                                      job.priority,
                                    ),
                                    child: Text(
                                      job.priority[0].toUpperCase(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  title: Text(job.title),
                                  subtitle: job.aircraftRegistration != null
                                      ? Text(
                                          'Aircraft: ${job.aircraftRegistration}',
                                        )
                                      : null,
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(job.status),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          job.status.toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (job.needsSync == 1)
                                        const Icon(
                                          Icons.sync,
                                          color: Colors.orange,
                                          size: 20,
                                        ),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  ),
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            JobDetailScreen(jobId: job.id!),
                                      ),
                                    );
                                    _loadJobs();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddJobScreen()),
          );
          _loadJobs();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
