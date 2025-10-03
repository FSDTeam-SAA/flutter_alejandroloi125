// import 'dart:io';
// import 'package:http/http.dart' as http;
//
// import '../../../constants/api_constants.dart';
// import '../models/investment.dart';
//
// class InvestmentRepository {
//   /// POST /investments  (adjust path to your backend)
//   Future<http.StreamedResponse> createInvestment({
//     required InvestmentPayload payload,
//     required List<File> images,
//     String? bearer,
//   }) async {
//     final uri = ApiConstants.api('investment/create-investment'); // <-- confirm your path
//     final req = http.MultipartRequest('POST', uri);
//
//     // Authorization only; DO NOT set content-type
//     req.headers.addAll(ApiConstants.authOnlyHeaders(bearer: bearer));
//
//     // fields
//     req.fields.addAll(payload.toFormFields());
//
//     // images (optional)
//     for (var i = 0; i < images.length; i++) {
//       final file = images[i];
//       final stream = http.ByteStream(file.openRead());
//       final length = await file.length();
//       req.files.add(http.MultipartFile(
//         'images', // <-- match backend field key
//         stream,
//         length,
//         filename: file.path.split('/').last,
//       ));
//     }
//
//     return await req.send();
//   }
// }
