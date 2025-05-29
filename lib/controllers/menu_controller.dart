import 'package:get/get.dart';
import '../core/models.dart';
import '../data/sources/remote/api_service.dart';

class ResMenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var menuItems = <MenuItem>[].obs;
  var categories = <Category>[].obs;
  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);
  var selectedCategory = Rx<Category?>(null); // الفئة المختارة

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      isLoading(true);
      errorMessage(null);

      // جلب الفئات أولاً
      final fetchedCategories = await _apiService.fetchCategories();
      // فرز الفئات حسب 'order'
      fetchedCategories.sort((a, b) => a.order.compareTo(b.order));
      categories.assignAll(fetchedCategories);

      // جلب الأطباق
      final fetchedMenuItems = await _apiService.fetchMenuItems();
      menuItems.assignAll(fetchedMenuItems);

      // تعيين الفئة "الكل" كفئة مختارة افتراضية، أو أول فئة
      if (categories.isNotEmpty) {
        // يمكنك إضافة فئة "الكل" يدوياً إذا أردت
        selectedCategory(Category(categoryId: 'all', categoryName: 'الكل', order: -1));
        // أو selectedCategory(categories.first);
      }

    } catch (e) {
      errorMessage(e.toString());
      Get.log('Error in MenuController: $e');
    } finally {
      isLoading(false);
    }
  }

  // دالة لتصفية الأطباق حسب الفئة المختارة
  List<MenuItem> get filteredMenuItems {
    if (selectedCategory.value == null || selectedCategory.value!.categoryId == 'all') {
      return menuItems;
    } else {
      return menuItems.where((item) => item.category == selectedCategory.value!.categoryName).toList();
    }
  }

  void selectCategory(Category? category) {
    selectedCategory(category);
  }
}