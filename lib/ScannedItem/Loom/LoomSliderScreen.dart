// import 'package:flutter/material.dart';
//
// import '../../Color/Colorclass.dart';
// import '../../JBL/JBL_Loom/SavedListScreenLomm.dart';
// import 'LoomScreen.dart';
//
// class LoomSliderScreen extends StatefulWidget {
//   final String screenType;
//   const LoomSliderScreen({Key? key, required this.screenType})
//     : super(key: key);
//
//   @override
//   State<LoomSliderScreen> createState() => _LoomSliderScreenState();
// }
//
// class _LoomSliderScreenState extends State<LoomSliderScreen> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//
//   final List<String> _screenTitles = ['All'];
//
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         title: const Text(
//           'Loom Management',
//           style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
//         ),
//         centerTitle: false,
// actions: [ Row(
//   mainAxisSize: MainAxisSize.min,
//   children: [
//     ElevatedButton(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: C.warning,
//         padding: const EdgeInsets.symmetric(
//           horizontal: 12,
//           vertical: 6,
//         ),
//       ),
//       onPressed: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SavedListScreen(),
//           ),
//         );
//       },
//       child: const Text(
//         "Saved List",
//         style: TextStyle(color: Colors.white, fontSize: 11),
//       ),
//     ),
//   ],
// ),],
//       ),
//       body: Column(
//         children: [
//
//           // Tab Indicator
//           Container(
//             color: Colors.white,
//             padding: const EdgeInsets.symmetric(vertical: 12),
//             child: Row(
//               children: List.generate(_screenTitles.length, (index) {
//                 final isActive = _currentPage == index;
//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () {
//                       _pageController.animateToPage(
//                         index,
//                         duration: const Duration(milliseconds: 300),
//                         curve: Curves.easeInOut,
//                       );
//                     },
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       margin: const EdgeInsets.symmetric(horizontal: 4),
//                       decoration: BoxDecoration(
//                         border: Border(
//                           bottom: BorderSide(
//                             color: isActive ? Colors.blue : Colors.transparent,
//                             width: 2,
//                           ),
//                         ),
//                       ),
//                       child: Text(
//                         _screenTitles[index],
//                         textAlign: TextAlign.center,
//                         style: TextStyle(
//                           color: isActive ? Colors.blue : Colors.grey[600],
//                           fontWeight: isActive
//                               ? FontWeight.w600
//                               : FontWeight.normal,
//                           fontSize: 15,
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//
//           // Page View
//           Expanded(
//             child: PageView(
//               controller: _pageController,
//               onPageChanged: (index) {
//                 setState(() {
//                   _currentPage = index;
//                 });
//               },
//               children: const [
//                 LoomForwardScreen(),
//                 // LoomOutpostScreen(),
//                 // LoomListScreen(),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//




import 'package:flutter/material.dart';

import '../../Color/Colorclass.dart';
import '../../JBL/JBL_Loom/SavedListScreenLomm.dart';
import 'LoomScreen.dart';

class LoomSliderScreen extends StatefulWidget {
  final String screenType;

  const LoomSliderScreen({
    Key? key,
    required this.screenType,
  }) : super(key: key);

  @override
  State<LoomSliderScreen> createState() => _LoomSliderScreenState();
}

class _LoomSliderScreenState extends State<LoomSliderScreen> {
  final PageController _pageController = PageController();

  int _currentPage = 0;

  final List<String> _screenTitles = [
    'All',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.pageBg,

      body: SafeArea(
        child: Column(
          children: [



            // ================= BODY =================

            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),

                child: PageView(
                  controller: _pageController,

                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },

                  children: const [

                    // MAIN SCREEN

                    LoomForwardScreen(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}