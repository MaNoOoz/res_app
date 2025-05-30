import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../core/app_core.dart';
import '../core/models.dart';
import '../data/sources/remote/api_service.dart';

class ResMenuController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();

  var menuItems = <MenuItem>[].obs;
  var categories = <Category>[].obs;
  var isLoading = true.obs;
  var errorMessage = Rx<String?>(null);
  var selectedCategory = Rx<Category?>(null);

  @override
  void onInit() {
    super.onInit();
    _ensureConfigLoaded();
  }

  Future<void> _ensureConfigLoaded() async {
    try {
      isLoading(true);
      errorMessage(null);

      // Wait for configuration to initialize
      await AppConfig.instance.loadConfig();
      await fetchData();
    } catch (e) {
      Logger().e('Configuration failed: ${e.toString()}');
      errorMessage('Configuration failed: ${e.toString()}');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchData() async {
    try {
      Logger().d('Starting to fetch data...');

      // Fetch categories first
      final fetchedCategories = await _apiService.fetchCategories();
      Logger().d('Fetched categories: ${fetchedCategories.length}');

      // Sort categories by order
      fetchedCategories.sort((a, b) => a.order.compareTo(b.order));

      // Add "All" category at the beginning
      final allCategory = Category(
        categoryId: 'all',
        categoryName: 'الكل',
        order: -1,
        // Add other required fields with default values
      );

      categories.assignAll([allCategory, ...fetchedCategories]);

      // Fetch menu items
      final fetchedMenuItems = await _apiService.fetchMenuItems();
      Logger().d('Fetched menu items: ${fetchedMenuItems.length}');
      menuItems.assignAll(fetchedMenuItems);

      // Set default selected category to "All"
      if (categories.isNotEmpty) {
        selectedCategory(categories.first); // This will be the "All" category
      }

      Logger().d('Data fetch completed successfully');

    } catch (e) {
      Logger().e('Error in fetchData: $e');
      errorMessage('Failed to load data: ${e.toString()}');
      rethrow;
    }
  }

  // Filter menu items based on selected category
  List<MenuItem> get filteredMenuItems {
    if (selectedCategory.value == null || selectedCategory.value!.categoryId == 'all') {
      Logger().d('Showing all menu items: ${menuItems.length}');
      return menuItems;
    } else {
      final filtered = menuItems.where((item) =>
      item.category == selectedCategory.value!.categoryName
      ).toList();
      Logger().d('Filtered items for category ${selectedCategory.value!.categoryName}: ${filtered.length}');
      return filtered;
    }
  }

  void selectCategory(Category? category) {
    Logger().d('Selected category: ${category?.categoryName}');
    selectedCategory(category);
  }

  // Refresh data
  Future<void> refreshData() async {
    await fetchData();
  }

  // Get category by ID
  Category? getCategoryById(String categoryId) {
    try {
      return categories.firstWhere((cat) => cat.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }

  // Get items count for a specific category
  int getItemsCountForCategory(String categoryId) {
    if (categoryId == 'all') {
      return menuItems.length;
    }
    final category = getCategoryById(categoryId);
    if (category == null) return 0;

    return menuItems.where((item) => item.category == category.categoryName).length;
  }
}