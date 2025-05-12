
import 'package:flutter/material.dart';
import 'package:flutter_web/screens/property/propdetail.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/card.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart'; 
import '../../services/property_service.dart';

class AlquilerPage extends StatefulWidget {
  const AlquilerPage({super.key});

  @override
  State<AlquilerPage> createState() => _AlquilerPageState();
}

class _AlquilerPageState extends State<AlquilerPage> {
  late Future<List<dynamic>> _alquileresFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _alquileresFuture = _fetchAlquileres();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> _fetchAlquileres() async {
    final allProperties = await PropertyService.fetchProperties();
    return allProperties
        .where((prop) =>
            prop['tipo']?.toString().toLowerCase().trim() == 'alquiler')
        .toList();
  }

  void handleCardClick(BuildContext context, int id, List<dynamic> properties) {
    final property = properties.firstWhere((p) => p['id'] == id, orElse: () => {});
    if (property.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PropertyDetailsPage(property: property),
        ),
      );
    }
  }
  
  Future<void> _launchWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/5493434662544?text=Hola,%20estoy%20interesado%20en%20una%20propiedad%20en%20alquiler");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = screenWidth > 1200
        ? 3
        : screenWidth > 800
            ? 2
            : 1;
    double childAspectRatio = screenWidth > 1200
        ? 0.80
        : screenWidth > 800
            ? 0.78
            : 0.90;

    return Scaffold(
      appBar: Navbar(),
      body: Container(
        color: const Color.fromARGB(255, 241, 241, 241),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                height: 280,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      Colors.grey.shade700,
                      Colors.grey.shade800,
                      Colors.grey.shade900,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'PROPIEDADES EN ALQUILER',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 80,
                        height: 3,
                        color: Colors.pink.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Encuentra tu próximo hogar para alquilar',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _launchWhatsApp,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey.shade900,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: const Text('Consultar disponibilidad'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'PROPIEDADES DISPONIBLES',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 60,
                      height: 3,
                      color: Colors.pink.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Explore nuestra selección de propiedades en alquiler',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: FutureBuilder<List<dynamic>>(
                future: _alquileresFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade800),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Cargando propiedades...',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        height: MediaQuery.of(context).size.height * 0.5,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              Text(
                                "Error al cargar propiedades",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 24),
                                child: Text(
                                  "${snapshot.error}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        constraints: BoxConstraints(
                          minHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.home_work, size: 48, color: Colors.grey.shade400),
                                    const SizedBox(height: 16),
                                    const Text(
                                      "No hay propiedades en alquiler disponibles",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Estamos trabajando para agregar nuevas propiedades pronto.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade700,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    ElevatedButton.icon(
                                      onPressed: _launchWhatsApp,
                                      label: const Text('Consultar disponibilidad'),
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: Colors.grey.shade800,
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }

                  final properties = snapshot.data!;
                  return SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 24,
                      mainAxisSpacing: 24,
                      childAspectRatio: childAspectRatio,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property = properties[index];
                        final mainImage = property['imageSrc']?.isNotEmpty == true
                            ? property['imageSrc'][0]
                            : 'assets/default_property.jpg';

                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: PropertyCard(
                            key: ValueKey(property['id']),
                            imageSrc: mainImage,
                            title: property['title'],
                            tipo: property['tipo'],
                            price: property['price'].toString(),
                            location: property['location'] ?? 'Sin ubicación',
                            bedrooms: property['bedrooms'] ?? 0,
                            bathrooms: property['bathrooms'] ?? 0,
                            area: property['area'] ?? 0,
                            description: property['description'],
                            buttonText: "Ver detalles",
                            onButtonClick: () =>
                                handleCardClick(context, property['id'], properties),
                          ),
                        );
                      },
                      childCount: properties.length,
                    ),
                  );
                },
              ),
            ),
            
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
                color: Colors.grey.shade900,
                child: Column(
                  children: [
                    const Text(
                      '¿BUSCANDO LA PROPIEDAD PERFECTA?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Container(
                        width: 60,
                        height: 3,
                        color: Colors.pink.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Contáctenos para encontrar la propiedad que se ajuste a sus necesidades.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _launchWhatsApp,
                      label: const Text('CONTACTAR AHORA'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.grey.shade900,
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverToBoxAdapter(
              child: const Footer(),
            ),
          ],
        ),
      ),
    );
  }
}