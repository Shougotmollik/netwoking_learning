import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:networking_learning/constant/api_constant.dart';
import 'package:networking_learning/model/user.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

class UserController extends GetxController {
  var isLoading = false.obs;

  var userList = <User>[].obs;

  final _dio = Dio()
    ..interceptors.add(
      PrettyDioLogger(
        request: true,
        error: true,
        responseBody: true,
        responseHeader: true,
      ),
    );

  @override
  void onInit() {
    super.onInit();
    fetchUser();
  }

  Future<void> fetchUser() async {
    isLoading(true);

    try {
      Response response = await _dio.get(
        ApiConstant.userUrl,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (response.statusCode == 200) {
        var json = response.data;
        userList.value = (json as List).map((e) => User.fromJson(e)).toList();
        isLoading(false);
      }
    } catch (e) {
      isLoading(false);
      print(e);
    }
  }
}
