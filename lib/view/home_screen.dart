import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:networking_learning/controller/user_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());
    return Scaffold(
      body: Obx(
        () => ListView.separated(
          itemCount: userController.userList.length,

          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) => Skeletonizer(
            enabled: userController.isLoading.value,
            child: Column(
              children: [
                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
