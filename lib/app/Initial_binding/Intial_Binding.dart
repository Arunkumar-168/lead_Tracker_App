import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tracker_app/features/leads/Controller/Lead_List_Controller.dart';

class InitialBinding extends Bindings {
  onInit() {
    initControllers();
  }

  @override
  void dependencies() async {
    Get.put(LeadListController());
  }
}

Future<void> initControllers() async {
  final sharedPreferences = await SharedPreferences.getInstance();
  Get.put(sharedPreferences);
  Get.put(LeadListController());
}
