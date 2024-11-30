import 'package:app_attend/src/user/dashboard/list_screen/report/report_controller.dart';
import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final _controller = Get.put(ReportController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Generated'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Obx(() {
          _controller.getReports();

          return ListView.builder(
              itemCount: _controller.reports.length,
              itemBuilder: (context, index) {
                final report = _controller.reports[index];
                return Column(
                  children: [
                    searchBar(),
                    SizedBox(height: 20),
                    reportCard(
                        '${report['subject']}\n${report['section']}',
                        '${report['date']}',
                        '${report['type']}',
                        '${report['url']}'),
                    // reportCard('IT314 - Software Engineering\nBSIT - 1C',
                    //     '11/02/2024', 'CSV'),
                  ],
                );
              });
        }),
      ),
    );
  }

  Align searchBar() {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 180,
        height: 50,
        child: TextField(
          decoration: InputDecoration(
            labelText: 'Search',
            suffixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
      ),
    );
  }

  Align reportCard(
      String sectionLabel, String date, String fileType, String url) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 350,
        margin: EdgeInsets.symmetric(vertical: 5),
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: blue,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sectionLabel,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: blue),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontSize: 15, color: blue),
                    ),
                    SizedBox(width: 30),
                    Text(
                      fileType,
                      style: TextStyle(fontSize: 15, color: blue),
                    ),
                  ],
                ),
              ],
            ),
            Spacer(),
            IconButton(
                onPressed: () {
                  final Uri downloadLink = Uri.parse(url);
                  launchUrl(downloadLink);
                },
                icon: Icon(Icons.download))
          ],
        ),
      ),
    );
  }

  Text rowText(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Text rowLabel(String label) {
    return Text(
      label,
      style: TextStyle(fontSize: 18),
    );
  }

  Align labelSubject(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: blue,
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Align labelTitle() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Subject: ',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
