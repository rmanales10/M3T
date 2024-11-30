import 'package:app_attend/src/user/dashboard/list_screen/attendance/attendance_controller.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_attendance1.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/list_of_students.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/student_list.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AttendanceScreen1 extends StatefulWidget {
  const AttendanceScreen1({super.key});

  @override
  State<AttendanceScreen1> createState() => _AttendanceScreen1State();
}

class _AttendanceScreen1State extends State<AttendanceScreen1> {
  final _controller = Get.put(AttendanceController());

  @override
  void initState() {
    super.initState();
    initAttendance();
  }

  @override
  Widget build(BuildContext context) {
    _controller.getAllAttendance();
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Attendance'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'List of Attendance',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 150,
                child: ElevatedButton(
                  onPressed: () => Get.to(() => CreateAttendance1()),
                  child: Row(
                    children: [
                      Icon(Icons.add),
                      Text('Create New'),
                    ],
                  ),
                ),
              ),
            ),
            lineSpacer(size),
            Expanded(
              child: Obx(() {
                if (_controller.allAttendance.isEmpty) {
                  return Center(child: Text('No attendance records found'));
                }

                return ListView.builder(
                  itemCount: _controller.allAttendance.length,
                  itemBuilder: (context, index) {
                    final record = _controller.allAttendance[index];
                    Timestamp timestamp = record['date'] as Timestamp;
                    DateTime dateTime = timestamp.toDate();
                    String formattedDate =
                        DateFormat('MMMM d, y').format(dateTime);
                    String label =
                        'Subject: ${record['subject']}\nSection: ${record['section']}\nDate: $formattedDate';

                    return createCard(
                      label,
                      () => Get.to(() => ListOfStudents(
                            subject: record['subject'],
                            section: record['section'],
                            date: formattedDate,
                            attendanceId: record['id'],
                          )),
                      () => Get.dialog(AlertDialog(
                        title: Text('Confirmation'),
                        content: Text(
                            'Are you sure you want to delete this attendance?'),
                        actions: [
                          ElevatedButton(onPressed: () {}, child: Text('Yes')),
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () => Get.back(),
                              child: Text('No'))
                        ],
                      )),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Container createCard(
      String label, VoidCallback onTap, VoidCallback onDelete) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      padding: EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: grey,
        border: Border.all(color: Colors.black, width: .8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: onTap,
            child: Text(label),
          ),
          IconButton(
            tooltip: 'delete ?',
            onPressed: onDelete,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }

  Future<void> initAttendance() async {
    await _controller.getAllAttendance();
  }
}
