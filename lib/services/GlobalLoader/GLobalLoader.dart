import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Controller
class LoaderController extends GetxController {
  var isLoading = false.obs;

  void show() {
    isLoading.value = true;
  }

  void hide() {
    isLoading.value = false;
  }
}

/// Global Loader Widget
class GlobalLoaderWidget extends StatelessWidget {
  const GlobalLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final loader = Get.find<LoaderController>();

    return Obx(() {
      if (!loader.isLoading.value) {
        return const SizedBox.shrink();
      }

      return Container(
        color: Colors.black.withOpacity(0.4),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }
}