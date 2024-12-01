import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAttendance extends StatefulWidget {
  const CreateAttendance({super.key});

  @override
  State<CreateAttendance> createState() => _CreateAttendanceState();
}

class _CreateAttendanceState extends State<CreateAttendance> {
  final TextEditingController _timeController = TextEditingController();
  final DateFormat _timeFormat = DateFormat("hh:mm a");
  final DateFormat dateFormat = DateFormat('MM/dd/yyyy');

  final selectedDate = Rxn<DateTime>();
  final _controller = Get.put(CreateController());

  // Dropdown reactive variables

  final selectedDepartment = 'BSIT'.obs;
  final List<String> department = [
    'BSIT',
    'BFPT',
    'BTLED - HE',
    'BTLED - ICT',
    'BTLED - IA',
  ];
  final RxString selectedSection = ''.obs;
  final RxList<String> sections = <String>[].obs;
  final RxString selectedSubject = ''.obs;
  final RxList<String> subjects = <String>[].obs;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Attendance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdownSection(
                label: 'Select Department:',
                selectedValue: selectedDepartment,
                options: department,
                onChanged: (newValue) async {
                  subjects.clear();
                  selectedDepartment.value = newValue!;
                  await _controller.fetchSubject(
                      department: selectedDepartment.value);
                  for (var s in _controller.subjects) {
                    if (subjects.contains(s['course_code'])) {
                      break;
                    }
                    subjects
                        .addNonNull('${s['course_code']} ${s['subject_name']}');
                  }
                  selectedSubject.value = subjects.first;
                },
              ),
              const SizedBox(height: 20),
              _buildDropdownSection(
                label: 'Select Subject:',
                selectedValue: selectedSubject,
                options: subjects,
                onChanged: (newValue) async {
                  sections.clear();
                  selectedSubject.value = newValue!;
                  await _controller.fetchSection(
                      subject: selectedSubject.value);

                  for (var s in _controller.sections) {
                    if (sections.contains(s['section_year_block'])) {
                      break;
                    }
                    sections.addNonNull('${s['section_year_block']}');
                  }
                  selectedSection.value = sections.first;
                },
              ),
              const SizedBox(height: 20),
              _buildDropdownSection(
                label: 'Select Section:',
                selectedValue: selectedSection,
                options: sections,
                onChanged: (newValue) => selectedSection.value = newValue!,
              ),
              const SizedBox(height: 20),
              _buildDateSelector(context),
              const SizedBox(height: 20),
              _buildTimeSelector(),
              const SizedBox(height: 30),
              Center(child: _buildAddAttendanceButton(size)),
            ],
          ),
        ),
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
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
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
                isExpanded: true,
                icon: const Icon(Icons.arrow_drop_down),
                style: const TextStyle(fontSize: 16),
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: TextStyle(color: Colors.black),
                    ),
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

  Widget _buildDateSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Date:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Obx(() => Text(
                      selectedDate.value != null
                          ? dateFormat.format(selectedDate.value!)
                          : 'MM/DD/YYYY',
                      style: const TextStyle(fontSize: 16),
                    )),
                const Spacer(),
                const Icon(Icons.calendar_today, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Time:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextField(
          controller: _timeController,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select time',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            suffixIcon: IconButton(
              icon: const Icon(Icons.access_time),
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
      ],
    );
  }

  Widget _buildAddAttendanceButton(Size size) {
    return SizedBox(
      width: size.width * 0.7,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _createAttendance,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Attendance', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

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

  Future<void> _selectTime() async {
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

  Future<void> _createAttendance() async {
    if (selectedDate.value == null || _timeController.text.isEmpty) {
      Get.snackbar('Error', 'Please select a valid date and time.');
      return;
    }

    await _controller.createAttendance(
      subject: selectedSubject.value,
      section: selectedSection.value,
      date: selectedDate.value,
      time: _timeController.value.text,
    );

    Get.back();
    Get.snackbar('Success', 'Attendance created successfully!');
  }
}
