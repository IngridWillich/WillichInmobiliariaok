import 'package:flutter/material.dart' hide SearchBar;
import 'package:flutter_web/components/footer.dart';
import 'package:flutter_web/components/searchbar.dart';
import 'package:flutter_web/screens/property/propdetail.dart';
import '../../components/carousel.dart';
import '../../components/card.dart';
import "../../components/navbar.dart";
import '../../services/property_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<dynamic>> _propertiesFuture;
  final List<String> carouselImages = const [
    "assets/tercera.jpeg",
    "assets/lindas.jpeg",
    "assets/tambien.jpeg",
    "assets/carr 3.jpg",
    "assets/jsjs.jpeg",
    "assets/carr 7.jpg",
    "assets/carr 8.jpeg",
  ];

  @override
  void initState() {
    super.initState();
    _propertiesFuture = PropertyService.fetchProperties();
  }

  void handleCardClick(BuildContext context, int id, List<dynamic> properties) {
    final property = properties.firstWhere(
      (p) => p['id'] == id,
      orElse: () => {},
    );
    
    if (property.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyDetailsPage(property: property),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontraron detalles de la propiedad')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 1;
    double childAspectRatio = 0.85;

    if (screenWidth > 1200) {
      crossAxisCount = 3;
      childAspectRatio = 0.80;
    } else if (screenWidth > 800) {
      crossAxisCount = 2;
      childAspectRatio = 0.78;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 0.90; 
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: Navbar(),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppBar().preferredSize.height + 0),
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.65,
              child: Carousel(images: carouselImages),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth < 600
                    ? 12
                    : screenWidth < 1200
                        ? 24
                        : 0,
              ),
              child: PropertySearchWidget(),
            ),
            const SizedBox(height: 30),
            const Padding(
              padding: EdgeInsets.only(top: 2.0),
              child: Text(
                "Descubre propiedades únicas y encuentra el hogar de tus sueños con nuestra selección exclusiva...",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 84, 84, 84),
                ),
                textAlign: TextAlign.center,
              ),
            ),

            FutureBuilder<List<dynamic>>(
              future: _propertiesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text('Error al cargar propiedades: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Text(
                      "No hay propiedades disponibles",
                      style: TextStyle(color: Colors.black54),
                    ),
                  );
                }

                final properties = snapshot.data!;

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: const EdgeInsets.only(top: 10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: childAspectRatio,
                        ),
                        itemCount: properties.length,
                        itemBuilder: (context, index) {
                          final property = properties[index];
                          final mainImage = property['imageSrc'] != null && 
                                          property['imageSrc'].isNotEmpty
                              ? property['imageSrc'][0]
                              : 'assets/default_property.jpg';
                          return PropertyCard(
                            key: ValueKey(property['id']),
                            imageSrc: mainImage,
                            title: property['title'],
                            tipo: property["tipo"],
                            price: property['price'].toString(),
                            location: property['location'] ?? 'Sin ubicación',
                            bedrooms: property['bedrooms'] ?? 0,
                            bathrooms: property['bathrooms'] ?? 0,
                            area: property['area'] ?? 0,
                            description: property['description'],
                            buttonText: "Ver detalles",
                            onButtonClick: () =>
                                handleCardClick(context, property['id'], properties),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
            
          
            const Footer(),
          ],
        ),
      ),
    );
  }
}