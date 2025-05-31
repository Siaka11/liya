import 'package:flutter/material.dart';
import 'package:liya/core/ui/theme/theme.dart';

class DishCard extends StatelessWidget {
  final String name;
  final String price;
  final String imageUrl;
  final String description;
  final VoidCallback onTap;
  final VoidCallback? onDelete;
  final int quantity;

  const DishCard({
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
    required this.onTap,
    this.onDelete,
    this.quantity = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[50],
      elevation: 0,
      margin: EdgeInsets.only(bottom: 4, top: 2),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: InkWell(
              onTap: onTap,
              child: Stack(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Icon(Icons.error, size: 100),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 180,
                              child: Text(
                                name,
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 4),
                            SizedBox(
                              width: 180,
                              child: Text(
                                description,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey[700]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: quantity > 0
                                        ? UIColors.orange.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        quantity > 0 ? '$quantity.X' : '',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: UIColors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (quantity > 0 && onDelete != null) ...[
                                        SizedBox(width: 4),
                                        GestureDetector(
                                          onTap: onDelete,
                                          child: Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                            size: 16,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$price CFA',
                            style: TextStyle(
                              fontSize: 16,
                              color: UIColors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      backgroundColor: UIColors.orange,
                      radius: 12,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: Icon(Icons.add, color: Colors.white, size: 10),
                        onPressed: onTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          /*Divider(
            height: 1,
            thickness: 1,
            color: Colors.grey[200],
          ),*/
        ],
      ),
    );
  }
}
