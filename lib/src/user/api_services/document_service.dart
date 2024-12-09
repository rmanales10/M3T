import 'dart:developer';

import 'package:get/get.dart';

class DocumentService extends GetConnect {
  Future<Response> generateDocument({
    required var record,
    required var subject,
    required var datenow,
    required var code,
    required var teacher,
  }) async {
    final data = {
      "document": "xDm6j3d7Ck6klGH4UsS2",
      "apiKey": "5MIC3AY-OFTEYII-X5OVCOA-GQO6KFY",
      "format": "docx",
      "data": {
        "subject": subject,
        "schedule": "",
        "code": code,
        "room": "",
        "date": datenow,
        "record": record,
        "teacher": teacher,
        "datenow": datenow
      }
    };

    final response = await post('https://app.documentero.com/api', data);

    if (response.statusCode == 200) {
      log('Document generated successfully!');
      log('$response');
      return response;
    } else {
      log('Failed to generate document: ${response.statusText}');
      throw Exception('Failed to generate document');
    }
  }
}
