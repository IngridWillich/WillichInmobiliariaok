
import 'package:flutter/material.dart';
import 'package:flutter_web/components/footer.dart';
import "providers/app_context.dart";
import 'components/navbar.dart';

class RootLayout extends StatelessWidget {
  final Widget child;

  const RootLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return AppProvider(
      child: Scaffold(
        appBar: const Navbar(),
        body: Stack(
          children: [
           
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 300), // Espacio para el footer
                  child: child,
                ),
              ),
            ),
            
           
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: const Footer(),
            ),
          ],
        ),
      ),
    );
  }
}