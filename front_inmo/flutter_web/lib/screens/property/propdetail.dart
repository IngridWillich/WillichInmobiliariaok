import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/footer.dart'; 

class PropertyDetailsPage extends StatefulWidget {
  final Map<String, dynamic> property;

  const PropertyDetailsPage({
    super.key,
    required this.property,
  });

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}

class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  int _currentImageIndex = 0;
  final ScrollController _thumbnailScrollController = ScrollController();
  late PageController _pageController;
  late PageController _fullScreenPageController;

  // Controla la visibilidad del ícono de lupa
  bool _showZoomIcon = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fullScreenPageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fullScreenPageController.dispose();
    _thumbnailScrollController.dispose();
    super.dispose();
  }

  void _openFullScreenGallery(BuildContext context, int initialIndex) {
    final List<String> images = (widget.property['imageSrc'] is List)
        ? (widget.property['imageSrc'] as List).whereType<String>().toList()
        : [];

    if (images.isEmpty) return;

    _fullScreenPageController = PageController(initialPage: initialIndex);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              PageView.builder(
                controller: _fullScreenPageController,
                itemCount: images.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentImageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  // Asegurarse de que la URL sea correcta
                  final String imageUrl = images[index].startsWith('http')
                      ? images[index]
                      : 'http://localhost:3004${images[index]}';
                      
                  return GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Center(
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 3.0,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.error_outline, size: 50, color: Colors.red),
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),

              // Flechas de navegación en fullscreen
              Positioned(
                left: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_left, size: 30, color: Colors.white),
                      onPressed: () {
                        if (_fullScreenPageController.page?.toInt() == 0) return;
                        _fullScreenPageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              Positioned(
                right: 20,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.chevron_right, size: 30, color: Colors.white),
                      onPressed: () {
                        if (_fullScreenPageController.page?.toInt() == images.length - 1) return;
                        _fullScreenPageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ),
                ),
              ),

              // Indicadores en fullscreen
              Positioned(
                bottom: 30,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(images.length, (index) {
                    return Container(
                      width: 10.0,
                      height: 10.0,
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentImageIndex == index
                            ? Colors.white
                            : Colors.white.withAlpha(102),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<String> images = (widget.property['imageSrc'] is List)
        ? (widget.property['imageSrc'] as List).whereType<String>().toList()
        : [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        foregroundColor: Colors.white,
        title: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: Center(
            child: Text(
              widget.property['title'] ?? 'Detalles de la propiedad',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de imágenes 
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.5,
              child: Stack(
                children: [
                  // PageView para las imágenes
                  PageView.builder(
                    controller: _pageController,
                    itemCount: images.isEmpty ? 1 : images.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentImageIndex = index;
                        if (_thumbnailScrollController.hasClients) {
                          _thumbnailScrollController.animateTo(
                            index * 80.0,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      });
                    },
                    itemBuilder: (context, index) {
                      if (images.isEmpty) return _buildPlaceholderImage();
                      
                      // Asegurarse de que la URL sea correcta
                      final String imageUrl = images[index].startsWith('http')
                          ? images[index]
                          : 'http://localhost:3004${images[index]}';
                          
                      return MouseRegion(
                        onEnter: (_) => setState(() => _showZoomIcon = true),
                        onExit: (_) => setState(() => _showZoomIcon = false),
                        child: Stack(
                          children: [
                            GestureDetector(
                              onTap: () => _openFullScreenGallery(context, _currentImageIndex),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderImage(),
                              ),
                            ),
                            
                            // Ícono de lupa 
                            if (_showZoomIcon)
                              Positioned.fill(
                                child: GestureDetector(
                                  onTap: () => _openFullScreenGallery(context, _currentImageIndex),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.2),
                                    child: Center(
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.5),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.zoom_in,
                                          color: Colors.white,
                                          size: 36,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  // Flechas de navegación
                  if (images.isNotEmpty && images.length > 1)
                    Positioned(
                      left: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_left, size: 24, color: Colors.white),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  
                  if (images.isNotEmpty && images.length > 1)
                    Positioned(
                      right: 10,
                      top: 0,
                      bottom: 0,
                      child: Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chevron_right, size: 24, color: Colors.white),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  
                  // Indicadores de posición
                  if (images.isNotEmpty && images.length > 1)
                    Positioned(
                      bottom: 20,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (index) {
                          return GestureDetector(
                            onTap: () => _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            ),
                            child: Container(
                              width: 8.0,
                              height: 8.0,
                              margin: const EdgeInsets.symmetric(horizontal: 4.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentImageIndex == index
                                    ? Colors.white
                                    : Colors.white.withAlpha(102),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            
            // Miniaturas de imágenes
            if (images.isNotEmpty && images.length > 1)
              Container(
                height: 80,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: ListView.builder(
                  controller: _thumbnailScrollController,
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    // Asegurarse de que la URL sea correcta
                    final String imageUrl = images[index].startsWith('http')
                        ? images[index]
                        : 'http://localhost:3004${images[index]}';
                        
                    return GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _currentImageIndex == index 
                                ?   Color.fromARGB(255, 202, 121, 148)
                                : Colors.transparent,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

            // Resto del contenido...
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio
                  Text(
                   'USD ${widget.property['price'] ?? 'Precio no disponible'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 202, 121, 148),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.property['location'] ?? 'Ubicación no disponible',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Características
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildFeatureColumn(
                            Icons.king_bed,
                            '${widget.property['bedrooms'] ?? 0}',
                            'Habitaciones',
                          ),
                          _buildFeatureColumn(
                            Icons.bathtub,
                            '${widget.property['bathrooms'] ?? 0}',
                            'Baños',
                          ),
                          _buildFeatureColumn(
                            Icons.aspect_ratio,
                            '${widget.property['area'] ?? 0}',
                            'm²',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    'Descripción',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property['description'] ?? 'Sin descripción disponible',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de contacto
                 SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Crear el mensaje con los detalles de la propiedad
                      final propertyTitle = widget.property['title'] ?? 'Propiedad';
                      
                      final propertyLocation = widget.property['location'] ?? 'Ubicación no disponible';
                      
                      final message = 'Hola, estoy interesado/a en la propiedad: '
                          '$propertyTitle\n'
                          'Ubicación: $propertyLocation\n'
                          '¿Podrían brindarme más información?';
                      
                      // Codificar el mensaje para URL
                      final encodedMessage = Uri.encodeFull(message);
                      
                      // Abrir el enlace de WhatsApp
                      final url = 'https://wa.me/5493434662544?text=$encodedMessage';
                      
                      
                      try {
                        launchUrl(Uri.parse(url));
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('No se pudo abrir WhatsApp'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Color.fromARGB(255, 202, 121, 148),
                      foregroundColor: Colors.white,
                    ),
                    child: const Text(
                      'Contactar al vendedor por WhatsApp',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

                  
                  if (widget.property.containsKey('additionalDetails'))
                    _buildAdditionalDetails(),
                ],
              ),
            ),

           
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      width: double.infinity,
      height: double.infinity,
      child: const Icon(
        Icons.home,
        size: 80,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildFeatureColumn(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon,  color: Color.fromARGB(255, 202, 121, 148), size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    final additionalDetails =
        widget.property['additionalDetails'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const Text(
          'Detalles adicionales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...additionalDetails.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.key}: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.value}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}