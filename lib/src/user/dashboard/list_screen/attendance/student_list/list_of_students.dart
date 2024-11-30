import 'dart:developer';
import 'package:app_attend/src/user/api_services/document_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListOfStudents extends StatefulWidget {
  final String subject;
  final String section;
  final String date;

  const ListOfStudents({
    super.key,
    required this.subject,
    required this.section,
    required this.date,
  });

  @override
  State<ListOfStudents> createState() => _ListOfStudentsState();
}

class _ListOfStudentsState extends State<ListOfStudents> {
  // Map to store each student's attendance status
  RxMap<String, bool> attendanceStatus = <String, bool>{}.obs;
  String? attendanceId;
  final _controller = Get.put(ListController());
  final documentService = Get.put(DocumentService());

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

              return DataTable(
                columns: [
                  DataColumn(label: Text('No.')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Action')),
                ],
                rows: studentList.asMap().entries.map((entry) {
                  int index = entry.key + 1;
                  Map<String, dynamic> student = entry.value;
                  return DataRow(cells: [
                    DataCell(Text('$index')),
                    // DataCell(Text(student['idnumber'] ?? '')),
                    DataCell(Text(student['full_name'] ?? 'NAA')),
                    DataCell(Checkbox(
                      value: true,
                      onChanged: (value) {},
                    )),
                  ]);
                }).toList(),
                // rows: [
                //   DataRow(cells: [
                //     DataCell(Text('dasda')),
                //     // DataCell(Text(student['idnumber'] ?? '')),
                //     DataCell(Text('dasdas')),
                //     DataCell(Checkbox(
                //       value: true,
                //       onChanged: (value) {},
                //     )),
                //   ])
                // ],
              );
            }),
          ),
          Spacer(),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              onPressed: () {
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

  void _onReportSelected(String value) async {
    if (value == 'pdf') {
      log('Exporting to PDF...');
      try {
        final response = await documentService.generateDocument();
        if (response.statusCode == 200) {
          // Get the download link from the response data
          final String downloadLink = response.body['data'];
          final Uri url = Uri.parse(downloadLink);
          log('Download your document here: $downloadLink');
          launchUrl(url);
        }
    } else if (value == 'csv') {
      log('Exporting to CSV...');
    }
  }
}
