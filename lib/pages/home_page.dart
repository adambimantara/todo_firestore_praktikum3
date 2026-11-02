import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../services/auth_service.dart';
import '../services/firestore_service.dart';
import '../theme/app_theme.dart';
import '../widgets/empty_state.dart';
import '../widgets/search_field.dart';
import '../widgets/task_card.dart';
import '../widgets/task_summary.dart';
import 'add_task_page.dart';
import 'edit_task_page.dart';
import 'login_page.dart';

enum TaskFilter { all, active, completed }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _searchController = TextEditingController();
  TaskFilter _currentFilter = TaskFilter.all;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.trim().toLowerCase();
    });
  }

  void _onSearchClear() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  Future<void> _confirmDeleteTask(Task task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.dangerBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.delete_forever_rounded, color: AppTheme.dangerRose, size: 22),
            ),
            const SizedBox(width: 12),
            Text(
              'Hapus Tugas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryNavy,
              ),
            ),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${task.title}"? Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textBody, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textBody),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRose,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Hapus',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await FirestoreService().deleteTask(task.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tugas berhasil dihapus.'),
            backgroundColor: AppTheme.primaryNavy,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Konfirmasi Logout',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryNavy,
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari sesi aplikasi To-Do List?',
          style: GoogleFonts.plusJakartaSans(fontSize: 14, color: AppTheme.textBody),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700, color: AppTheme.textBody),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await AuthService().signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final userName = currentUser?.displayName ??
        (currentUser?.email != null && currentUser!.email!.isNotEmpty
            ? currentUser.email!.split('@').first
            : 'Mahasiswa');
    final userInitials = userName.isNotEmpty ? userName[0].toUpperCase() : 'M';
    final todayFormatted = DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFD),
      body: StreamBuilder<List<Task>>(
        stream: FirestoreService().getTasks(),
        builder: (context, snapshot) {
          final allTasks = snapshot.data ?? [];

          final totalCount = allTasks.length;
          final completedCount = allTasks.where((t) => t.isDone).length;
          final activeCount = totalCount - completedCount;

          final filteredTasks = allTasks.where((task) {
            if (_currentFilter == TaskFilter.active && task.isDone) {
              return false;
            }
            if (_currentFilter == TaskFilter.completed && !task.isDone) {
              return false;
            }
            if (_searchQuery.isNotEmpty) {
              final matchTitle = task.title.toLowerCase().contains(_searchQuery);
              final matchDesc = task.description.toLowerCase().contains(_searchQuery);
              final matchCat = task.category.toLowerCase().contains(_searchQuery);
              return matchTitle || matchDesc || matchCat;
            }
            return true;
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Premium Hero Header App Bar
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
                  decoration: const BoxDecoration(
                    gradient: AppTheme.heroGradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(28),
                      bottomRight: Radius.circular(28),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Row: User Avatar, Greeting, Date, and Logout Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              // Avatar circle with online badge
                              Stack(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFF2563EB), Color(0xFF06B6D4)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.electricBlue.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        userInitials,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: AppTheme.successMint,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.primaryDark, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),

                              // Greeting and Date
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Halo, $userName',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Text('👋', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    todayFormatted,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // Logout Button with Frosted Icon
                          InkWell(
                            onTap: _handleLogout,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(9),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.15),
                                ),
                              ),
                              child: const Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFFCA5A5),
                                size: 19,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Task Summary inside Hero
                      TaskSummaryWidget(
                        totalCount: totalCount,
                        completedCount: completedCount,
                        activeCount: activeCount,
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Search & Filter Controls
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search Input
                      SearchFieldWidget(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        onClear: _onSearchClear,
                      ),
                      const SizedBox(height: 16),

                      // Filter Segmented Capsules
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterCapsule(
                              label: 'Semua',
                              filter: TaskFilter.all,
                              count: totalCount,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterCapsule(
                              label: 'Aktif',
                              filter: TaskFilter.active,
                              count: activeCount,
                            ),
                            const SizedBox(width: 8),
                            _buildFilterCapsule(
                              label: 'Selesai',
                              filter: TaskFilter.completed,
                              count: completedCount,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Section Header with Item Count
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getFilterTitle(),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primaryNavy,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${filteredTasks.length} tugas',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textBody,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // 3. Task List, Loading, Error, or Empty State
              if (snapshot.hasError) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: AppTheme.dangerRose),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal Memuat Data Firestore',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 13, color: AppTheme.textBody),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (snapshot.connectionState == ConnectionState.waiting) ...[
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
              ] else if (filteredTasks.isEmpty) ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    title: _searchQuery.isNotEmpty
                        ? 'Tidak Ada Hasil'
                        : (_currentFilter == TaskFilter.completed
                            ? 'Belum Ada Tugas Selesai'
                            : 'Belum Ada Tugas'),
                    subtitle: _searchQuery.isNotEmpty
                        ? 'Tidak ditemukan tugas dengan kata kunci "$_searchQuery".'
                        : 'Belum ada tugas. Yuk, tambahkan tugas pertamamu!',
                    onAction: _searchQuery.isNotEmpty
                        ? null
                        : () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const AddTaskPage()),
                            );
                          },
                    actionLabel: 'Tambah Tugas Baru',
                  ),
                ),
              ] else ...[
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 90),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final task = filteredTasks[index];
                        return TaskCardWidget(
                          task: task,
                          onToggle: (val) {
                            FirestoreService().toggleDone(task.id, task.isDone);
                          },
                          onEdit: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => EditTaskPage(task: task),
                              ),
                            );
                          },
                          onDelete: () {
                            _confirmDeleteTask(task);
                          },
                        );
                      },
                      childCount: filteredTasks.length,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.buttonGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricBlue.withValues(alpha: 0.4),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddTaskPage()),
            );
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          label: Text(
            'Tambah Tugas',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  String _getFilterTitle() {
    switch (_currentFilter) {
      case TaskFilter.active:
        return 'Tugas Aktif';
      case TaskFilter.completed:
        return 'Tugas Selesai';
      case TaskFilter.all:
        return 'Daftar Tugas';
    }
  }

  Widget _buildFilterCapsule({
    required String label,
    required TaskFilter filter,
    required int count,
  }) {
    final isSelected = _currentFilter == filter;

    return InkWell(
      key: Key('filter_${filter.name}'),
      onTap: () {
        setState(() {
          _currentFilter = filter;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryNavy : AppTheme.borderLight,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : AppTheme.textBody,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
