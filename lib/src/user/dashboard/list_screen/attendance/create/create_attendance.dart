import 'package:app_attend/src/user/dashboard/list_screen/attendance/create/create_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CreateAttendance extends StatefulWidget {
  const CreateAttendance({Key? key}) : super(key: key);

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
  final selectedDepartment = RxnString();
  final List<String> department = [
    'BSIT',
    'BFPT',
    'BTLED - HE',
    'BTLED - ICT',
    'BTLED - IA',
  ];
  final selectedSection = RxnString();
  final sections = RxList<String>();
  final selectedSubject = RxnString();
  final subjects = RxList<String>();
  final isLoading = RxBool(false);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Attendance'),
        centerTitle: true,
      ),
      body: Obx(() => isLoading.value
          ? const Center(child: CircularProgressIndicator())
          : _buildAttendanceForm(size)),
    );
  }

  Widget _buildAttendanceForm(Size size) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDepartmentDropdown(),
            const SizedBox(height: 20),
            if (selectedDepartment.value != null) _buildSubjectDropdown(),
            const SizedBox(height: 20),
            if (selectedSubject.value != null) _buildSectionDropdown(),
            const SizedBox(height: 20),
            if (selectedSection.value != null) _buildDateSelector(context),
            const SizedBox(height: 20),
            if (selectedSection.value != null) _buildTimeSelector(),
            const SizedBox(height: 30),
            if (selectedSection.value != null)
              Center(child: _buildAddAttendanceButton(size)),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentDropdown() {
    return _buildDropdownSection(
      label: 'Select Department:',
      selectedValue: selectedDepartment,
      options: department,
      onChanged: (newValue) async {
        try {
          isLoading.value = true;
          selectedDepartment.value = newValue!;
          subjects.clear();
          selectedSubject.value = null;
          selectedSection.value = null;

          await _controller.fetchSubject(department: selectedDepartment.value!);

          for (var s in _controller.subjects) {
            final courseSubject = '${s['course_code']} ${s['subject_name']}';
            if (!subjects.contains(courseSubject)) {
              subjects.add(courseSubject);
            }
          }

          if (subjects.isNotEmpty) {
            selectedSubject.value = subjects.first;
          }
        } catch (e) {
          _showErrorSnackbar('Failed to fetch subjects');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Widget _buildSubjectDropdown() {
    return _buildDropdownSection(
      label: 'Select Subject:',
      selectedValue: selectedSubject,
      options: subjects,
      onChanged: (newValue) async {
        try {
          isLoading.value = true;
          selectedSubject.value = newValue!;
          sections.clear();
          selectedSection.value = null;

          await _controller.fetchSection(subject: selectedSubject.value!);

          for (var s in _controller.sections) {
            final sectionBlock = s['section_year_block'];
            if (!sections.contains(sectionBlock)) {
              sections.add(sectionBlock);
            }
          }

          if (sections.isNotEmpty) {
            selectedSection.value = sections.first;
          }
        } catch (e) {
          _showErrorSnackbar('Failed to fetch sections');
        } finally {
          isLoading.value = false;
        }
      },
    );
  }

  Widget _buildSectionDropdown() {
    return _buildDropdownSection(
      label: 'Select Section:',
      selectedValue: selectedSection,
      options: sections,
      onChanged: (newValue) => selectedSection.value = newValue!,
    );
  }

  Widget _buildDropdownSection({
    required String label,
    required RxnString selectedValue,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedValue.value,
              isExpanded: true,
              hint: const Text('Select an option'),
              icon: const Icon(Icons.arrow_drop_down),
              style: const TextStyle(fontSize: 16),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: options.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
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
    final canCreateAttendance = selectedDepartment.value != null &&
        selectedSubject.value != null &&
        selectedSection.value != null &&
        selectedDate.value != null &&
        _timeController.text.isNotEmpty;

    return SizedBox(
      width: size.width * 0.7,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: canCreateAttendance ? _createAttendance : null,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text('Add Attendance', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _createAttendance() async {
    if (selectedDepartment.value == null ||
        selectedSubject.value == null ||
        selectedSection.value == null ||
        selectedDate.value == null ||
        _timeController.text.isEmpty) {
      _showErrorSnackbar('Please fill in all required fields');
      return;
    }

    try {
      isLoading.value = true;
      await _controller.createAttendance(
        subject: selectedSubject.value!,
        section: selectedSection.value!,
        date: selectedDate.value!,
        time: _timeController.text,
      );

      Get.back();
      Get.snackbar('Success', 'Attendance created successfully!',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      _showErrorSnackbar('Failed to create attendance: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  }
}
