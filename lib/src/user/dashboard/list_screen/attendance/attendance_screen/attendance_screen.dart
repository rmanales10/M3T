import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_screen/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_attendance.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final _controller = Get.put(AttendanceController());

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'List of Attendance',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 160,
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: () => Get.to(() => const CreateAttendance()),
                  icon: const Icon(Icons.add),
                  label: const Text('Create New'),
                ),
              ),
            ),
            lineSpacer(size),
            Expanded(
              child: Obx(() {
                _controller.getAllAttendance();

                if (_controller.allAttendance.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildAttendanceList();
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'No attendance records found.',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildAttendanceList() {
    return ListView.builder(
      itemCount: _controller.allAttendance.length,
      itemBuilder: (context, index) {
        final record = _controller.allAttendance[index];
        final timestamp = record['date'] as Timestamp;
        final dateTime = timestamp.toDate();
        final formattedDate = DateFormat('MMMM d, y').format(dateTime);

        final label =
            'Subject: ${record['subject']}\nSection: ${record['section']}\nDate: $formattedDate';

        return _buildAttendanceCard(
          label: label,
          onTap: () => Get.to(() => ListOfStudents(
                subject: record['subject'],
                section: record['section'],
                date: formattedDate,
                attendanceId: record['id'],
                isSubmitted: record['is_submitted'],
              )),
          onDelete: () => _confirmDelete(record['id'], record['is_submitted']),
          isSubmitted: record['is_submitted'],
        );
      },
    );
  }

  Widget _buildAttendanceCard({
    required String label,
    required VoidCallback onTap,
    required VoidCallback onDelete,
    required bool isSubmitted,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: grey,
        border: Border.all(color: Colors.black, width: 0.8),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                label,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (isSubmitted)
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 24,
            ),
          IconButton(
            tooltip: 'Delete?',
            onPressed: onDelete,
            icon: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String attendanceId, bool isSubmitted) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirmation'),
        content: const Text('Are you sure you want to delete this attendance?'),
        actions: [
          ElevatedButton(
            onPressed: () async {
              await _controller.deleteAttendanceRecord(
                  attendanceId, isSubmitted);
              Get.back();
              Get.snackbar('Success', 'Attendance deleted successfully.');
            },
            child: const Text('Yes'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
        ],
      ),
    );
  }
}
