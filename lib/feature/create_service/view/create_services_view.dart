import 'package:alejandroloi/core/util/styles.dart';
import 'package:flutter/material.dart';

class CreateServicesView extends StatelessWidget {
  const CreateServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black,
        title: Text("Create Services",style: headingText,),
      ),
      body: Column(children: [],),
    );
  }
}
