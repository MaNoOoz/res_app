import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/menu_controller.dart';
import '../core/app_core.dart';
import '../core/models.dart';
import '../utils/Constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ResMenuController menuController = Get.put(ResMenuController());
  bool _configLoaded = false;
  bool _configError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  Future<void> _loadConfig() async {
    try {
        await AppConfig.instance.loadConfig();

      setState(() => _configLoaded = true);
    } catch (e) {
      setState(() {
        _configError = true;
        _errorMessage = e.toString();
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    // // Show loading indicator while configuration is loading
    // if (!_configLoaded) {
    //   return Scaffold(
    //     backgroundColor: Colors.grey[200],
    //     body: Center(
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         children: [
    //           const CircularProgressIndicator(),
    //           const SizedBox(height: 20),
    //           Text(
    //             'جاري تحميل التكوين...',
    //             style: TextStyle(
    //               fontSize: 18,
    //               color: Colors.grey[700],
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //   );
    // }
    //
    // // Show error if configuration failed
    // if (_configError) {
    //   return Scaffold(
    //     backgroundColor: Colors.grey[200],
    //     body: Center(
    //       child: Padding(
    //         padding: const EdgeInsets.all(20.0),
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             const Icon(Icons.error_outline, size: 50, color: Colors.red),
    //             const SizedBox(height: 20),
    //             Text(
    //               'خطأ في التكوين',
    //               style: TextStyle(
    //                 fontSize: 24,
    //                 fontWeight: FontWeight.bold,
    //                 color: Colors.grey[800],
    //               ),
    //             ),
    //             const SizedBox(height: 10),
    //             Text(
    //               _errorMessage ?? 'حدث خطأ غير معروف',
    //               textAlign: TextAlign.center,
    //               style: TextStyle(
    //                 fontSize: 18,
    //                 color: Colors.grey[700],
    //               ),
    //             ),
    //             const SizedBox(height: 20),
    //             ElevatedButton(
    //               onPressed: _loadConfig,
    //               child: const Text('إعادة المحاولة'),
    //             ),
    //           ],
    //         ),
    //       ),
    //     ),
    //   );
    // }

    // Main content once configuration is loaded
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: menuController.fetchData,
        child: const Icon(Icons.refresh),

      ),
      appBar: AppBar(
        title: Obx(() => menuController.selectedCategory.value != null
            ? Text(
          menuController.selectedCategory.value!.categoryId == 'all'
              ? AppConfig.instance.clientSettings.cafeRestaurantName
              : menuController.selectedCategory.value!.categoryName,
          style: TextStyle(
            color: AppConfig.instance.themingSettings.textColorDark,
          ),
        )
            : Text(
          AppConfig.instance.clientSettings.cafeRestaurantName,
          style: TextStyle(
            color: AppConfig.instance.themingSettings.textColorDark,
          ),
        )),
        backgroundColor: AppConfig.instance.themingSettings.primaryColor,
        foregroundColor: AppConfig.instance.themingSettings.textColorDark,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: AppConfig.instance.themingSettings.textColorDark,
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: const Text('البحث في القائمة'),
                  content: TextField(
                    decoration: const InputDecoration(
                      hintText: 'ابحث عن طبق أو وصف...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: AppConfig.instance.themingSettings.backgroundColor,
      body: Obx(() {
        if (menuController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
                color: AppConfig.instance.themingSettings.primaryColor
            ),
          );
        }
        else if (menuController.errorMessage.value != null) {
          return Center(
            child: Text(
              'خطأ: ${menuController.errorMessage.value}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        else {
          return Column(
            children: [
              // Categories bar
              Container(
                height: 60,
                color: AppConfig.instance.themingSettings.backgroundColor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: menuController.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll
                        ?  Category(
                        categoryId: 'all',
                        categoryName: 'الكل',
                        order: -1)
                        : menuController.categories[index - 1];

                    return Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          category.categoryName,
                          style: TextStyle(
                            fontFamily: APP_FONT_FAMILY,
                            color: menuController.selectedCategory.value?.categoryId == category.categoryId
                                ? AppConfig.instance.themingSettings.textColorDark
                                : AppConfig.instance.themingSettings.textColorLight,
                          ),
                        ),
                        selected: menuController.selectedCategory.value?.categoryId == category.categoryId,
                        selectedColor: AppConfig.instance.themingSettings.primaryColor,
                        backgroundColor: AppConfig.instance.themingSettings.backgroundColor,
                        onSelected: (selected) {
                          if (selected) menuController.selectCategory(category);
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppConfig.instance.themingSettings.primaryColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ));
                  },
                ),
              ),
              // Menu items list
              Expanded(
                child: menuController.filteredMenuItems.isEmpty
                    ? Center(
                  child: Text(
                    'لا توجد أطباق في هذه الفئة أو تطابق مع البحث.',
                    style: TextStyle(
                        color: AppConfig.instance.themingSettings.textColorLight
                    ),
                  ),
                )
                    : ListView.builder(
                  itemCount: menuController.filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuController.filteredMenuItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      color: AppConfig.instance.themingSettings.backgroundColor,
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.imageUrl != null && item.imageUrl!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10.0),
                                  child: Image.network(
                                    item.imageUrl!,
                                    height: 150,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return SizedBox(
                                        height: 150,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: AppConfig.instance.themingSettings.accentColor,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: Icon(Icons.broken_image, color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConfig.instance.themingSettings.textColorLight,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppConfig.instance.themingSettings.textColorLight.withOpacity(0.8),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.price.toStringAsFixed(2)} ريال',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppConfig.instance.themingSettings.accentColor,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: AppConfig.instance.themingSettings.textColorLight.withOpacity(0.7),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        }
      }),
    );
  }
}