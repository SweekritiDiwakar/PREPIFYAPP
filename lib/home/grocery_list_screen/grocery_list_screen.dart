import 'package:flutter/material.dart';
import 'package:prepify/home/profile_screen/profile_screen.dart';
import 'package:prepify/home/profile_screen/edit_profile_screen.dart';

class GroceryListScreen extends StatefulWidget {
  const GroceryListScreen({super.key});

  @override
  State<GroceryListScreen> createState() => _GroceryListScreenState();
}

class _GroceryListScreenState extends State<GroceryListScreen> {
  final List<Map<String, dynamic>> _products = [
    {'name': 'Butter', 'checked': false},
    {'name': 'Chicken breast', 'checked': false},
    {'name': 'Vanilla', 'checked': false},
    {'name': 'Potatoes', 'checked': false},
    {'name': 'Milk', 'checked': false},
  ];

  final List<Map<String, dynamic>> _purchased = [
    {'name': 'Bananas', 'checked': true},
    {'name': 'Rice', 'checked': true},
    {'name': 'Salt', 'checked': true},
  ];

  final TextEditingController _newItemController = TextEditingController();

  void _addNewItem() {
    final String text = _newItemController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _products.add({'name': text, 'checked': false});
        _newItemController.clear();
      });
    }
  }

  @override
  void dispose() {
    _newItemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = _products.length + _purchased.length;
    int checkedItems = _purchased.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Top Bar: Avatar, Logo, Bell (SS 2 Style)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundImage: const AssetImage('assets/images/me.jpeg'),
                      backgroundColor: Colors.grey[200],
                    ),
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        height: 40,
                        width: 40,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'PREPIFY',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProfileScreen()),
                      );
                    },
                    child: const Icon(Icons.settings, size: 28, color: Colors.black),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              // Back Button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios, color: Colors.green, size: 20),
              ),

              const SizedBox(height: 20),

              // Title
              const Text(
                "Grocery List",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 20),

              // List Progress 
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "List Progress",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    "$checkedItems of $totalItems items",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: totalItems > 0 ? checkedItems / totalItems : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 12,
                ),
              ),

              const SizedBox(height: 25),

              // Inline Add Item Section (SS Style)
              Row(
                children: [
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                     decoration: BoxDecoration(
                       color: Colors.grey[100],
                       borderRadius: BorderRadius.circular(20),
                     ),
                     child: Text(
                       "${_products.length + 1}.",
                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                     ),
                   ),
                   const SizedBox(width: 10),
                   Expanded(
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16),
                       decoration: BoxDecoration(
                         color: Colors.grey[100],
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: TextField(
                         controller: _newItemController,
                         decoration: InputDecoration(
                           hintText: "e.g. 1 cup milk",
                           border: InputBorder.none,
                           hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                         ),
                         onSubmitted: (value) => _addNewItem(),
                       ),
                     ),
                   ),
                   const SizedBox(width: 10),
                   GestureDetector(
                     onTap: _addNewItem,
                     child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                       decoration: BoxDecoration(
                         color: Colors.green.withOpacity(0.1),
                         borderRadius: BorderRadius.circular(20),
                       ),
                       child: const Text(
                         "Add",
                         style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                       ),
                     ),
                   ),
                ],
              ),

              const SizedBox(height: 30),

              // Products Section 
              const Text(
                "Products",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildListContainer(_products, true),

              const SizedBox(height: 30),

              // Purchased Section
              const Text(
                "Purchased",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Serif',
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              _buildListContainer(_purchased, false),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListContainer(List<Map<String, dynamic>> items, bool isProductList) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = items[index];
          return ListTile(
            leading: Checkbox(
              value: item['checked'],
              onChanged: (val) {
                if (val == null) return;
                setState(() {
                  item['checked'] = val;
                  if (isProductList && val) {
                    // Move from products to purchased
                    _products.remove(item);
                    _purchased.add(item);
                  } else if (!isProductList && !val) {
                    // Move from purchased to products
                    _purchased.remove(item);
                    _products.add(item);
                  }
                });
              },
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
            title: Text(
              item['name'],
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: item['checked'] ? Colors.grey : Colors.black,
                decoration: item['checked'] ? TextDecoration.lineThrough : null,
              ),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
              onPressed: () {
                setState(() {
                  items.removeAt(index);
                });
              },
            ),
          );
        },
      ),
    );
  }
}
