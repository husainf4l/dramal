import 'package:get/get.dart';
import '../controllers/vaccine_controller.dart';

class VaccineBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VaccineController>(() => VaccineController());
  }
}
