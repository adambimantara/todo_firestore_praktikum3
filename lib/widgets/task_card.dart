import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../theme/app_theme.dart';

class TaskCardWidget extends StatelessWidget {
  final Task task;
  final ValueChanged<bool?> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TaskCardWidget({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM • HH:mm');
    final formattedDate = dateFormat.format(task.timestamp);

    // Dynamic Category Colors
    Color categoryBg;
    Color categoryText;
    switch (task.category.toLowerCase()) {
      case 'kuliah':
        categoryBg = const Color(0xFFEFF6FF);
        categoryText = const Color(0xFF1D4ED8);
        break;
      case 'desain':
        categoryBg = const Color(0xFFF3E8FF);
        categoryText = const Color(0xFF7E22CE);
        break;
      case 'keamanan':
        categoryBg = const Color(0xFFFEF2F2);
        categoryText = const Color(0xFFB91C1C);
        break;
      case 'praktikum':
      default:
        categoryBg = const Color(0xFFE0F2FE);
        categoryText = const Color(0xFF0369A1);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: task.isDone ? const Color(0xFFFBFCFE) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: task.isDone
              ? const Color(0xFFE2E8F0)
              : const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: task.isDone
                ? Colors.transparent
                : const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Category Tag, Priority, and Quick Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: categoryBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.category,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: categoryText,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Priority Dot
                      if (task.priority.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.priority == 'Tinggi'
                                    ? AppTheme.dangerRose
                                    : (task.priority == 'Sedang'
                                        ? AppTheme.warningAmber
                                        : AppTheme.successMint),
                              ),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              task.priority,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),

                  // Actions (Edit & Delete)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: onEdit,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      InkWell(
                        onTap: onDelete,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            size: 16,
                            color: AppTheme.dangerRose,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Main Row: Checkbox, Title, and Description
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Animated Circular Checkbox
                  GestureDetector(
                    onTap: () => onToggle(!task.isDone),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(top: 2, right: 12),
                      decoration: BoxDecoration(
                        gradient: task.isDone ? AppTheme.successGradient : null,
                        color: task.isDone ? null : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.isDone
                              ? Colors.transparent
                              : const Color(0xFFCBD5E1),
                          width: 2,
                        ),
                        boxShadow: task.isDone
                            ? [
                                BoxShadow(
                                  color: AppTheme.successMint.withValues(alpha: 0.35),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: task.isDone
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),

                  // Text Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: task.isDone
                                ? AppTheme.textMuted
                                : AppTheme.textMain,
                            decoration: task.isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            decorationColor: AppTheme.textMuted,
                            height: 1.3,
                          ),
                        ),
                        if (task.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            task.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              color: task.isDone
                                  ? AppTheme.textMuted.withValues(alpha: 0.7)
                                  : AppTheme.textBody,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Bottom Info: Timestamp & Status Pill
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.schedule_rounded,
                        size: 13,
                        color: AppTheme.textMuted,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formattedDate,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: task.isDone
                          ? AppTheme.successBg
                          : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      task.isDone ? 'Selesai' : 'Aktif',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: task.isDone
                            ? AppTheme.successMint
                            : AppTheme.electricBlue,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
