import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ImageListScreen(),
    );
  }
}

class ImageListScreen extends StatelessWidget {
  final List<String> imagePaths = [
    'assets/images/umar1.jpg',
    'assets/images/umar2.png',
    'assets/images/umer3.png',
    'assets/images/umar1.jpg',
    'https://picsum.photos/200/300',
    'https://picsum.photos/201/300',
    'https://picsum.photos/202/300',
    'https://picsum.photos/203/300',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Vertical Image List")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: imagePaths.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  elevation: 5,
                  child: ImageWidget(
                    imagePath: imagePaths[index],
                    width: double.infinity,
                    height: 200,
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          ImageHorizontalScreen(imagePaths: imagePaths),
                ),
              );
            },
            child: Text("Go to Horizontal Images"),
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}

class ImageHorizontalScreen extends StatelessWidget {
  final List<String> imagePaths;
  ImageHorizontalScreen({required this.imagePaths});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Horizontal Image List")),
      body: Container(
        height: 200, // Fixed height for horizontal scrolling
        child: ListView.builder(
          scrollDirection: Axis.horizontal, // Enables horizontal scrolling
          itemCount: imagePaths.length,
          itemBuilder: (context, index) {
            return Card(
              margin: EdgeInsets.all(10),
              elevation: 5,
              child: ImageWidget(
                imagePath: imagePaths[index],
                width: 150,
                height: 150,
              ),
            );
          },
        ),
      ),
    );
  }
}

// A reusable widget for displaying images
class ImageWidget extends StatelessWidget {
  final String imagePath;
  final double width;
  final double height;

  ImageWidget({
    required this.imagePath,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    bool isAsset = imagePath.startsWith('assets');

    return isAsset
        ? Image.asset(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
        )
        : Image.network(
          imagePath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(child: CircularProgressIndicator());
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(child: Text("Failed to load image"));
          },
        );
  }
}
