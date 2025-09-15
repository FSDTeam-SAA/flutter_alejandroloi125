import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PrivacyPolicyScreenView extends StatelessWidget {
  const PrivacyPolicyScreenView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: Text("Privacy Policy",style: TextStyle(color: Colors.white,fontSize: 24,fontWeight: FontWeight.w700),),
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.black,

      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Text(""""Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi lobortis risus eget magna euismod rhoncus. Vivamus eu lectus a lectus interdum placerat. Praesent consectetur ante orci, non mattis massa posuere in. Integer blandit ut mi eu efficitur. Praesent congue, arcu vitae malesuada vehicula, lacus velit facilisis velit, ut vehicula sapien erat id dui. Proin nisi ante, ullamcorper vitae libero eu, mollis venenatis lectus. Integer auctor et sem at sollicitudin. Sed eget diam nisi. Nulla in id.
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi lobortis risus eget magna euismod rhoncus. Vivamus eu lectus a lectus interdum placerat. Praesent consectetur ante orci, non mattis massa posuere in. Integer blandit ut mi eu efficitur. Praesent congue, arcu vitae malesuada vehicula, lacus velit facilisis velit, ut vehicula sapien erat id dui. Proin nisi ante, ullamcorper vitae libero eu, mollis venenatis lectus. Integer auctor et sem at sollicitudin. Sed eget diam nisi. Nulla in id.
          Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi lobortis risus eget magna euismod rhoncus. Vivamus eu lectus a lectus interdum placerat. Praesent consectetur ante orci, non mattis massa posuere in. Integer blandit ut mi eu efficitur. Praesent congue, arcu vitae malesuada vehicula, lacus velit facilisis velit, ut vehicula sapien erat id dui. Proin nisi ante, ullamcorper vitae libero eu, mollis venenatis lectus. Integer auctor et sem at sollicitudin. Sed eget diam nisi. Nulla in id."""
            ,style: TextStyle(fontSize: 14,color: Color(0xFFE0E0E0),),textAlign: TextAlign.justify,),
        ),
      ),
    );
  }
}
