

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_web/components/navbar.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:mime_type/mime_type.dart';

class AdminPanel extends StatefulWidget {
  final String token;

  const AdminPanel({super.key, required this.token});

  @override
  State<AdminPanel> createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
  List<dynamic> properties = [];
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  late TabController _tabController;
  String _filterType = 'todos'; // Para filtrar por tipo (venta/alquiler)
  
  // Controladores para búsqueda y filtros
  final TextEditingController _searchController = TextEditingController();
  final _bedroomsFilterController = TextEditingController();
  final _bathroomsFilterController = TextEditingController();
  bool _showAdvancedFilters = false;

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _areaController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController(text: 'venta');
  int? _editingId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProperties();
    
    // Agregar listener para búsqueda con debounce
    _searchController.addListener(_onSearchChanged);
  }
  
  // Debounce para la búsqueda
  DateTime? _lastSearchTime;
  void _onSearchChanged() {
    final now = DateTime.now();
    _lastSearchTime = now;
    
    // Esperar 500ms antes de realizar la búsqueda
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_lastSearchTime == now) {
        _searchProperties();
      }
    });
  }

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3004/api/properties'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          properties = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al cargar propiedades: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Error: $e');
    }
  }
  
  // Método para buscar propiedades con los filtros aplicados
  Future<void> _searchProperties() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      // Construir la URL con los parámetros de búsqueda
      final queryParams = <String, String>{};
      
      // Texto de búsqueda
      if (_searchController.text.isNotEmpty) {
        queryParams['query'] = _searchController.text;
      }
      
      // Filtro de tipo (venta/alquiler)
      if (_filterType != 'todos') {
        queryParams['type'] = _filterType;
      }
      
      // Filtros avanzados
      if (_bedroomsFilterController.text.isNotEmpty) {
        queryParams['bedrooms'] = _bedroomsFilterController.text;
      }
      
      if (_bathroomsFilterController.text.isNotEmpty) {
        queryParams['bathrooms'] = _bathroomsFilterController.text;
      }
      
      // Construir la URL con los parámetros
      final uri = Uri.http('localhost:3004', '/api/properties/search', queryParams);
      
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          properties = json.decode(response.body);
          isLoading = false;
        });
      } else {
        throw Exception('Error al buscar propiedades: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Error: $e');
    }
  }

  // Filtrar propiedades por tipo
  List<dynamic> get filteredProperties {
    if (_filterType == 'todos') return properties;
    return properties.where((p) => p['tipo'] == _filterType).toList();
  }

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (images.isNotEmpty) {
        setState(() => _selectedImages = images);
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar imágenes: $e');
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final url = _editingId == null 
          ? 'http://localhost:3004/api/properties'
          : 'http://localhost:3004/api/properties/$_editingId';

      debugPrint('Enviando a: $url');

      var request = http.MultipartRequest(
        _editingId == null ? 'POST' : 'PUT',
        Uri.parse(url),
      );

      // Configurar headers
      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.headers['Accept'] = 'application/json';

      // Agregar campos del formulario
      request.fields.addAll({
        'title': _titleController.text,
        'price': _priceController.text,
        'location': _locationController.text,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'area': _areaController.text,
        'description': _descriptionController.text,
        'tipo': _typeController.text,
      });

      // Procesar imágenes
      for (var image in _selectedImages) {
        final mimeType = mime(image.name) ?? 'application/octet-stream';
        final fileType = mimeType.split('/')[0];
        
        if (fileType != 'image') {
          throw Exception('Solo se permiten imágenes (${image.name})');
        }

        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          request.files.add(http.MultipartFile.fromBytes(
            'images',
            bytes,
            filename: image.name,
            contentType: MediaType.parse(mimeType),
          ));
        } else {
          request.files.add(await http.MultipartFile.fromPath(
            'images',
            image.path,
            filename: image.name,
            contentType: MediaType.parse(mimeType),
          ));
        }
      }

      // Enviar solicitud
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (!mounted) return;

      // Debug
      debugPrint('Respuesta del servidor ($url):');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pop();
        _fetchProperties();
        _clearForm();
        
        // Mensaje específico según la operación
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_editingId == null 
                ? 'Propiedad creada correctamente' 
                : 'Propiedad actualizada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error del servidor (${response.statusCode}): $responseData');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al ${_editingId == null ? 'crear' : 'actualizar'} propiedad: ${e.toString()}');
    }
  }

  Future<void> _deleteProperty(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('http://localhost:3004/api/properties/$id'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        _fetchProperties();
        // Mensaje específico para eliminación
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propiedad eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al eliminar: ${response.statusCode}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error al eliminar propiedad: $e');
    }
  }

  void _editProperty(Map<String, dynamic> property) {
    setState(() {
      _editingId = property['id'];
      _titleController.text = property['title'];
      _priceController.text = property['price'].toString();
      _locationController.text = property['location'];
      _bedroomsController.text = property['bedrooms'].toString();
      _bathroomsController.text = property['bathrooms'].toString();
      _areaController.text = property['area'].toString();
      _descriptionController.text = property['description'];
      _typeController.text = property['tipo'] ?? 'venta';
      _selectedImages = [];
    });

    _showPropertyForm();
  }

  void _showPropertyForm() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_editingId == null ? 'Nueva Propiedad' : 'Editar Propiedad'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _typeController.text,
                  items: ['venta', 'alquiler'].map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type == 'venta' ? 'Venta' : 'Alquiler'),
                  )).toList(),
                  onChanged: (value) => _typeController.text = value!,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixText: '\$ ',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Ubicación',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _bedroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Dormitorios',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.bed),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _bathroomsController,
                        decoration: const InputDecoration(
                          labelText: 'Baños',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                          prefixIcon: Icon(Icons.bathroom),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) => value!.isEmpty ? 'Requerido' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(
                    labelText: 'Área (m²)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    suffixText: 'm²',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Seleccionar Imágenes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
                if (_selectedImages.isNotEmpty)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      const Text('Imágenes seleccionadas:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _selectedImages.map((image) => Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: kIsWeb 
                                ? Image.network(
                                    image.path,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : Image.file(
                                    File(image.path), 
                                    width: 80, 
                                    height: 80, 
                                    fit: BoxFit.cover,
                                  ),
                              ),
                              Positioned(
                                right: 0,
                                top: 0,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.remove(image);
                                    });
                                  },
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, size: 16, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          )).toList(),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              _clearForm();
            },
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancelar', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            onPressed: _submitProperty,
            icon: Icon(_editingId == null ? Icons.save : Icons.update),
            label: Text(_editingId == null ? 'Guardar' : 'Actualizar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _clearForm() {
    setState(() {
      _editingId = null;
      _titleController.clear();
      _priceController.clear();
      _locationController.clear();
      _bedroomsController.clear();
      _bathroomsController.clear();
      _areaController.clear();
      _descriptionController.clear();
      _typeController.text = 'venta';
      _selectedImages = [];
    });
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('OK'),
          )
        ],
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirmar'),
          ],
        ),
        content: const Text('¿Estás seguro que deseas eliminar esta propiedad?'),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context), 
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
          ),
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _deleteProperty(id);
            },
            icon: const Icon(Icons.delete, color: Colors.red),
            label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
  
  // Mostrar/ocultar filtros avanzados
  void _toggleAdvancedFilters() {
    setState(() {
      _showAdvancedFilters = !_showAdvancedFilters;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _typeController.dispose();
    _searchController.dispose();
    _bedroomsFilterController.dispose();
    _bathroomsFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(), // Usa tu Navbar existente
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Panel de administración con estilo
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.pink.shade400, Colors.pink.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Panel de Administración',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Gestiona tus propiedades de forma sencilla',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.home, size: 32, color: Colors.pink),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${properties.length}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('Propiedades'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.sell, size: 32, color: Colors.pink),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${properties.where((p) => p['tipo'] == 'venta').length}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('En Venta'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Card(
                                elevation: 4,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    children: [
                                      const Icon(Icons.apartment, size: 32, color: Colors.pink),
                                      const SizedBox(height: 8),
                                      Text(
                                        '${properties.where((p) => p['tipo'] == 'alquiler').length}',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Text('En Alquiler'),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Filtros y pestañas
                  Container(
                    color: Colors.grey.shade100,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  // Campo de búsqueda
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Buscar propiedades...',
                                        prefixIcon: const Icon(Icons.search),
                                        suffixIcon: _searchController.text.isNotEmpty
                                            ? IconButton(
                                                icon: const Icon(Icons.clear),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  _searchProperties();
                                                },
                                              )
                                            : null,
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                      onSubmitted: (_) => _searchProperties(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Filtro de tipo
                                  DropdownButton<String>(
                                    value: _filterType,
                                    items: [
                                      const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                                      const DropdownMenuItem(value: 'venta', child: Text('Venta')),
                                      const DropdownMenuItem(value: 'alquiler', child: Text('Alquiler')),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _filterType = value!;
                                      });
                                      _searchProperties();
                                    },
                                    hint: const Text('Filtrar por'),
                                  ),
                                  const SizedBox(width: 16),
                                  // Botón para mostrar/ocultar filtros avanzados
                                  IconButton(
                                    icon: Icon(
                                      _showAdvancedFilters ? Icons.filter_list_off : Icons.filter_list,
                                      color: Colors.pink,
                                    ),
                                    onPressed: _toggleAdvancedFilters,
                                    tooltip: 'Filtros avanzados',
                                  ),
                                  const SizedBox(width: 8),
                                  // Botón para agregar nueva propiedad
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _clearForm();
                                      _showPropertyForm();
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Nueva Propiedad'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.pink,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              // Filtros avanzados (condicional)
                              if (_showAdvancedFilters)
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  margin: const EdgeInsets.only(top: 16),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 5,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Filtros avanzados',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Row(
                                        children: [
                                          // Filtro de dormitorios
                                          Expanded(
                                            child: TextField(
                                              controller: _bedroomsFilterController,
                                              decoration: const InputDecoration(
                                                labelText: 'Dormitorios (mín.)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(Icons.bed),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          // Filtro de baños
                                          Expanded(
                                            child: TextField(
                                              controller: _bathroomsFilterController,
                                              decoration: const InputDecoration(
                                                labelText: 'Baños (mín.)',
                                                border: OutlineInputBorder(),
                                                prefixIcon: Icon(Icons.bathroom),
                                              ),
                                              keyboardType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Botones de acción para filtros
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              _bedroomsFilterController.clear();
                                              _bathroomsFilterController.clear();
                                            },
                                            child: const Text('Limpiar filtros'),
                                          ),
                                          const SizedBox(width: 16),
                                          ElevatedButton(
                                            onPressed: _searchProperties,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.pink,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: const Text('Aplicar filtros'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                        TabBar(
                          controller: _tabController,
                          tabs: const [
                            Tab(text: 'Todas las Propiedades'),
                            Tab(text: 'En Venta'),
                            Tab(text: 'En Alquiler'),
                          ],
                          labelColor: Colors.pink,
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: Colors.pink,
                          onTap: (index) {
                            setState(() {
                              // Actualizar el filtro de tipo según la pestaña seleccionada
                              if (index == 0) {
                                _filterType = 'todos';
                              } else if (index == 1) {
                                _filterType = 'venta';
                              } else if (index == 2) {
                                _filterType = 'alquiler';
                              }
                            });
                            _searchProperties();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ];
        },
        // Lista de propiedades - Ahora con scroll completo y una propiedad por fila
        body: TabBarView(
          controller: _tabController,
          children: [
            // Todas las propiedades
            _buildPropertyList(properties),
            
            // Propiedades en venta
            _buildPropertyList(properties.where((p) => p['tipo'] == 'venta').toList()),
            
            // Propiedades en alquiler
            _buildPropertyList(properties.where((p) => p['tipo'] == 'alquiler').toList()),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPropertyList(List<dynamic> propertyList) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.pink),
        ),
      );
    }
    
    if (propertyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home_work, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No hay propiedades disponibles',
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                _clearForm();
                _showPropertyForm();
              },
              icon: const Icon(Icons.add),
              label: const Text('Agregar Propiedad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pink,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    // Usar ListView en lugar de GridView para mostrar una propiedad por fila
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: propertyList.length,
      itemBuilder: (context, index) {
        final property = propertyList[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Imagen y detalles en formato horizontal para pantallas grandes
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  
                  if (isWideScreen) {
                    // Formato horizontal para pantallas grandes
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen con etiqueta de tipo
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                bottomLeft: Radius.circular(12),
                              ),
                              child: property['imageSrc'] != null && 
                                      (property['imageSrc'] as List).isNotEmpty
                                  ? Image.network(
                                      'http://localhost:3004${property['imageSrc'][0]}',
                                      height: 240,
                                      width: 300,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 240,
                                        width: 300,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.home, size: 64, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      height: 240,
                                      width: 300,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.home, size: 64, color: Colors.white),
                                    ),
                            ),
                            // Etiqueta de tipo (venta/alquiler)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: property['tipo'] == 'venta' ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  property['tipo'] == 'venta' ? 'VENTA' : 'ALQUILER',
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
                        
                        // Detalles de la propiedad
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property['title'],
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        property['location'],
                                        style: TextStyle(color: Colors.grey.shade700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  '\$${property['price']}',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.pink,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  property['description'],
                                  style: TextStyle(
                                    color: Colors.grey.shade800,
                                    fontSize: 14,
                                  ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 16),
                                // Características
                                Row(
                                  children: [
                                    _buildFeatureChip(Icons.bed, '${property['bedrooms']}'),
                                    const SizedBox(width: 8),
                                    _buildFeatureChip(Icons.bathroom, '${property['bathrooms']}'),
                                    const SizedBox(width: 8),
                                    _buildFeatureChip(Icons.square_foot, '${property['area']}m²'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Botones de acción
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton.icon(
                                      onPressed: () => _editProperty(property),
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      label: const Text('Editar', style: TextStyle(color: Colors.blue)),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton.icon(
                                      onPressed: () => _confirmDelete(property['id']),
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Formato vertical para pantallas pequeñas
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Imagen con etiqueta de tipo
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: property['imageSrc'] != null && 
                                      (property['imageSrc'] as List).isNotEmpty
                                  ? Image.network(
                                      'http://localhost:3004${property['imageSrc'][0]}',
                                      height: 200,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        height: 200,
                                        width: double.infinity,
                                        color: Colors.grey.shade300,
                                        child: const Icon(Icons.home, size: 64, color: Colors.white),
                                      ),
                                    )
                                  : Container(
                                      height: 200,
                                      width: double.infinity,
                                      color: Colors.grey.shade300,
                                      child: const Icon(Icons.home, size: 64, color: Colors.white),
                                    ),
                            ),
                            // Etiqueta de tipo (venta/alquiler)
                            Positioned(
                              top: 10,
                              left: 10,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: property['tipo'] == 'venta' ? Colors.green : Colors.blue,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  property['tipo'] == 'venta' ? 'VENTA' : 'ALQUILER',
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
                        
                        // Detalles de la propiedad
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property['title'],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      property['location'],
                                      style: TextStyle(color: Colors.grey.shade700),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '\$${property['price']}',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.pink,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                property['description'],
                                style: TextStyle(
                                  color: Colors.grey.shade800,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 16),
                              // Características
                              Row(
                                children: [
                                  _buildFeatureChip(Icons.bed, '${property['bedrooms']}'),
                                  const SizedBox(width: 8),
                                  _buildFeatureChip(Icons.bathroom, '${property['bathrooms']}'),
                                  const SizedBox(width: 8),
                                  _buildFeatureChip(Icons.square_foot, '${property['area']}m²'),
                                ],
                              ),
                              const SizedBox(height: 16),
                              // Botones de acción
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () => _editProperty(property),
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    label: const Text('Editar', style: TextStyle(color: Colors.blue)),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton.icon(
                                    onPressed: () => _confirmDelete(property['id']),
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildFeatureChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.pink),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}

