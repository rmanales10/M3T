import 'dart:developer';

import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/api_services/firestore_service.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StudentList extends StatefulWidget {
  final String subject;
  final String section;
  final DateTime dateTime;
  final String time;
  const StudentList({
    super.key,
    required this.subject,
    required this.section,
    required this.dateTime,
    required this.time,
  });

  @override
  State<StudentList> createState() => _StudentListState();
}

class _StudentListState extends State<StudentList> {
  final FirestoreService _firestoreService = Get.put(FirestoreService());
  final AuthService _authService = Get.put(AuthService());

  // Map to store each student's attendance status
  RxMap<String, bool> attendanceStatus = <String, bool>{}.obs;
  String? attendanceId;

  @override
  void initState() {
    super.initState();
    _initializeAttendanceStatus();
  }

  Future<void> _initializeAttendanceStatus() async {
    var user = _authService.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated!',
          snackPosition: SnackPosition.TOP);
      return;
    }

    // Retrieve or create the attendanceId for the specific date, section, and subject
    attendanceId = await _firestoreService.getOrCreateAttendanceId(
      userId: user.uid,
      date: widget.dateTime,
      section: widget.section,
      subject: widget.subject,
      time: widget.time.toString(),
    );

    // Fetch the student attendance status for this attendance record
    await _firestoreService.getStudentAttendanceStatus(
      userId: user.uid,
      attendanceId: attendanceId!,
    );

    // Populate the attendanceStatus map based on the fetched records
    for (var record in _firestoreService.studentAttendanceRecords) {
      attendanceStatus[record['id']] = !(record['isAbsent']
          as bool); // If `isAbsent` is true, checkbox should be false
    }
  }

  @override
  Widget build(BuildContext context) {
    _firestoreService.getAllStudent();

    return Scaffold(
      appBar: AppBar(
        title: Text('List of Students'),
        centerTitle: true,
        elevation: 0.0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 30),
          Row(
            children: [
              _buildInfoContainer('Subject:', widget.subject),
              _buildInfoContainer('Section:', widget.section),
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            child: Obx(() {
              final sortedStudents = _firestoreService.studentData
                  .where((student) => student['section'] == widget.section)
                  .toList()
                ..sort((a, b) =>
                    (a['fullname'] ?? '').compareTo(b['fullname'] ?? ''));

              return DataTable(
                columns: [
                  DataColumn(label: Text('No.')),
                  // DataColumn(label: Text('ID Number')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Action')),
                ],
                rows: sortedStudents.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  Map<String, dynamic> student = entry.value;
                  attendanceStatus[student['id']] ??= false;

                  return DataRow(cells: [
                    DataCell(Text('$index')),
                    // DataCell(Text(student['idnumber'] ?? '')),
                    DataCell(Text(student['fullname'] ?? '')),
                    DataCell(Checkbox(
                      value: attendanceStatus[student['id']],
                      onChanged: (value) {
                        attendanceStatus[student['id']] = value ?? false;
                      },
                    )),
                  ]);
                }).toList(),
              );
            }),
          ),
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
                _saveAttendanceForStudents();
                Get.back();
              },
              child: Text('Save'),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
      floatingActionButton: PopupMenuButton<String>(
        onSelected: _onReportSelected,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: blue,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Report', style: TextStyle(color: Colors.white)),
              SizedBox(width: 15),
              Icon(Icons.arrow_drop_down, color: Colors.white),
            ],
          ),
        ),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          PopupMenuItem<String>(value: 'pdf', child: Text('Export PDF')),
          PopupMenuItem<String>(value: 'csv', child: Text('Export CSV')),
        ],
      ),
    );
  }

  Widget _buildInfoContainer(String label, String value) {
    return Container(
      padding: EdgeInsets.only(left: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          SizedBox(height: 4),
          Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
                color: blue, borderRadius: BorderRadius.circular(5)),
            child: Text(value,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAttendanceForStudents() async {
    var user = _authService.currentUser;
    if (user == null) {
      Get.snackbar('Error', 'User not authenticated!',
          snackPosition: SnackPosition.TOP);
      return;
    }

    final studentsInSection = _firestoreService.studentData
        .where((student) => student['section'] == widget.section)
        .toList();

    for (var student in studentsInSection) {
      await _firestoreService.storeAttendanceRecord(
        userId: user.uid,
        attendanceId: attendanceId!,
        recordId: student['id'],
        fullname: student['fullname'],
        idnumber: student['idnumber'],
        section: widget.section,
        subject: widget.subject,
        date: widget.dateTime,
        isAbsent:
            !(attendanceStatus[student['id']] ?? false), // True if not checked
      );
    }
  }

  void _onReportSelected(String value) {
    if (value == 'pdf') {
      log('Exporting to PDF...');
    } else if (value == 'csv') {
      log('Exporting to CSV...');
    }
  }
}
