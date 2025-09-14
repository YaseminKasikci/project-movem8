class CategoryModel {
  final int id;
  final String categoryName;
  final String? icon;

  CategoryModel({required this.id, required this.categoryName, this.icon});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      categoryName: json['categoryName'],
      icon: json['icon'],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "categoryName": categoryName,
        "icon": icon,
      };
}
