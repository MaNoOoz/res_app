// نموذج لـ Menu Item (مطابق لهيكل JSON الذي يرجع من Google Sheet)
class MenuItem {
  final String itemId;
  final String category;
  final String itemName;
  final String description;
  final double price;
  final String? imageUrl; // يمكن أن تكون null
  final String? qrCodeData; // يمكن أن تكون null
  final bool availability;

  MenuItem({
    required this.itemId,
    required this.category,
    required this.itemName,
    required this.description,
    required this.price,
    this.imageUrl,
    this.qrCodeData,
    required this.availability,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemId: json['item_id'] ?? '',
      category: json['category'] ?? '',
      itemName: json['item_name'] ?? '',
      description: json['description'] ?? '',
      // تأكد أن السعر يتم تحويله بشكل صحيح (قد يكون int أو double)
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'],
      qrCodeData: json['qr_code_data'],
      availability: json['availability'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item_id': itemId,
      'category': category,
      'item_name': itemName,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'qr_code_data': qrCodeData,
      'availability': availability,
    };
  }
}

// نموذج لـ Category
class Category {
  final String categoryId;
  final String categoryName;
  final int order; // لترتيب عرض الفئات

  Category({
    required this.categoryId,
    required this.categoryName,
    required this.order,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      categoryId: json['category_id'] ?? '',
      categoryName: json['category_name'] ?? '',
      order: json['order'] ?? 0,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      'category_name': categoryName,
      'order': order,
    };
  }
}

