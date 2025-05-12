
import 'package:flutter/material.dart';
import 'package:flutter_web/screens/property/propdetail.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Property {
  final int id;
  final String title;
  final String description;
  final String location;
  final double price;
  final int bedrooms;
  final int bathrooms;
  final double area;
  final String tipo;
  final List<String> imageSrc;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.tipo,
    required this.imageSrc,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    List<String> images = [];
    if (json['imageSrc'] != null) {
      if (json['imageSrc'] is List) {
        images = (json['imageSrc'] as List).map((img) => img.toString()).toList();
      } else if (json['imageSrc'] is String) {
        images = [json['imageSrc']];
      }
    }
    
    return Property(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      location: json['location'] ?? '',
      price: _parsePrice(json['price']),
      bedrooms: json['bedrooms'] ?? 0,
      bathrooms: json['bathrooms'] ?? 0,
      area: _parseArea(json['area']),
      tipo: json['tipo'] ?? '',
      imageSrc: images,
    );
  }

  static double _parsePrice(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

static double _parseArea(dynamic value) {
  if (value is num) return value.toDouble();
  if (value is String) {
    if (value.contains('x')) {
      final parts = value.split('x');
      if (parts.length == 2) {
        final width = double.tryParse(parts[0].trim());
        final length = double.tryParse(parts[1].trim());
        if (width != null && length != null) {
          return width * length;
        }
      }
    }
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }
  return 0.0;
}
}

class PropertySearchWidget extends StatefulWidget {
  const PropertySearchWidget({super.key});

  @override
  State<PropertySearchWidget> createState() => _PropertySearchWidgetState();
}

class _PropertySearchWidgetState extends State<PropertySearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  String propertyType = '';
  final TextEditingController _bedroomsController = TextEditingController();
  final TextEditingController _bathroomsController = TextEditingController();

  List<Property> properties = [];
  bool isLoading = false;
  bool showFilters = false;
  String? error;
  bool hasSearched = false;
  
  DateTime? _lastSearchTime;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _bedroomsController.addListener(_onSearchChanged);
    _bathroomsController.addListener(_onSearchChanged);
  }
  
  void _onSearchChanged() {
    final now = DateTime.now();
    _lastSearchTime = now;
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastSearchTime == now) {
        searchProperties();
      }
    });
  }

  Future<void> searchProperties() async {
    
    if (_searchController.text.isEmpty && 
        propertyType.isEmpty && 
        _bedroomsController.text.isEmpty && 
        _bathroomsController.text.isEmpty) {
      setState(() {
        properties = [];
        isLoading = false;
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      error = null;
      hasSearched = true;
    });

    final queryParams = <String, String>{};
    
    if (_searchController.text.isNotEmpty) {
      queryParams['query'] = _searchController.text;
    }
    
    if (propertyType.isNotEmpty) {
      queryParams['type'] = propertyType;
    }
    
    if (_bedroomsController.text.isNotEmpty) {
      queryParams['bedrooms'] = _bedroomsController.text;
    }
    
    if (_bathroomsController.text.isNotEmpty) {
      queryParams['bathrooms'] = _bathroomsController.text;
    }
    
    try {
      final uri = Uri.http('localhost:3004', '/api/properties/search', queryParams);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          properties = data.map((json) => Property.fromJson(json)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Error del servidor: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error de conexión: $e';
        isLoading = false;
      });
    }
  }

  void clearFilters() {
    setState(() {
      propertyType = '';
      _bedroomsController.clear();
      _bathroomsController.clear();
      _searchController.clear();
      properties = [];
      hasSearched = false;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 4,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.search, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText: 'Buscar propiedades...',
                              border: InputBorder.none,
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        searchProperties();
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            showFilters ? Icons.filter_list_off : Icons.filter_list,
                            color: Colors.grey,
                          ),
                          onPressed: () => setState(() => showFilters = !showFilters),
                        ),
                        ElevatedButton(
                          onPressed: searchProperties,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pink,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Buscar'),
                        ),
                      ],
                    ),
                    if (showFilters) ...[
                      const SizedBox(height: 16),
                      _buildFiltersPanel(),
                      const SizedBox(height: 8),
                      _buildActiveFilters(),
                    ],
                  ],
                ),
              ),
            ),
          ),
          PropertySearchResults(
            properties: properties,
            isLoading: isLoading,
            error: error,
            hasSearched: hasSearched,
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersPanel() {
    return Column(
      children: [
        Row(
          children: [
            _buildTypeFilter(),
            const SizedBox(width: 16),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildBedroomsFilter(),
            const SizedBox(width: 16),
            _buildBathroomsFilter(),
          ],
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: clearFilters,
            child: const Text('Limpiar filtros', style: TextStyle(color: Colors.pink)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tipo de operacion', style: TextStyle(fontSize: 12, color: Colors.grey)),
          DropdownButtonFormField<String>(
            value: propertyType.isEmpty ? null : propertyType,
            items: const [
              DropdownMenuItem(value: '', child: Text('Todas')),
              DropdownMenuItem(value: 'venta', child: Text('Venta')),
              DropdownMenuItem(value: 'alquiler', child: Text('Alquiler')),
            ],
            onChanged: (value) {
              setState(() => propertyType = value ?? '');
              searchProperties();
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }

  Widget _buildBedroomsFilter() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Habitaciones', style: TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _bedroomsController,
            decoration: const InputDecoration(
              hintText: 'Mínimo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bed),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildBathroomsFilter() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Baños', style: TextStyle(fontSize: 12, color: Colors.grey)),
          TextField(
            controller: _bathroomsController,
            decoration: const InputDecoration(
              hintText: 'Mínimo',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bathroom),
            ),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (propertyType.isNotEmpty)
          InputChip(
            label: Text(propertyType == 'venta' ? 'Venta' : 'Alquiler'),
            onDeleted: () {
              setState(() => propertyType = '');
              searchProperties();
            },
            deleteIconColor: Colors.pink,
            backgroundColor: Colors.pink.shade50,
          ),
        if (_bedroomsController.text.isNotEmpty)
          InputChip(
            label: Text('${_bedroomsController.text}+ hab'),
            onDeleted: () {
              setState(() => _bedroomsController.clear());
              searchProperties();
            },
            deleteIconColor: Colors.pink,
            backgroundColor: Colors.pink.shade50,
          ),
        if (_bathroomsController.text.isNotEmpty)
          InputChip(
            label: Text('${_bathroomsController.text}+ baños'),
            onDeleted: () {
              setState(() => _bathroomsController.clear());
              searchProperties();
            },
            deleteIconColor: Colors.pink,
            backgroundColor: Colors.pink.shade50,
          ),
      ],
    );
  }
}

class PropertySearchResults extends StatelessWidget {
  final List<Property> properties;
  final bool isLoading;
  final String? error;
  final bool hasSearched;

  const PropertySearchResults({
    super.key,
    required this.properties,
    required this.isLoading,
    this.error,
    required this.hasSearched,
  });

  @override
  Widget build(BuildContext context) {
    if (!hasSearched) {
      return const SizedBox.shrink();
    }

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
          ),
        ),
      );
    }

    if (error != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: Colors.red.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    error!,
                    style: TextStyle(color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (properties.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home_work, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'No se encontraron propiedades',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otros filtros de búsqueda',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              '${properties.length} propiedades encontradas',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: properties.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final property = properties[index];
              return _buildPropertyCard(property, context);
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildPropertyCard(Property property, BuildContext context) {
    final isWideScreen = MediaQuery.of(context).size.width > 600;
    
    return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
          Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PropertyDetailsPage(
              property: {
                'id': property.id.toString(),
                'title': property.title,
                'description': property.description,
                'location': property.location,
                'price': property.price.toString(),
                'bedrooms': property.bedrooms.toString(),
                'bathrooms': property.bathrooms.toString(),
                'area': property.area.toString(),
                'tipo': property.tipo,
                'imageSrc': property.imageSrc.map((img) => 
                  img.startsWith('http') ? img : 'http://localhost:3004$img'
                ).toList(),
              },
            ),
          ),
        );
      },
      child: isWideScreen 
          ? _buildWideLayout(property)
          : _buildNarrowLayout(property),
    ),
  );
     
}
  
  Widget _buildWideLayout(Property property) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomLeft: Radius.circular(12),
          ),
          child: Container(
            width: 250,
            height: 200,
            color: Colors.grey.shade200,
            child: property.imageSrc.isNotEmpty
                ? Image.network(
                    'http://localhost:3004${property.imageSrc[0]}',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.home, size: 48, color: Colors.grey),
                  )
                : const Icon(Icons.home, size: 48, color: Colors.grey),
          ),
        ),
        
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        property.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: property.tipo == 'venta' ? Colors.green : Colors.blue,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        property.tipo == 'venta' ? 'VENTA' : 'ALQUILER',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        property.location,
                        style: TextStyle(color: Colors.grey.shade700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  'USS${property.price.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.pink,
                  ),
                ),
                
                const SizedBox(height: 12),
                
                Text(
                  property.description,
                  style: TextStyle(
                    color: Colors.grey.shade800,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    _buildFeatureChip(Icons.bed, '${property.bedrooms} hab'),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.bathroom, '${property.bathrooms} baños'),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.square_foot, '${property.area.toStringAsFixed(0)} m²'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildNarrowLayout(Property property) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 180,
                width: double.infinity,
                color: Colors.grey.shade200,
                child: property.imageSrc.isNotEmpty
                    ? Image.network(
                        'http://localhost:3004${property.imageSrc[0]}',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(Icons.home, size: 48, color: Colors.grey),
                      )
                    : const Icon(Icons.home, size: 48, color: Colors.grey),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: property.tipo == 'venta' ? Colors.green : Colors.blue,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  property.tipo == 'venta' ? 'VENTA' : 'ALQUILER',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                property.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 8),
              
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      property.location,
                      style: TextStyle(color: Colors.grey.shade700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              Text(
                'USS${property.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink,
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                property.description,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 16),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFeatureChip(Icons.bed, '${property.bedrooms} hab'),
                  _buildFeatureChip(Icons.bathroom, '${property.bathrooms} baños'),
                  _buildFeatureChip(Icons.square_foot, '${property.area.toStringAsFixed(0)} m²'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFeatureChip(IconData icon, String text) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.pink),
      label: Text(text),
      backgroundColor: Colors.grey.shade100,
      visualDensity: VisualDensity.compact,
    );
  }
}