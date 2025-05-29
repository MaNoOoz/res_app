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
  // قم بوضع MenuController هنا
  final ResMenuController menuController = Get.put(ResMenuController());

  @override
  Widget build(BuildContext context) {
    // استخدم Obx للاستماع للتغييرات في حالة الـ MenuController
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          menuController.fetchData();

        }
        ,
      )
        ,
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
        // ألوان أيقونات ونصوص AppBar
        foregroundColor: AppConfig.instance.themingSettings.textColorDark,
        actions: [
          // زر البحث (مثال بسيط يمكنك تطويره)
          IconButton(
            icon: Icon(Icons.search),
            color: AppConfig.instance.themingSettings.textColorDark,
            onPressed: () {
              Get.dialog(
                AlertDialog(
                  title: Text('البحث في القائمة'),
                  content: TextField(
                    // onChanged: menuController.updateSearchTerm,
                    decoration: InputDecoration(
                      hintText: 'ابحث عن طبق أو وصف...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        // menuController.updateSearchTerm(''); // مسح البحث عند الإغلاق
                        Get.back();
                      },
                      child: Text('إغلاق'),
                    ),
                  ],
                ),
              );
            },
          ),
          // يمكنك إضافة زر المفضلة هنا لاحقًا
          // IconButton(
          //   icon: Icon(Icons.favorite),
          //   onPressed: () {
          //     // الانتقال إلى شاشة المفضلة
          //   },
          // ),
        ],
      ),
      // لون خلفية الصفحة من الثيم
      backgroundColor: AppConfig.instance.themingSettings.backgroundColor,
      body: Obx(() {
        // عرض مؤشر التحميل
        if (menuController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
                color: AppConfig.instance.themingSettings.primaryColor),
          );
        }
        // عرض رسالة الخطأ في حالة وجودها
        else if (menuController.errorMessage.value != null) {
          return Center(
            child: Text(
              'خطأ: ${menuController.errorMessage.value}',
              style: TextStyle(color: Colors.red),
            ),
          );
        }
        // عرض المحتوى عند نجاح التحميل
        else {
          return Column(
            children: [
              // شريط الفئات (يمكن استخدام ListView.builder أفقيًا أو TabBar)
              Container(
                height: 60, // ارتفاع شريط الفئات
                color: AppConfig.instance.themingSettings.backgroundColor,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  // +1 لفئة "الكل" المضافة يدويًا
                  itemCount: menuController.categories.length + 1,
                  itemBuilder: (context, index) {
                    final isAll = index == 0;
                    final category = isAll
                        ? Category(
                        categoryId: 'all',
                        categoryName: 'الكل',
                        order: -1) // فئة "الكل"
                        : menuController.categories[index - 1]; // الفئات الفعلية

                    return Obx(() => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ChoiceChip(
                        label: Text(
                          category.categoryName,
                          style: TextStyle(
                            fontFamily: APP_FONT_FAMILY,
                            color: menuController.selectedCategory.value
                                ?.categoryId ==
                                category.categoryId
                                ? AppConfig
                                .instance.themingSettings.textColorDark
                                : AppConfig
                                .instance.themingSettings.textColorLight,
                          ),
                        ),
                        selected: menuController.selectedCategory.value
                            ?.categoryId ==
                            category.categoryId,
                        selectedColor:
                        AppConfig.instance.themingSettings.primaryColor,
                        backgroundColor: AppConfig
                            .instance.themingSettings.backgroundColor,
                        onSelected: (selected) {
                          if (selected) {
                            menuController.selectCategory(category);
                          }
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: AppConfig
                                .instance.themingSettings.primaryColor,
                            width: 1.0,
                          ),
                        ),
                      ),
                    ));
                  },
                ),
              ),
              // قائمة الأطباق المفلترة
              Expanded(
                child: menuController.filteredMenuItems.isEmpty
                    ? Center(
                  child: Text(
                    'لا توجد أطباق في هذه الفئة أو تطابق مع البحث.',
                    style: TextStyle(
                        color: AppConfig
                            .instance.themingSettings.textColorLight),
                  ),
                )
                    : ListView.builder(
                  itemCount: menuController.filteredMenuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuController.filteredMenuItems[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      color: AppConfig.instance.themingSettings
                          .backgroundColor, // لون خلفية البطاقة
                      elevation: 4.0, // ظل للبطاقة
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // الصورة (إذا كانت موجودة)
                            if (item.imageUrl != null &&
                                item.imageUrl!.isNotEmpty)
                              Padding(
                                padding:
                                const EdgeInsets.only(bottom: 10.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(
                                      10.0), // حواف دائرية للصورة
                                  child: Image.network(
                                    item.imageUrl!,
                                    height: 150, // ارتفاع ثابت للصورة
                                    width: double.infinity, // عرض كامل
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child,
                                        loadingProgress) {
                                      if (loadingProgress == null)
                                        return child;
                                      return Center(
                                        child: SizedBox(
                                          height: 150,
                                          child: CircularProgressIndicator(
                                            value: loadingProgress
                                                .expectedTotalBytes !=
                                                null
                                                ? loadingProgress
                                                .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                                : null,
                                            color: AppConfig.instance
                                                .themingSettings
                                                .accentColor,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error,
                                        stackTrace) {
                                      return Container(
                                        height: 150,
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: Icon(
                                              Icons.broken_image,
                                              color: Colors.grey),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            // اسم الطبق
                            Text(
                              item.itemName,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppConfig.instance.themingSettings
                                    .textColorLight,
                              ),
                            ),
                            SizedBox(height: 8),
                            // وصف الطبق
                            Text(
                              item.description,
                              style: TextStyle(
                                fontSize: 16,
                                color: AppConfig.instance.themingSettings
                                    .textColorLight
                                    .withOpacity(0.8),
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 12),
                            // السعر والفئة (في صف واحد)
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${item.price.toStringAsFixed(2)} ريال',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppConfig.instance
                                        .themingSettings.accentColor,
                                  ),
                                ),
                                Text(
                                  item.category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                    color: AppConfig.instance
                                        .themingSettings.textColorLight
                                        .withOpacity(0.7),
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