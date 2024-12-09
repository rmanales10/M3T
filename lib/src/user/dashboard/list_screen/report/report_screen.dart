import 'package:app_attend/src/user/dashboard/list_screen/report/report_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatelessWidget {
  final _controller = Get.put(ReportController());
  final TextEditingController _searchController = TextEditingController();

  ReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Generated'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Align(alignment: Alignment.centerRight, child: _buildSearchBar()),
            const SizedBox(height: 20),
            Expanded(
              child: Obx(() {
                _controller.getReports();
                final reports = _controller.filteredReports;

                if (reports.isEmpty) {
                  return const Center(
                    child: Text(
                      'No reports available.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _buildReportCard(
                      sectionLabel:
                          '${report['subject']}\n${report['section']}',
                      date: '${report['date']}',
                      fileType: '${report['type']}',
                      url: '${report['url']}',
                      id: report['attendance_id'],
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

  Widget _buildSearchBar() {
    return SizedBox(
      width: 200,
      height: 40,
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          labelText: 'Search',
          suffixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onChanged: (query) {
          _controller.updateSearchQuery(query); // Trigger search filtering
        },
      ),
    );
  }

  Widget _buildReportCard({
    required String sectionLabel,
    required String date,
    required String fileType,
    required String url,
    required String id,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: blue, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: blue,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontSize: 14, color: blue),
                    ),
                    const SizedBox(width: 30),
                    Text(
                      fileType,
                      style: TextStyle(fontSize: 14, color: blue),
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              final Uri downloadLink = Uri.parse(url);
              launchUrl(downloadLink, mode: LaunchMode.externalApplication);
            },
            icon: const Icon(Icons.download),
            color: blue,
          ),
          IconButton(
            onPressed: () {
              Get.dialog(AlertDialog(
                title: Text('Confirmation'),
                content: Text('Are you sure you want to delete?'),
                actions: [
                  TextButton(
                      onPressed: () async {
                        await _controller.deleteReports(id);
                        Get.back(closeOverlays: true);
                        Get.snackbar('Success', 'Report deleted successfully!');
                      },
                      child: Text(
                        'Delete',
                        style: TextStyle(color: Colors.red),
                      )),
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.blue),
                      )),
                ],
              ));
            },
            icon: const Icon(Icons.delete),
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
