import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart'; // Cached image loading
import 'dart:convert';
import 'dart:async';

class SliderPage extends StatefulWidget {
  const SliderPage({super.key});

  @override
  _SliderPageState createState() => _SliderPageState();
}

class _SliderPageState extends State<SliderPage> {
  List<dynamic> posts = [];
  late PageController _pageController;
  int currentPage = 0;
  Timer? autoSlideTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: currentPage);
    fetchPosts();
    startAutoSlide();
  }

  @override
  void dispose() {
    autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  // Function to fetch posts from the PHP API
  Future<void> fetchPosts() async {
    try {
      final response = await http
          .get(Uri.parse('https://test.mchostlk.com/api_get_posts.php'));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          posts = data;
        });
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  // Function to start auto-sliding the images
  void startAutoSlide() {
    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.hasClients && posts.isNotEmpty) {
        setState(() {
          currentPage = (currentPage + 1) % posts.length;
        });
        _pageController.animateToPage(
          currentPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Latest News')),
      body: posts.isEmpty
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator if posts are not fetched
          : Column(
              children: [
                const SizedBox(height: 10),
                SizedBox(
                  height: 300, // Set fixed height for the slider
                  width: MediaQuery.of(context).size.width *
                      0.9, // 90% of the screen width
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: posts.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Stack(
                            children: [
                              CachedNetworkImage(
                                imageUrl: post['image_path'],
                                fit: BoxFit.cover,
                                height: double.infinity,
                                width: double.infinity,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Container(
                                  color: Colors.black.withOpacity(0.5),
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    post['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
