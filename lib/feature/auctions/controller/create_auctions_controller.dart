import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CreateAuctionsController extends GetxController{

  var selectedOption = "ICE".obs;


  final List<Map<String, dynamic>> options = [
    {"label": "ICE", "color": Colors.green},
    {"label": "Fire", "color": Colors.red},
    {"label": "Police", "color": Colors.blue},
    {"label": "Ambulance", "color": Colors.amber},
  ];
}