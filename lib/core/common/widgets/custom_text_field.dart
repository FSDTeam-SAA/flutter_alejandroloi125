import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;

  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool isPassword;
   final Function ?validator;
  final TextInputType keyboardType;
  final int?mexLine;
  final double? width;
  final bool showBorder;
  final Color borderColor;

  // final EdgeInsetsGeometry? contentPadding;
  // final bool filled;
  // final Color? fillColor;
  // final double borderRadius;




  const CustomTextField({
    super.key,
   this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.mexLine,
    this.width,
    this.showBorder = false,
    this.borderColor = Colors.white,
    // this.contentPadding,
    // this.filled = true,
    // this.fillColor,
    // this.borderRadius = 8,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscure = true;



  @override
  Widget build(BuildContext context) {
    return  Container(
      width: widget.width ?? double.infinity,
      height: 52,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10),  color: Color(0xFF1C1C1C),),
      child: TextField(  maxLines: widget.mexLine ?? 1,
        style: const TextStyle(color: Colors.white),
        cursorColor: Colors.white,
        controller: widget.controller,
        obscureText: widget.isPassword ? _obscure : false,
        keyboardType: widget.keyboardType,

        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w400,),
          prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 24, color: Color(0xFFB1B3B4)) : null,
          suffixIcon: widget.isPassword ? IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, size: 18, color: const Color(0xffB4B4B4),), onPressed: () {setState(() {_obscure = !_obscure;});},) : null,



          enabledBorder:widget.showBorder? OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: widget.borderColor),
            
          ):InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: BorderSide(color: widget.borderColor),
            //borderSide: const BorderSide(color: Color(0xFF283280), width: 2),
          ),
        ),
      ),
    );
  }
}

