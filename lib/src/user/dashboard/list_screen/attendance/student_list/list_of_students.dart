import 'dart:developer';
import 'package:app_attend/src/user/api_services/document_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ListOfStudents extends StatefulWidget {
  final String subject;
  final String section;
  final String date;
  final String attendanceId;
  final bool isSubmitted;

  const ListOfStudents({
    super.key,
    required this.subject,
    required this.section,
    required this.date,
    required this.attendanceId,
    required this.isSubmitted,
  });

  @override
  State<ListOfStudents> createState() => _ListOfStudentsState();
}

class _ListOfStudentsState extends State<ListOfStudents> {
  final _controller = Get.put(ListController());
  final documentService = Get.put(DocumentService());

  // Initialize studentRecord list to track attendance
  final RxList<Map<String, dynamic>> studentRecord =
      <Map<String, dynamic>>[].obs;

  // This will track the attendance for each student
  final RxList<bool> isPresent = <bool>[].obs;

  @override
  Widget build(BuildContext context) {
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
              _buildInfoContainer('Date:', widget.date),
            ],
          ),
          SizedBox(height: 16),
          SingleChildScrollView(
            child: Obx(() {
              _controller.getStudentsList(
                  section: widget.section, subject: widget.subject);
              final studentList = _controller.studentList;

              if (isPresent.isEmpty) {
                isPresent
                    .addAll(List.generate(studentList.length, (_) => false));
              }

              _controller.printAttendanceStudentRecord(
                  attendanceId: widget.attendanceId);
              final Map<String, dynamic> printList =
                  _controller.attendaceStudentRecord;

              // Null-check for student_record
              if (printList.containsKey('student_record') &&
                  printList['student_record'] != null) {
                final List<dynamic> rawStudentList =
                    printList['student_record'];
                final List<Map<String, dynamic>> studentPrintList =
                    rawStudentList
                        .map((e) => Map<String, dynamic>.from(e as Map))
                        .toList();

                if (widget.isSubmitted) {
                  return DataTable(
                    columns: [
                      DataColumn(label: Text('No.')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Absent ?')),
                    ],
                    rows: studentPrintList.asMap().entries.map((entry) {
                      int index = entry.key;
                      Map<String, dynamic> student = entry.value;

                      return DataRow(cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(student['name'] ?? 'N/A')),
                        DataCell(Text(student['present'] ?? 'N/A')),
                      ]);
                    }).toList(),
                  );
                }
              }
              return DataTable(
                columns: [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Absent ?')),
                ],
                rows: studentList.asMap().entries.map((entry) {
                  int index = entry.key;
                  Map<String, dynamic> student = entry.value;

                  if (studentRecord.length < studentList.length) {
                    studentRecord.add({
                      'name': student['full_name'],
                      'present': isPresent[index] == false ? 'X' : '✓',
                    });
                  }

                  return DataRow(cells: [
                    DataCell(Text('${index + 1}')),
                    DataCell(Text(student['full_name'] ?? 'N/A')),
                    DataCell(Checkbox(
                      value: isPresent[index],
                      onChanged: (value) {
                        setState(() {
                          isPresent[index] = value ?? false;
                        });

                        studentRecord[index]['present'] =
                            isPresent[index] == false ? 'X' : '✓';
                      },
                    )),
                  ]);
                }).toList(),
              );
            }),
          ),
          Spacer(),
          Text(
            !widget.isSubmitted
                ? 'Note! You can only submit once'
                : 'Note! Generate to Word only',
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.red),
          ),
          SizedBox(height: 5),
          Align(
            alignment: Alignment.center,
            child: Container(
                width: 150,
                height: 40,
                decoration: BoxDecoration(
                    color: blue, borderRadius: BorderRadius.circular(5)),
                child: !widget.isSubmitted
                    ? TextButton(
                        onPressed: () async {
                          await _controller.addAttendanceStudentRecord(
                            attendanceId: widget.attendanceId,
                            code: "Wala pa",
                            datenow: widget.date,
                            room: "Wala pa",
                            schedule: "Wala pa",
                            studentRecord: studentRecord,
                            subject: widget.subject,
                            teacher: "rolan wala pana",
                            section: widget.section,
                          );
                          await _controller.isSubmitted(
                              attendanceId: widget.attendanceId);

                          Get.back();
                        },
                        child: Text(
                          'Submit',
                          style: TextStyle(color: Colors.white),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          _onReportSelected(attendanceId: widget.attendanceId);
                        },
                        child: Text(
                          'Generate Report...',
                          style: TextStyle(color: Colors.white),
                        ),
                      )),
          ),
          SizedBox(height: 50),
        ],
      ),
      // floatingActionButton: PopupMenuButton<String>(
      //   onSelected: _onReportSelected,
      //   child: Container(
      //     padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      //     decoration: BoxDecoration(
      //       color: blue,
      //       borderRadius: BorderRadius.circular(8),
      //     ),
      //     child: Row(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text('Report', style: TextStyle(color: Colors.white)),
      //         SizedBox(width: 15),
      //         Icon(Icons.arrow_drop_down, color: Colors.white),
      //       ],
      //     ),
      //   ),
      //   itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
      //     PopupMenuItem<String>(value: 'pdf', child: Text('Export PDF')),
      //     PopupMenuItem<String>(value: 'csv', child: Text('Export CSV')),
      //   ],
      // ),
    );
  }

  Widget _buildInfoContainer(String label, String value) {
    return Container(
      padding: EdgeInsets.only(left: 20),
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11)),
          ),
        ],
      ),
    );
  }

  void _onReportSelected({required attendanceId}) async {
    _controller.printAttendanceStudentRecord(attendanceId: attendanceId);
    final generate = _controller.attendaceStudentRecord;
    final record = _controller.studentPrintList;
    final List recorded = [];
    int i = 1;
    for (var records in record) {
      var data = {
        "index": i++,
        "name": records['name'],
        "section": generate['section'],
        "present": '${records['present']}',
      };
      recorded.add(data);
    }
    log('$recorded');
    log('Exporting to PDF...');

    try {
      final response = await documentService.generateDocument(record: recorded);
      if (response.statusCode == 200) {
        // Get the download link from the response data
        final String downloadLink = response.body['data'];
        final Uri url = Uri.parse(downloadLink);
        log('Download your document here: $downloadLink');
        launchUrl(url);
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
