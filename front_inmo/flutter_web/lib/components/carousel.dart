
import 'package:flutter/material.dart';

class Carousel extends StatefulWidget {
  final List<String> images;

  const Carousel({super.key, required this.images});

  @override
  CarouselState createState() => CarouselState();
}

class CarouselState extends State<Carousel> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    _autoScroll();
  }

  void _autoScroll() {
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.images.length;
          _pageController.animateToPage(
            _currentIndex,
            duration: const Duration(milliseconds: 1500), // ⏳ Transición más lenta
            curve: Curves.easeInOut,
          );
        });
        _autoScroll();
      }
    });
  }

  void _goToSlide(int index) {
    setState(() {
      _currentIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 1000),
        curve: Curves.easeInOut,
      );
    });
  }

  void _nextSlide() {
    _goToSlide((_currentIndex + 1) % widget.images.length);
  }

  void _previousSlide() {
    _goToSlide((_currentIndex - 1 + widget.images.length) % widget.images.length);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8, 
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.images.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return Image.asset(
                widget.images[index],
                fit: BoxFit.cover, 
                width: double.infinity,
                height: double.infinity,
              );
            },
          ),
        ),
        Positioned(
          bottom: 10, 
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.images.length, (index) {
              return GestureDetector(
                onTap: () => _goToSlide(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: _currentIndex == index ? 12 : 8,
                  height: _currentIndex == index ? 12 : 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index ? Colors.white : Colors.grey[400],
                  ),
                ),
              );
            }),
          ),
        ),
        Positioned(
          left: 10,
          top: MediaQuery.of(context).size.height * 0.3 - 20, // 🔥 Centra flechas verticalmente
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _previousSlide,
          ),
        ),
        Positioned(
          right: 10,
          top: MediaQuery.of(context).size.height * 0.3 - 20, // 🔥 Centra flechas verticalmente
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: _nextSlide,
          ),
        ),
      ],
    );
  }
}
