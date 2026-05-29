// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'GLobalLoader.dart';
//
//
// class GlobalLoaderWidget extends StatelessWidget {
//   const GlobalLoaderWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final controller = Get.find<GlobalLoader>();
//
//     return Obx(() {
//       if (!controller.isLoading.value) return const SizedBox();
//
//       return Container(
//         color: Colors.black.withOpacity(0.3),
//         child: const Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     });
//   }
// }