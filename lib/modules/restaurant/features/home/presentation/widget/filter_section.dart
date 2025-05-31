import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../category/presentation/pages/dishes_by_category_page.dart';

class FilterItem {
  final String label;
  final String imageUrl;

  FilterItem({required this.label, required this.imageUrl});
}

class FilterSection extends StatefulWidget {
  @override
  _FilterSectionState createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  int? _selectedIndex;

  final List<FilterItem> filters = [
    FilterItem(
        label: "Europe",
        imageUrl:
            "http://api-restaurant.toptelsig.com/uploads/section/europeen.svg"),
    FilterItem(
        label: "Ivoirien",
        imageUrl:
            "http://api-restaurant.toptelsig.com/uploads/section/ivoire.svg"),
    FilterItem(
        label: "Pizza",
        imageUrl:
            "http://api-restaurant.toptelsig.com/uploads/section/pizza.svg"),
    FilterItem(
        label: "Afrique",
        imageUrl:
            "http://api-restaurant.toptelsig.com/uploads/section/europeen.svg"),
    FilterItem(
        label: "Hamburger",
        imageUrl:
            "http://api-restaurant.toptelsig.com/uploads/section/europeen.svg"),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(filters.length, (index) {
          bool isSelected = _selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => DishesByCategoryPage(
                        categoryName: filters[index].label),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(
                    color: isSelected ? Colors.orange : Colors.grey[300]!,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    // Image ou icône
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: SvgPicture.network(
                        filters[index].imageUrl,
                        width: 30,
                        height: 30,
                        fit: BoxFit.cover,
                        placeholderBuilder: (context) => Icon(
                          Icons.error,
                          size: 24,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    // Texte
                    Text(
                      filters[index].label,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
