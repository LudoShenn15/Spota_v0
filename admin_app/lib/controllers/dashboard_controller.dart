import 'package:get/get.dart';

class DashboardController extends GetxController {
  final RxInt courseCount = 12.obs;
  final RxInt coachCount = 5.obs;
  final RxInt memberCount = 84.obs;

  Future<void> fetchStats() async {
    // Ici nous simulons un appel API
    await Future.delayed(const Duration(seconds: 1));
    courseCount.value = 15;
    coachCount.value = 6;
    memberCount.value = 92;
    update();
  }
}