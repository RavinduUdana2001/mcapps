class QuickAccessItem {
  final String name;
  final String icon;
  final String url;

  QuickAccessItem({required this.name, required this.icon, required this.url});

  Map<String, String> toMap() {
    return {'name': name, 'icon': icon, 'url': url};
  }

  factory QuickAccessItem.fromMap(Map<String, String> map) {
    return QuickAccessItem(
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      url: map['url'] ?? '',
    );
  }
}
