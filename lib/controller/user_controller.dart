import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart' hide Response;
import 'package:networking_learning/constant/api_constant.dart';
import 'package:networking_learning/model/photo.dart';
import 'package:networking_learning/model/todo.dart';
import 'package:networking_learning/model/user.dart';
import 'package:networking_learning/service/api_client.dart';

class UserController extends GetxController {
  var isLoading = false.obs;

  var userList = <User>[].obs;
  var photosList = <Photo>[].obs;
  var todoList = <Todo>[].obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> fetchUser() async {
    try {
      isLoading(true);

      final Response response = await ApiClient.get(ApiConstant.userUrl);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;

        userList.value = jsonData.map((data) => User.fromJson(data)).toList();
        isLoading(false);
      }
    } on ApiException catch (e) {
      debugPrint(e.toString());
      isLoading(false);
    }
  }

  Future<void> fetchPost() async {
    try {
      isLoading(true);
      final Response response = await ApiClient.get(ApiConstant.photo);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;

        photosList.value = jsonData.map((e) => Photo.fromJson(e)).toList();
      }
    } on ApiException catch (e) {
      debugPrint(e.toString());
      isLoading(false);
    }
  }

  Future<void> fetchTodo() async {
    try {
      isLoading(true);
      final Response response = await ApiClient.get(ApiConstant.todo);
      if (response.statusCode == 200) {
        final List<dynamic> jsonData = response.data;

        todoList.value = jsonData.map((item) => Todo.fromJson(item)).toList();
        isLoading(false);
      }
    } on ApiException catch (e) {
      debugPrint(e.toString());
      isLoading(true);
    }
  }
}
