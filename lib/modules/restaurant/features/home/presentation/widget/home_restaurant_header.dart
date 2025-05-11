import 'package:flutter/material.dart';

class HomeRestaurantHeader extends StatelessWidget {
  const HomeRestaurantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: Colors.black),
              SizedBox(width: 8),
              Text(
                "Yamoussoukro, Maison des députés",
                style: TextStyle(fontSize: 10, color: Colors.black),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.shopping_cart, color: Colors.black),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.favorite_border, color: Colors.black),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}