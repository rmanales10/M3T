import 'package:app_attend/src/widgets/color_constant.dart';
import 'package:flutter/material.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report Generated'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: Column(
          children: [
            searchBar(),
            SizedBox(height: 20),
            reportCard('IT312 - Networking\nBSIT - 1B', '11/03/2024', 'PDF'),
            reportCard(
                'IT314 - Software Engineering\nBSIT - 1C', '11/02/2024', 'CSV'),
          ],
        ),
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

  Align reportCard(String sectionLabel, String date, String fileType) {
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
        child: Column(
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
