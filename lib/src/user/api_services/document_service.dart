import 'dart:developer';

import 'package:get/get.dart';

class DocumentService extends GetConnect {
  // POST request to generate document
  Future<Response> generateDocument() async {
    // Prepare the data to send in the request
    final data = {
      "document": "2RRLUXvDTbIQ9DA4n5Bx",
      "apiKey": "KZ54NBI-MEPE5AI-QCBLXJI-OY3KVPA",
      "format": "docx",
      "data": {
        "name": "name",
        "city": "city",
        "conditional": true,
        "products": [
          {"product": "product", "price": "price"}
        ],
        "fullname": "Ginbert Fernandez",
        "section": "BSIT 2c",
        "idnumber": "2020307507"
      }
    };

    // Send POST request
    final response = await post('https://app.documentero.com/api', data);

    // Check the response status
    if (response.statusCode == 200) {
      // Successfully generated document
      log('Document generated successfully!');
      return response;
    } else {
      // Handle error
      log('Failed to generate document: ${response.statusText}');
      throw Exception('Failed to generate document');
    }
  }
}
