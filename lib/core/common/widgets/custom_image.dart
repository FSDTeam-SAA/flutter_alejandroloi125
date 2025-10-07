// lib/core/common/widgets/custom_image.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerSlot extends StatefulWidget {
  final double width;
  final double height;
  final ValueChanged<File?>? onSelected; // notify provider

  const ImagePickerSlot({
    super.key,
    this.width = 120,
    this.height = 120,
    this.onSelected,
  });

  @override
  State<ImagePickerSlot> createState() => _ImagePickerSlotState();
}

class _ImagePickerSlotState extends State<ImagePickerSlot> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final file = File(picked.path);
        setState(() => _image = file);
        widget.onSelected?.call(file); // pass to provider
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _removeImage() {
    setState(() => _image = null);
    widget.onSelected?.call(null); // clear in provider
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _image == null ? _pickImage : null,
      child: _image != null
          ? Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              _image!,
              width: widget.width,
              height: widget.height,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: InkWell(
              onTap: _removeImage,
              child: const CircleAvatar(
                radius: 14,
                backgroundColor: Colors.red,
                child: Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      )
          : Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
            SizedBox(height: 6),
            Text("Add Image", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}


// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
//
// class ImagePickerSlot extends StatefulWidget {
//   final double width;
//   final double height;
//
//   const ImagePickerSlot({
//     super.key,
//     this.width = 120,
//     this.height = 120,
//   });
//
//   @override
//   State<ImagePickerSlot> createState() => _ImagePickerSlotState();
// }
//
// class _ImagePickerSlotState extends State<ImagePickerSlot> {
//   File? _image;
//
//   final ImagePicker _picker = ImagePicker(); // initialize once
//
//   Future<void> _pickImage() async {
//     try {
//       final picked = await _picker.pickImage(source: ImageSource.gallery);
//       if (picked != null) {
//         setState(() => _image = File(picked.path));
//       }
//     } catch (e) {
//       debugPrint('Image pick error: $e');
//     }
//   }
//
//   void _removeImage() {
//     setState(() => _image = null);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: _image == null ? _pickImage : null, // tap only if empty
//       child: _image != null
//           ? Stack(
//         clipBehavior: Clip.none,
//         children: [
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.file(
//               _image!,
//               width: widget.width,
//               height: widget.height,
//               fit: BoxFit.cover,
//             ),
//           ),
//           Positioned(
//             top: -6,
//             right: -6,
//             child: InkWell(
//               onTap: _removeImage,
//               child: const CircleAvatar(
//                 radius: 14,
//                 backgroundColor: Colors.red,
//                 child: Icon(Icons.close, color: Colors.white, size: 16),
//               ),
//             ),
//           ),
//         ],
//       )
//           : Container(
//         width: widget.width,
//         height: widget.height,
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.add_photo_alternate, size: 32, color: Colors.grey),
//             SizedBox(height: 6),
//             Text("Add Image", style: TextStyle(color: Colors.grey)),
//           ],
//         ),
//       ),
//     );
//   }
// }
