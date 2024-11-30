import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/api_services/firestore_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_attendance1.dart';
import 'package:app_attend/src/user/dashboard/list_screen/attendance/student_list/student_list.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/reusable_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AuthService _authService = Get.put(AuthService());
  final FirestoreService _firestoreService = Get.put(FirestoreService());

  @override
  void initState() {
    super.initState();
    fetchAttendanceRecords();
  }

  void fetchAttendanceRecords() async {
    if (_authService.currentUser != null) {
      await _firestoreService.retrieveAttendance(
          userId: _authService.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                if (_firestoreService.attendanceRecords.isEmpty) {
                  return Center(child: Text('No attendance records found'));
                }

                return ListView.builder(
                  itemCount: _firestoreService.attendanceRecords.length,
                  itemBuilder: (context, index) {
                    final record = _firestoreService.attendanceRecords[index];
                    String label =
                        'Subject: ${record['subject']}\nSection: ${record['section']}\nDate: ${record['date'].toString().substring(0, 10)}';

                    return createCard(
                      label,
                      () => Get.to(() => StudentList(
                            subject: record['subject'],
                            section: record['section'],
                            dateTime: record['date'],
                            time: record['time'],
                          )),
                      () => Get.dialog(AlertDialog(
                        title: Text('Confirmation'),
                        content: Text(
                            'Are you sure you want to delete this attendance?'),
                        actions: [
                          ElevatedButton(
                              onPressed: () async {
                                fetchAttendanceRecords();
                                Get.back();
                                _firestoreService.deleteAttendanceRecord(
                                  userId: _authService.currentUser!.uid,
                                  attendanceId: record['id'],
                                );
                              },
                              child: Text('Yes')),
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
            onPressed: onDelete,
            icon: Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
