// import 'package:flutter/material.dart';
//
// class Header extends StatelessWidget {
//   final String title;
//   final VoidCallback? onBack;
//   final List<Widget>? actions;
//   final Widget? child;
//   final double heightFactor; // 0.0 to 1.0, where 1.0 = full screen height
//
//   const Header({
//     Key? key,
//     required this.title,
//     this.onBack,
//     this.actions,
//     this.child,
//     this.heightFactor = 0.15, // Default small header
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final screenHeight = MediaQuery.of(context).size.height;
//     final headerHeight = screenHeight * heightFactor;
//
//     // Curve intensity increases with height
//     final curveDepth = headerHeight * 0.15; // Curve depth is 15% of header height
//
//     return SizedBox(
//       height: headerHeight,
//       child: Stack(
//         children: [
//           // Curved background
//           CustomPaint(
//             size: Size(double.infinity, headerHeight),
//             painter: _CurvedHeaderPainter(
//               color: theme.primaryColor,
//               curveDepth: curveDepth,
//             ),
//           ),
//           // Content
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 18),
//               child: Column(
//                 children: [
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       if (onBack != null)
//                         IconButton(
//                           icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
//                           onPressed: onBack,
//                         )
//                       else
//                         SizedBox(width: 6),
//                       Expanded(
//                         child: Text(
//                           title,
//                           style: const TextStyle(
//                             fontSize: 22,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             letterSpacing: 0.7,
//                           ),
//                           textAlign: TextAlign.left,
//                         ),
//                       ),
//                       if (actions != null) ...actions!,
//                     ],
//                   ),
//                   if (child != null)
//                     Expanded(child: child!),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CurvedHeaderPainter extends CustomPainter {
//   final Color color;
//   final double curveDepth;
//
//   _CurvedHeaderPainter({required this.color, required this.curveDepth});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = color
//       ..style = PaintingStyle.fill;
//
//     final path = Path();
//     path.lineTo(0, size.height - curveDepth);
//
//     // Create smooth curve at bottom
//     path.quadraticBezierTo(
//       size.width / 2,
//       size.height,
//       size.width,
//       size.height - curveDepth,
//     );
//
//     path.lineTo(size.width, 0);
//     path.close();
//
//     canvas.drawPath(path, paint);
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }



import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? child;
  final double heightFactor;

  const Header({
    Key? key,
    required this.title,
    this.actions,
    this.child,
    this.heightFactor = 0.12, // Default 12% of screen height
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.primaryColor;
    final screenHeight = MediaQuery.of(context).size.height;
    final headerHeight = screenHeight * heightFactor;

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Centered Title
            Positioned.fill(
              child: Center(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Optional actions aligned to top-right
            if (actions != null)
              Positioned(
                top: 12,
                right: 24,
                child: Row(children: actions!),
              ),

            // Optional child content inside header
            if (child != null)
              Positioned.fill(
                child: child!,
              ),
          ],
        ),
      ),
    );
  }
}