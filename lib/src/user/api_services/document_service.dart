import 'dart:developer';

import 'package:get/get.dart';

class DocumentService extends GetConnect {
  Future<Response> generateDocument(
      {required var record, required var subject, required var datenow}) async {
    final data = {
      "document": "xDm6j3d7Ck6klGH4UsS2",
      "apiKey": "5MIC3AY-OFTEYII-X5OVCOA-GQO6KFY",
      "format": "docx",
      "data": {
        "subject": subject,
        "schedule": "schedule",
        "code": "code",
        "room": "room",
        "date": datenow,
        "record": record,
        "teacher": "teacher",
        "datenow": "datenow"
      }
    };

    final response = await post('https://app.documentero.com/api', data);

    if (response.statusCode == 200) {
      log('Document generated successfully!');
      return response;
    } else {
      log('Failed to generate document: ${response.statusText}');
      throw Exception('Failed to generate document');
    }
  }
}
