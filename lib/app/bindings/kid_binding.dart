import 'package:get/get.dart';
import '../controllers/kid_controller.dart';

class KidBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KidController>(() => KidController());
  }
}
