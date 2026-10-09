import 'package:flutter/material.dart';

/// Built-in icons a user can pick for a category. Stored in Firestore by key.
const Map<String, IconData> kBuiltInCategoryIcons = {
  'restaurant': Icons.restaurant,
  'coffee': Icons.local_cafe,
  'groceries': Icons.local_grocery_store,
  'cart': Icons.shopping_cart,
  'bag': Icons.shopping_bag,
  'transport': Icons.directions_bus,
  'car': Icons.directions_car,
  'bike': Icons.two_wheeler,
  'flight': Icons.flight,
  'hotel': Icons.hotel,
  'home': Icons.home,
  'bolt': Icons.bolt,
  'water': Icons.water_drop,
  'wifi': Icons.wifi,
  'phone': Icons.phone_android,
  'health': Icons.medical_services,
  'fitness': Icons.fitness_center,
  'school': Icons.school,
  'book': Icons.menu_book,
  'movie': Icons.movie,
  'music': Icons.music_note,
  'game': Icons.sports_esports,
  'gift': Icons.card_giftcard,
  'party': Icons.celebration,
  'beauty': Icons.spa,
  'clothes': Icons.checkroom,
  'work': Icons.work,
  'salary': Icons.payments,
  'wallet': Icons.account_balance_wallet,
  'bank': Icons.account_balance,
  'savings': Icons.savings,
  'invest': Icons.trending_up,
  'insurance': Icons.shield,
  'tax': Icons.receipt_long,
  'child': Icons.child_care,
  'tools': Icons.build,
  'travel_bag': Icons.luggage,
  'donation': Icons.volunteer_activism,
  'other': Icons.category,
};

/// Icons that ship as PNG files in your /assets folder (the original ones).
const List<String> kLegacyAssetIcons = [
  'credit_card',
  'electricity',
  'emi',
  'fees',
  'food',
  'fuel',
  'pet',
  'rentals',
  'shopping',
  'travel',
];

/// Picks black or white so an icon stays readable on [background].
Color onColor(Color background) =>
    ThemeData.estimateBrightnessForColor(background) == Brightness.dark
        ? Colors.white
        : Colors.black87;

/// Renders a category icon at a fixed size, whatever the source:
/// a built-in Material icon, a legacy PNG asset, or a fallback when the icon
/// is empty / the asset is missing (this is what removes the
/// "Unable to load asset: assets/.png" box and the oversized images).
class CategoryIcon extends StatelessWidget {
  final String icon;
  final Color color;
  final double size;

  const CategoryIcon({
    super.key,
    required this.icon,
    required this.color,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final builtIn = kBuiltInCategoryIcons[icon];
    if (builtIn != null) {
      return Icon(builtIn, color: color, size: size);
    }
    if (icon.isNotEmpty) {
      return Image.asset(
        'assets/$icon.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: color,
        errorBuilder: (_, __, ___) =>
            Icon(Icons.category, color: color, size: size),
      );
    }
    return Icon(Icons.category, color: color, size: size);
  }
}

/// A coloured circle with the category icon centred inside it.
class CategoryAvatar extends StatelessWidget {
  final String icon;
  final int colorValue;
  final double radius;

  const CategoryAvatar({
    super.key,
    required this.icon,
    required this.colorValue,
    this.radius = 24,
  });

  @override
  Widget build(BuildContext context) {
    final bg = Color(colorValue);
    return CircleAvatar(
      radius: radius,
      backgroundColor: bg,
      child: CategoryIcon(
        icon: icon,
        color: onColor(bg),
        size: radius,
      ),
    );
  }
}
