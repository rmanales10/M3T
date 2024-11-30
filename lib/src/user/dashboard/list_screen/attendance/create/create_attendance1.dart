import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAttendance1 extends StatefulWidget {
  const CreateAttendance1({super.key});

  @override
  State<CreateAttendance1> createState() => _CreateAttendance1State();
}

class _CreateAttendance1State extends State<CreateAttendance1> {
  final TextEditingController _timeController = TextEditingController();
  final DateFormat _timeFormat = DateFormat("hh:mm a");
  final selectedDate = Rxn<DateTime>();
  final dateFormat = DateFormat('MM/dd/yyyy');
  final _controller = Get.put(CreateController());

  // Drop-down reactive variables
  final selectedSection = 'BSIT 3A'.obs;
  final List<String> sections = [
    'BSIT 3A',
    'BSIT 3B',
    'BSIT 3C',
    'BSIT 3D',
    'BSIT 3E',
    'BSIT 3F',
  ];

  final selectedSubject = 'Elective'.obs;
  final List<String> subjects = [
    'Elective',
    'Mobile Programming',
    'Database',
  ];

  void _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final now = DateTime.now();
      final selectedTime =
          DateTime(now.year, now.month, now.day, picked.hour, picked.minute);
      _timeController.text = _timeFormat.format(selectedTime);
    }
  }

  RxList<Map<String, dynamic>> attendanceRecords = <Map<String, dynamic>>[].obs;
  final isLoading = true.obs;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDate.value = picked;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Attendance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 50),
              _buildDropdownSection(
                label: 'Select Subject:',
                selectedValue: selectedSubject,
                options: subjects,
                onChanged: (newValue) {
                  selectedSubject.value = newValue!;
                },
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Flexible(
                    child: _buildDropdownSection(
                      label: 'Select Section:',
                      selectedValue: selectedSection,
                      options: sections,
                      onChanged: (newValue) {
                        selectedSection.value = newValue!;
                      },
                    ),
                  ),
                  SizedBox(width: 20), // Add spacing between widgets
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Date:'),
                        GestureDetector(
                          onTap: () => _selectDate(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Obx(() => Text(
                                      selectedDate.value != null
                                          ? dateFormat
                                              .format(selectedDate.value!)
                                          : 'MM/DD/YYYY',
                                      style: const TextStyle(fontSize: 16),
                                    )),
                                const SizedBox(width: 8),
                                const Icon(Icons.calendar_today, size: 20),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Select Time:'),
                  selectTime(),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  const SizedBox(height: 20),
                  addAttendanceButton(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox selectTime() {
    return SizedBox(
      width: 200,
      child: TextField(
        controller: _timeController,
        keyboardType: TextInputType.datetime,
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          suffixIcon: IconButton(
            icon: Icon(Icons.access_time),
            onPressed: _selectTime,
          ),
        ),
        onTap: () {
          if (_timeController.text.isEmpty) {
            final now = DateTime.now();
            _timeController.text = _timeFormat.format(now);
          }
        },
      ),
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required RxString selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Obx(
            () => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedValue.value,
                icon: const Icon(Icons.arrow_drop_down),
                isExpanded: true,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                dropdownColor: Colors.grey[300],
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget addAttendanceButton() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1),
      ),
      child: TextButton(
        onPressed: () async {
          await _controller.createAttendance(
              subject: selectedSubject.value,
              section: selectedSection.value,
              date: selectedDate.value,
              time: _timeController.value.text);
          Get.back();
        },
        child: const Row(
          children: [
            Icon(Icons.add_circle_outline),
            SizedBox(width: 15),
            Text('Add Attendance', style: TextStyle(color: Colors.black)),
          ],
        ),
      ),
    );
  }
}
