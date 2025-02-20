import 'package:flutter/material.dart';
import 'package:dh/Food/food_menu_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foodie App',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const FoodServiceOption(),
    );
  }
}

class FoodServiceOption extends StatefulWidget {
  const FoodServiceOption({super.key});

  @override
  _FoodServiceOptionState createState() => _FoodServiceOptionState();
}

class _FoodServiceOptionState extends State<FoodServiceOption> {
  String _selectedOption = 'Dining In';

  void _selectOption(String option, {bool navigate = false}) {
    setState(() {
      _selectedOption = option;
    });

    if (navigate) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FoodMenuPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen[400],
        title: const Text(
          'Food Court',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              Colors.white60,
            ], // Light Green to Dark Green
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Apply color to "Choose Your Option"
            const Text(
              'Choose Your Option :',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Change the color here
              ),
            ),

            const SizedBox(height: 8),

            // Apply color to the welcome message
            const Text(
              "Welcome to Food Court! Whether you're dining in, ordering for "
                  "home delivery, or planning a bulk order for an event, we've got you covered.",
              textAlign: TextAlign.justify,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Change the color here
              ),
            ),
            const SizedBox(height: 40),
            _buildOptionButton(
                'Dining In',
                Icons.restaurant,
                _selectedOption == 'Dining In',
                () => _selectOption('Dining In')),
            const SizedBox(height: 20),
            _buildOptionButton(
                'Doorstep Delivery',
                Icons.delivery_dining,
                _selectedOption == 'Doorstep Delivery',
                () => _selectOption('Doorstep Delivery', navigate: true)),
            const SizedBox(height: 20),
            _buildOptionButton(
                'Bulk Orders',
                Icons.shopping_cart,
                _selectedOption == 'Bulk Orders',
                () => _selectOption('Bulk Orders')),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton(
      String label, IconData icon, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  colors: [Colors.lightGreen[300]!, Colors.green[500]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight)
              : LinearGradient(
                  colors: [Colors.white, Colors.grey[300]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
                color: isSelected ? Colors.black26 : Colors.black12,
                offset: const Offset(0, 4),
                blurRadius: 8)
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          splashColor: Colors.greenAccent[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.white : Colors.black54),
              const SizedBox(width: 10),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}

// Extracted text styles for cleaner code
const TextStyle _headerTextStyle =
    TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white);
const TextStyle _subHeaderTextStyle =
    TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white70);
