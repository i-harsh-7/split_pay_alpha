// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';
// import '../components/header.dart';
//
// class AddBillPage extends StatefulWidget {
//   const AddBillPage({super.key});
//
//   @override
//   State<AddBillPage> createState() => _AddBillPageState();
// }
//
// class _AddBillPageState extends State<AddBillPage> {
//   File? _capturedImage;
//   final ImagePicker _picker = ImagePicker();
//
//   Future<void> _takePhoto() async {
//     try {
//       final XFile? photo = await _picker.pickImage(
//         source: ImageSource.camera,
//         maxWidth: 1800,
//         maxHeight: 1800,
//         imageQuality: 85,
//       );
//
//       if (photo != null) {
//         setState(() {
//           _capturedImage = File(photo.path);
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error capturing photo: $e')),
//       );
//     }
//   }
//
//   Future<void> _uploadImage() async {
//     if (_capturedImage == null) return;
//
//     // TODO: Implement API call to backend
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Upload functionality - API pending')),
//     );
//
//     // After successful upload, you can navigate or reset
//     // Navigator.pop(context);
//   }
//
//   void _retakePhoto() {
//     setState(() {
//       _capturedImage = null;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final isDark = theme.brightness == Brightness.dark;
//
//     return Scaffold(
//       backgroundColor: theme.scaffoldBackgroundColor,
//       body: Column(
//         children: [
//           // Header with "Add Bill" title
//           Header(
//             title: 'Add Bill',
//             heightFactor: 0.12,
//           ),
//
//           // Main content
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: _capturedImage == null
//                   ? _buildInitialView(isDark)
//                   : _buildPreviewView(isDark),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildInitialView(bool isDark) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Large camera icon placeholder
//         Container(
//           width: double.infinity,
//           height: 280,
//           decoration: BoxDecoration(
//             color: isDark ? Colors.grey[800] : Colors.grey[300],
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Icon(
//             Icons.camera_alt_outlined,
//             size: 120,
//             color: isDark ? Colors.grey[600] : Colors.grey[400],
//           ),
//         ),
//
//         const SizedBox(height: 30),
//
//         // Take Photo button
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton.icon(
//             onPressed: _takePhoto,
//             icon: const Icon(Icons.camera_alt, size: 24),
//             label: const Text(
//               'Take photo',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF5B8DEE),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 2,
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 15),
//
//         // Manual Add button
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton.icon(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => ManuallyAddPage(
//                     groupId: widget.groupId,
//                     members: widget.members,
//                   ),
//                 ),
//               );
//             },
//
//             icon: const Icon(Icons.edit_outlined, size: 24),
//             label: const Text(
//               'Manual Add',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isDark ? Colors.grey[800] : Colors.white,
//               foregroundColor: const Color(0xFF5B8DEE),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 side: BorderSide(
//                   color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                   width: 1,
//                 ),
//               ),
//               elevation: 1,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPreviewView(bool isDark) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         // Display captured image
//         Container(
//           width: double.infinity,
//           height: 280,
//           decoration: BoxDecoration(
//             color: isDark ? Colors.grey[800] : Colors.grey[300],
//             borderRadius: BorderRadius.circular(20),
//             image: _capturedImage != null
//                 ? DecorationImage(
//               image: FileImage(_capturedImage!),
//               fit: BoxFit.cover,
//             )
//                 : null,
//           ),
//         ),
//
//         const SizedBox(height: 30),
//
//         // Upload button
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton.icon(
//             onPressed: _uploadImage,
//             icon: const Icon(Icons.cloud_upload, size: 24),
//             label: const Text(
//               'Upload',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF5B8DEE),
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               elevation: 2,
//             ),
//           ),
//         ),
//
//         const SizedBox(height: 15),
//
//         // Retake Photo button
//         SizedBox(
//           width: double.infinity,
//           height: 55,
//           child: ElevatedButton.icon(
//             onPressed: _retakePhoto,
//             icon: const Icon(Icons.camera_alt, size: 24),
//             label: const Text(
//               'Retake Photo',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: isDark ? Colors.grey[800] : Colors.white,
//               foregroundColor: const Color(0xFF5B8DEE),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//                 side: BorderSide(
//                   color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                   width: 1,
//                 ),
//               ),
//               elevation: 1,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }




import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../components/header.dart';
import 'manual_add.dart'; // ADD THIS IMPORT

class AddBillPage extends StatefulWidget {
  final String groupId;  // ADD THIS
  final List<Map<String, String>> members;  // ADD THIS

  const AddBillPage({
    super.key,
    required this.groupId,  // ADD THIS
    required this.members,  // ADD THIS
  });

  @override
  State<AddBillPage> createState() => _AddBillPageState();
}

class _AddBillPageState extends State<AddBillPage> {
  File? _capturedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = File(photo.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error capturing photo: $e')),
      );
    }
  }

  Future<void> _uploadImage() async {
    if (_capturedImage == null) return;

    // TODO: Implement API call to backend
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Upload functionality - API pending')),
    );

    // After successful upload, you can navigate or reset
    // Navigator.pop(context);
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header with "Add Bill" title
          Header(
            title: 'Add Bill',
            heightFactor: 0.12,
          ),

          // Main content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: _capturedImage == null
                  ? _buildInitialView(isDark)
                  : _buildPreviewView(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Large camera icon placeholder
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            Icons.camera_alt_outlined,
            size: 120,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
        ),

        const SizedBox(height: 30),

        // Take Photo button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(

            onPressed: _takePhoto,

            icon: const Icon(Icons.camera_alt, size: 24),
            label: const Text(
              'Take photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B8DEE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Manual Add button - UPDATED
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManuallyAddPage(
                    groupId: widget.groupId,
                    members: widget.members,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 24),
            label: const Text(
              'Manual Add',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              foregroundColor: const Color(0xFF5B8DEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              elevation: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewView(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Display captured image
        Container(
          width: double.infinity,
          height: 280,
          decoration: BoxDecoration(
            color: isDark ? Colors.grey[800] : Colors.grey[300],
            borderRadius: BorderRadius.circular(20),
            image: _capturedImage != null
                ? DecorationImage(
              image: FileImage(_capturedImage!),
              fit: BoxFit.cover,
            )
                : null,
          ),
        ),

        const SizedBox(height: 30),

        // Upload button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _uploadImage,
            icon: const Icon(Icons.cloud_upload, size: 24),
            label: const Text(
              'Upload',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B8DEE),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
            ),
          ),
        ),

        const SizedBox(height: 15),

        // Retake Photo button
        SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton.icon(
            onPressed: _retakePhoto,
            icon: const Icon(Icons.camera_alt, size: 24),
            label: const Text(
              'Retake Photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? Colors.grey[800] : Colors.white,
              foregroundColor: const Color(0xFF5B8DEE),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                  color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              elevation: 1,
            ),
          ),
        ),
      ],
    );
  }
}
