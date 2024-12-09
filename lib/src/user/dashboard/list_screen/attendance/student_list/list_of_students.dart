import 'dart:developer';
import 'package:app_attend/src/user/api_services/document_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/docx_template.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/profile/profile_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final _profileController = Get.put(ProfileController());
  final documentService = Get.put(DocumentService());

  final RxList<Map<String, dynamic>> studentRecord =
      <Map<String, dynamic>>[].obs;

  final RxList<bool> isPresent = <bool>[].obs;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
          Expanded(
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

              if (printList.containsKey('student_record') &&
                  printList['student_record'] != null) {
                final List<dynamic> rawStudentList =
                    printList['student_record'];
                final List<Map<String, dynamic>> studentPrintList =
                    rawStudentList
                        .map((e) => Map<String, dynamic>.from(e as Map))
                        .toList();

                if (widget.isSubmitted) {
                  return _buildScrollableTable(studentPrintList, size);
                }
              }
              return _buildScrollableTable(studentList, size);
            }),
          ),
          SizedBox(height: 10),
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
                color: blue,
                borderRadius: BorderRadius.circular(5),
              ),
              child: !widget.isSubmitted
                  ? TextButton(
                      onPressed: () async {
                        await _profileController.fetchUserInfo();

                        await _controller.addAttendanceStudentRecord(
                          attendanceId: widget.attendanceId,
                          code: widget.subject.split(' ')[0],
                          datenow: widget.date,
                          room: '',
                          schedule: widget.date,
                          studentRecord: studentRecord,
                          subject: widget.subject,
                          teacher: _profileController.userInfo['fullname'],
                          section: widget.section,
                        );
                        await _controller.isSubmitted(
                            attendanceId: widget.attendanceId);
                        populateWordTemplate();

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
                    ),
            ),
          ),
          SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _buildScrollableTable(List<Map<String, dynamic>> data, Size size) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: size.width,
          height: size.height,
          child: DataTable(
            columns: [
              DataColumn(label: Text('No.')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Absent ?')),
            ],
            rows: data.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> student = entry.value;

              if (studentRecord.length < data.length) {
                studentRecord.add({
                  'name': student['full_name'] ?? student['name'],
                  'present': isPresent[index] == false ? 'X' : '✓',
                });
              }

              return DataRow(cells: [
                DataCell(Text('${index + 1}')),
                DataCell(
                    Text(student['full_name'] ?? student['name'] ?? 'N/A')),
                DataCell(widget.isSubmitted
                    ? Text(
                        student['present'] ?? 'N/A',
                        style: TextStyle(
                            color: student['present'] == '✓'
                                ? Colors.green
                                : Colors.red),
                      )
                    : Checkbox(
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
          ),
        ),
      ),
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
    int index = 1;
    for (var records in record) {
      var data = {
        "index": '${index++}',
        "name": records['name'],
        "section": generate['section'],
        "present": '${records['present']}',
      };
      recorded.add(data);
    }
    log('$recorded');
    log('Exporting to PDF...');

    try {
      await _profileController.fetchUserInfo();
      final response = await documentService.generateDocument(
        record: recorded,
        subject: generate['subject'],
        datenow: generate['datenow'],
        code: widget.subject.split(' ')[0],
        teacher: _profileController.userInfo['fullname'],
      );

      if (response.statusCode == 200) {
        final String downloadLink = response.body['data'];
        await _controller.storedUrl(
          attendanceId: attendanceId,
          subject: generate['subject'],
          section: generate['section'],
          date: generate['datenow'],
          type: 'Docx',
          url: downloadLink,
        );
        Get.back();
        Get.snackbar('Success', 'Report generated successfully!');
      }
    } catch (e) {
      log('Error $e');
    }
  }
}
