import 'dart:developer';

import 'package:app_attend/src/user/api_services/auth_service.dart';
import 'package:app_attend/src/user/api_services/firestore_service.dart';
import 'package:app_attend/src/user/dashboard/list_screen/home/home_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:app_attend/src/widgets/status_widget.dart';
import 'package:app_attend/src/widgets/time_clock.dart';
import 'package:app_attend/src/widgets/time_controller.dart';
import 'package:app_attend/src/widgets/upcoming_reminder.dart';
import 'package:app_attend/src/widgets/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeFinal extends StatefulWidget {
  const HomeFinal({super.key});

  @override
  State<HomeFinal> createState() => _HomeFinalState();
}

class _HomeFinalState extends State<HomeFinal> {
  late TimeController timeController;
  late AuthService authService;
  late FirestoreService firestoreService;
  late HomeController _controller;
  final selectedSubject = RxnString();
  final subjectNames = RxList<String>();
  Rx<DateTime> date = DateTime.now().obs;
  RxString time = "".obs;
  RxInt totalPresent = 0.obs;
  RxInt totalAbsent = 0.obs;
  RxInt totalStudent = 0.obs;

  @override
  void initState() {
    super.initState();
    timeController = Get.put(TimeController());
    authService = Get.put(AuthService());
    firestoreService = Get.put(FirestoreService());
    _controller = Get.put(HomeController());

    _controller.fetchAllRecord();
    for (var attend in _controller.allRecord) {
      if (subjectNames.contains(attend['subject'])) break;
      subjectNames.addNonNull(attend['subject'].toString());
    }
  }

  String _formatSubject(Map<String, dynamic> record) {
    final subject = record['subject'] as String;
    final section = record['section'] as String;
    final recordTime = record['time'] as String;
    final timestamp = record['date'];
    DateTime recordDate =
        timestamp is Timestamp ? timestamp.toDate() : (timestamp as DateTime);
    return '$subject $section ${DateFormat('MM/dd/yyyy').format(recordDate)} $recordTime';
  }

  void _updateDateTimeFromSelection(String selected) {
    log('Selected item: $selected');
    final parts = selected.split(' ');
    if (parts.length < 2) return;
    final selectedDateTimeStr =
        '${parts[parts.length - 2]} ${parts[parts.length - 1]}';
    try {
      final selectedDateTime =
          DateFormat('MM/dd/yyyy hh:mm a').parse(selectedDateTimeStr);
      date.value = selectedDateTime;
      time.value = DateFormat('hh:mm a').format(selectedDateTime);
    } catch (e) {
      log('Error parsing date and time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUserProfile(),
              const SizedBox(height: 20),
              _buildTimeClock(),
              const SizedBox(height: 20),
              _buildSubjectDropdown(size),
              const SizedBox(height: 20),
              _buildInOutStatus(),
              const SizedBox(height: 20),
              _buildUpcomingReminders(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return Obx(() => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: blue,
          ),
          child: UserProfileWidget(
            name: firestoreService.userData['fullname'] ?? 'No Name',
            email: 'Instructor',
            profileImageUrl: 'assets/logo.png',
          ),
        ));
  }

  Widget _buildTimeClock() {
    return Obx(() => TimeClockWidget(
          time: timeController.currentTime.value,
          role: timeController.timeOfDay.value,
        ));
  }

  Widget _buildSubjectDropdown(Size size) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() => DropdownButton<String>(
            value: selectedSubject.value,
            icon: const Icon(Icons.arrow_drop_down),
            elevation: 16,
            hint: Text('Select an option'),
            underline: const SizedBox(),
            style: const TextStyle(color: Colors.black),
            onChanged: (String? newValue) {
              if (newValue != null) {
                totalStudent.value = 0;
                totalPresent.value = 0;
                totalAbsent.value = 0;
                selectedSubject.value = newValue;
                _updateDateTimeFromSelection(newValue);
                _controller.fetchSubjectOnly(subject: selectedSubject.value);
                for (var present in _controller.subjectOnly) {
                  for (var record in present['student_record']) {
                    if (record['present'] == '✓') {
                      totalPresent.value++;
                    }
                    if (record['present'] == 'X') {
                      totalAbsent.value++;
                    }
                    totalStudent.value++;
                  }
                }
              }
            },
            items: subjectNames.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            isExpanded: true,
          )),
    );
  }

  Widget _buildInOutStatus() {
    return Obx(() => InOutStatusWidget(
          inCount: totalPresent.value,
          breakCount: totalStudent.value,
          outCount: totalAbsent.value,
          dateTime:
              '${DateFormat('EEEE, d MMM yyyy').format(date.value)} ${time.value}',
          firstIn: time.value,
          lastOut: "",
        ));
  }

  Widget _buildUpcomingReminders() {
    return UpcomingRemindersWidget(
      reminders: [
        Reminder(
          month: "May",
          day: 27,
          notes: ["Pay period cycle ends in 2 days"],
        ),
        Reminder(
          month: "May",
          day: 28,
          notes: ["Labour Day", "Timesheet approvals due date"],
        ),
      ],
    );
  }
}
