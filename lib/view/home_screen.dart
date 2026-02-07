import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:networking_learning/controller/user_controller.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.put(UserController());
    return Scaffold(
      body: Obx(
        () => ListView.separated(
          itemCount: userController.userList.length,
          itemBuilder: (context, index) => ListTile(
            title: Text(userController.userList[index].name.toString()),
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      ),
    );
  }
}
