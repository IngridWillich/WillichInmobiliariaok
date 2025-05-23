// import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter_web/components/navbar.dart';
// import 'package:http/http.dart' as http;
// import 'package:http_parser/http_parser.dart';
// import 'dart:convert';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
// import 'package:mime_type/mime_type.dart';

// class AdminPanel extends StatefulWidget {
//   final String token;

//   const AdminPanel({super.key, required this.token});

//   @override
//   State<AdminPanel> createState() => _AdminPanelState();
// }

// class _AdminPanelState extends State<AdminPanel> with SingleTickerProviderStateMixin {
//   List<dynamic> properties = []; // Propiedades filtradas
//   List<dynamic> allProperties = []; // TODAS las propiedades sin filtrar
//   bool isLoading = true;
//   final ImagePicker _picker = ImagePicker();
//   List<XFile> _selectedImages = [];
//   late TabController _tabController;
//   String _filterType = 'todos';
//   String _estadoFilter = 'todos'; 
//   final TextEditingController _searchController = TextEditingController();
//   final _bedroomsFilterController = TextEditingController();
//   final _bathroomsFilterController = TextEditingController();
//   bool _showAdvancedFilters = false;

//   final _formKey = GlobalKey<FormState>();
//   final _titleController = TextEditingController();
//   final _priceController = TextEditingController();
//   final _locationController = TextEditingController();
//   final _bedroomsController = TextEditingController();
//   final _bathroomsController = TextEditingController();
//   final _areaController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   final _typeController = TextEditingController(text: 'venta');
//   final _estadoController = TextEditingController(text: 'disponible');
//   int? _editingId;
  
//   // Para previsualización de imágenes
//   int _currentImageIndex = 0;
//   bool _showImagePreview = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     _fetchProperties();
//     _searchController.addListener(_onSearchChanged);
//   }

//   DateTime? _lastSearchTime;
//   void _onSearchChanged() {
//     final now = DateTime.now();
//     _lastSearchTime = now;
    
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (_lastSearchTime == now) {
//         _searchProperties();
//       }
//     });
//   }

//   Future<void> _fetchProperties() async {
//     if (!mounted) return;
    
//     setState(() => isLoading = true);
    
//     try {
//       final response = await http.get(
//         Uri.parse('http://localhost:3004/api/properties'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint('Propiedades recibidas: ${data.length}');
//         setState(() {
//           properties = data;
//           allProperties = List.from(data); // Guardar una copia de todas las propiedades
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Error al cargar propiedades: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//       _showErrorDialog('Error: $e');
//     }
//   }
  
//   Future<void> _searchProperties() async {
//     if (!mounted) return;
    
//     setState(() => isLoading = true);
    
//     try {
//       final queryParams = <String, String>{};
      
//       if (_searchController.text.isNotEmpty) {
//         queryParams['query'] = _searchController.text;
//       }
      
//       if (_filterType != 'todos') {
//         queryParams['type'] = _filterType;
//       }
      
//       if (_estadoFilter != 'todos') {
//         queryParams['estado'] = _estadoFilter; 
//       }
      
//       if (_bedroomsFilterController.text.isNotEmpty) {
//         queryParams['bedrooms'] = _bedroomsFilterController.text;
//       }
      
//       if (_bathroomsFilterController.text.isNotEmpty) {
//         queryParams['bathrooms'] = _bathroomsFilterController.text;
//       }
      
//       final uri = Uri.http('localhost:3004', '/api/properties/search', queryParams);
      
//       debugPrint('Buscando propiedades con: $queryParams');
//       final response = await http.get(
//         uri,
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         debugPrint('Resultados de búsqueda: ${data.length}');
//         setState(() {
//           properties = data;
//           // Si no hay filtros, actualizar también allProperties
//           if (queryParams.isEmpty) {
//             allProperties = List.from(data);
//           }
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Error al buscar propiedades: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       setState(() => isLoading = false);
//       _showErrorDialog('Error: $e');
//     }
//   }

//   // Filtrar propiedades solo por estado (disponible, reservado, vendido)
//   List<dynamic> get filteredProperties {
//     if (_estadoFilter == 'todos') return properties;
    
//     return properties.where((p) {
//       return p['estado'] == _estadoFilter;
//     }).toList();
//   }

//   // Obtener contadores para las propiedades usando allProperties
//   int get totalProperties => allProperties.length;
//   int get ventaProperties => allProperties.where((p) => p['tipo'] == 'venta').length;
//   int get alquilerProperties => allProperties.where((p) => p['tipo'] == 'alquiler').length;

//   Future<void> _pickImages() async {
//     try {
//       final images = await _picker.pickMultiImage(
//         imageQuality: 85,
//         maxWidth: 1920,
//       );
//       if (images.isNotEmpty) {
//         setState(() => _selectedImages.addAll(images));
//       }
//     } catch (e) {
//       _showErrorDialog('Error al seleccionar imágenes: $e');
//     }
//   }

//   // Mover imagen hacia arriba en la lista
//   void _moveImageUp(int index) {
//     if (index <= 0) return;
//     setState(() {
//       final temp = _selectedImages[index];
//       _selectedImages[index] = _selectedImages[index - 1];
//       _selectedImages[index - 1] = temp;
//     });
//   }

//   // Mover imagen hacia abajo en la lista
//   void _moveImageDown(int index) {
//     if (index >= _selectedImages.length - 1) return;
//     setState(() {
//       final temp = _selectedImages[index];
//       _selectedImages[index] = _selectedImages[index + 1];
//       _selectedImages[index + 1] = temp;
//     });
//   }

//   // Mostrar previsualización de imagen a tamaño completo
//   void _showFullImagePreview(int index) {
//     setState(() {
//       _currentImageIndex = index;
//       _showImagePreview = true;
//     });
//   }

//   // Cerrar previsualización de imagen
//   void _closeImagePreview() {
//     setState(() {
//       _showImagePreview = false;
//     });
//   }

//   // Navegar a la imagen anterior
//   void _previousImage() {
//     if (_currentImageIndex > 0) {
//       setState(() {
//         _currentImageIndex--;
//       });
//     }
//   }

//   // Navegar a la imagen siguiente
//   void _nextImage() {
//     if (_currentImageIndex < _selectedImages.length - 1) {
//       setState(() {
//         _currentImageIndex++;
//       });
//     }
//   }

//   Future<void> _submitProperty() async {
//     if (!_formKey.currentState!.validate()) return;

//     try {
//       final url = _editingId == null 
//           ? 'http://localhost:3004/api/properties'
//           : 'http://localhost:3004/api/properties/$_editingId';

//       debugPrint('Enviando a: $url');
//       debugPrint('Estado seleccionado: ${_estadoController.text}');

//       var request = http.MultipartRequest(
//         _editingId == null ? 'POST' : 'PUT',
//         Uri.parse(url),
//       );

//       request.headers['Authorization'] = 'Bearer ${widget.token}';
//       request.headers['Accept'] = 'application/json';

//       request.fields.addAll({
//         'title': _titleController.text,
//         'price': _priceController.text,
//         'location': _locationController.text,
//         'bedrooms': _bedroomsController.text,
//         'bathrooms': _bathroomsController.text,
//         'area': _areaController.text,
//         'description': _descriptionController.text,
//         'tipo': _typeController.text,
//         'estado': _estadoController.text, 
//       });

//       // Log de todos los campos que se envían
//       request.fields.forEach((key, value) {
//         debugPrint('Campo enviado: $key = $value');
//       });

//       for (var image in _selectedImages) {
//         final mimeType = mime(image.name) ?? 'application/octet-stream';
//         final fileType = mimeType.split('/')[0];
        
//         if (fileType != 'image') {
//           throw Exception('Solo se permiten imágenes (${image.name})');
//         }

//         if (kIsWeb) {
//           final bytes = await image.readAsBytes();
//           request.files.add(http.MultipartFile.fromBytes(
//             'images',
//             bytes,
//             filename: image.name,
//             contentType: MediaType.parse(mimeType),
//           ));
//         } else {
//           request.files.add(await http.MultipartFile.fromPath(
//             'images',
//             image.path,
//             filename: image.name,
//             contentType: MediaType.parse(mimeType),
//           ));
//         }
//       }

//       final response = await request.send();
//       final responseData = await response.stream.bytesToString();

//       if (!mounted) return;

//       debugPrint('Respuesta del servidor ($url):');
//       debugPrint('Status: ${response.statusCode}');
//       debugPrint('Body: $responseData');

//       if (response.statusCode >= 200 && response.statusCode < 300) {
//         Navigator.of(context).pop();
        
//         // Forzar recarga completa
//         setState(() {
//           properties = [];
//           allProperties = [];
//           isLoading = true;
//         });
        
//         await _fetchProperties();
//         _clearForm();
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(_editingId == null 
//                 ? 'Propiedad creada correctamente' 
//                 : 'Propiedad actualizada correctamente'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception('Error del servidor (${response.statusCode}): $responseData');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showErrorDialog('Error al ${_editingId == null ? 'crear' : 'actualizar'} propiedad: ${e.toString()}');
//     }
//   }

//   Future<void> _deleteProperty(int id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('http://localhost:3004/api/properties/$id'),
//         headers: {'Authorization': 'Bearer ${widget.token}'},
//       );

//       if (!mounted) return;

//       if (response.statusCode == 200) {
//         // Forzar recarga completa
//         setState(() {
//           properties = [];
//           allProperties = [];
//           isLoading = true;
//         });
        
//         await _fetchProperties();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Propiedad eliminada correctamente'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } else {
//         throw Exception('Error al eliminar: ${response.statusCode}');
//       }
//     } catch (e) {
//       if (!mounted) return;
//       _showErrorDialog('Error al eliminar propiedad: $e');
//     }
//   }

//   void _editProperty(Map<String, dynamic> property) {
//     debugPrint('Editando propiedad: ${property['id']}');
//     debugPrint('Estado actual: ${property['estado']}');
    
//     setState(() {
//       _editingId = property['id'];
//       _titleController.text = property['title'];
//       _priceController.text = property['price'].toString();
//       _locationController.text = property['location'];
//       _bedroomsController.text = property['bedrooms'].toString();
//       _bathroomsController.text = property['bathrooms'].toString();
//       _areaController.text = property['area'].toString();
//       _descriptionController.text = property['description'];
//       _typeController.text = property['tipo'] ?? 'venta';
//       _estadoController.text = property['estado'] ?? 'disponible'; 
//       _selectedImages = []; // Limpiar imágenes seleccionadas
//     });

//     _showPropertyForm();
//   }

//   // Widget para mostrar la previsualización de imagen a tamaño completo
//   Widget _buildImagePreviewDialog() {
//     return Dialog(
//       backgroundColor: Colors.transparent,
//       insetPadding: EdgeInsets.zero,
//       child: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.black.withOpacity(0.9),
//         child: Stack(
//           children: [
//             // Imagen central
//             Center(
//               child: kIsWeb
//                 ? Image.network(
//                     _selectedImages[_currentImageIndex].path,
//                     fit: BoxFit.contain,
//                   )
//                 : Image.file(
//                     File(_selectedImages[_currentImageIndex].path),
//                     fit: BoxFit.contain,
//                   ),
//             ),
            
//             // Botones de navegación
//             Positioned(
//               left: 20,
//               top: 0,
//               bottom: 0,
//               child: _currentImageIndex > 0
//                 ? IconButton(
//                     icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 36),
//                     onPressed: _previousImage,
//                   )
//                 : const SizedBox(),
//             ),
            
//             Positioned(
//               right: 20,
//               top: 0,
//               bottom: 0,
//               child: _currentImageIndex < _selectedImages.length - 1
//                 ? IconButton(
//                     icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 36),
//                     onPressed: _nextImage,
//                   )
//                 : const SizedBox(),
//             ),
            
//             // Botón de cerrar
//             Positioned(
//               right: 20,
//               top: 20,
//               child: IconButton(
//                 icon: const Icon(Icons.close, color: Colors.white, size: 36),
//                 onPressed: _closeImagePreview,
//               ),
//             ),
            
//             // Contador de imágenes
//             Positioned(
//               bottom: 20,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.7),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     'Imagen ${_currentImageIndex + 1} de ${_selectedImages.length}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 16,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showPropertyForm() {
//     showDialog(
//       context: context,
//       builder: (context) => Stack(
//         children: [
//           Dialog(
//             insetPadding: const EdgeInsets.all(20),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(16),
//             ),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 800),
//               child: Container(
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(16),
//                   color: Colors.white,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Encabezado del formulario
//                     Container(
//                       padding: const EdgeInsets.all(20),
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           colors: [const Color.fromARGB(255, 202, 121, 148), const Color.fromARGB(255, 164, 97, 119)],
//                           begin: Alignment.topLeft,
//                           end: Alignment.bottomRight,
//                         ),
//                         borderRadius: const BorderRadius.only(
//                           topLeft: Radius.circular(16),
//                           topRight: Radius.circular(16),
//                         ),
//                       ),
//                       child: Row(
//                         children: [
//                           Icon(
//                             _editingId == null ? Icons.add_home : Icons.edit,
//                             color: Colors.white,
//                             size: 28,
//                           ),
//                           const SizedBox(width: 12),
//                           Text(
//                             _editingId == null ? 'Nueva Propiedad' : 'Editar Propiedad',
//                             style: const TextStyle(
//                               fontSize: 22,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(Icons.close, color: Colors.white),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                               _clearForm();
//                             },
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Contenido del formulario
//                     Flexible(
//                       child: SingleChildScrollView(
//                         padding: const EdgeInsets.all(24),
//                         child: Form(
//                           key: _formKey,
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               // Sección: Información básica
//                               _buildSectionTitle('Información básica'),
//                               const SizedBox(height: 16),
                              
//                               // Tipo y Estado
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildDropdownField(
//                                       label: 'Tipo de propiedad',
//                                       icon: Icons.category,
//                                       value: _typeController.text,
//                                       items: [
//                                         DropdownMenuItem(
//                                           value: 'venta',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.sell, color: Colors.green, size: 18),
//                                               const SizedBox(width: 8),
//                                               const Text('Venta'),
//                                             ],
//                                           ),
//                                         ),
//                                         DropdownMenuItem(
//                                           value: 'alquiler',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.apartment, color: Colors.blue, size: 18),
//                                               const SizedBox(width: 8),
//                                               const Text('Alquiler'),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                       onChanged: (value) => _typeController.text = value!,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: _buildDropdownField(
//                                       label: 'Estado',
//                                       icon: Icons.info_outline,
//                                       value: _estadoController.text,
//                                       items: [
//                                         DropdownMenuItem(
//                                           value: 'disponible',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.check_circle, color: Colors.green, size: 18),
//                                               const SizedBox(width: 8),
//                                               const Text('Disponible'),
//                                             ],
//                                           ),
//                                         ),
//                                         DropdownMenuItem(
//                                           value: 'reservado',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.access_time, color: Colors.orange, size: 18),
//                                               const SizedBox(width: 8),
//                                               const Text('Reservado'),
//                                             ],
//                                           ),
//                                         ),
//                                         DropdownMenuItem(
//                                           value: 'vendido',
//                                           child: Row(
//                                             children: [
//                                               Icon(Icons.not_interested, color: Colors.red, size: 18),
//                                               const SizedBox(width: 8),
//                                               const Text('Vendido'),
//                                             ],
//                                           ),
//                                         ),
//                                       ],
//                                       onChanged: (value) => _estadoController.text = value!,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),
                              
//                               // Título y Precio
//                               _buildInputField(
//                                 controller: _titleController,
//                                 label: 'Título de la propiedad',
//                                 icon: Icons.title,
//                                 validator: (value) => value!.isEmpty ? 'El título es requerido' : null,
//                               ),
//                               const SizedBox(height: 16),
                              
//                               _buildInputField(
//                                 controller: _priceController,
//                                 label: 'Precio',
//                                 icon: Icons.attach_money,
//                                 keyboardType: TextInputType.number,
//                                 prefixText: '\$ ',
//                                 validator: (value) => value!.isEmpty ? 'El precio es requerido' : null,
//                               ),
//                               const SizedBox(height: 16),
                              
//                               _buildInputField(
//                                 controller: _locationController,
//                                 label: 'Ubicación',
//                                 icon: Icons.location_on,
//                                 validator: (value) => value!.isEmpty ? 'La ubicación es requerida' : null,
//                               ),
//                               const SizedBox(height: 24),
                              
//                               // Sección: Características
//                               _buildSectionTitle('Características'),
//                               const SizedBox(height: 16),
                              
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: _buildInputField(
//                                       controller: _bedroomsController,
//                                       label: 'Dormitorios',
//                                       icon: Icons.bed,
//                                       keyboardType: TextInputType.number,
//                                       validator: (value) => value!.isEmpty ? 'Requerido' : null,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   Expanded(
//                                     child: _buildInputField(
//                                       controller: _bathroomsController,
//                                       label: 'Baños',
//                                       icon: Icons.bathroom,
//                                       keyboardType: TextInputType.number,
//                                       validator: (value) => value!.isEmpty ? 'Requerido' : null,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
                              
//                               _buildInputField(
//                                 controller: _areaController,
//                                 label: 'Área (m²)',
//                                 icon: Icons.square_foot,
//                                 keyboardType: TextInputType.number,
//                                 suffixText: 'm²',
//                                 validator: (value) => value!.isEmpty ? 'El área es requerida' : null,
//                               ),
//                               const SizedBox(height: 24),
                              
//                               // Sección: Descripción
//                               _buildSectionTitle('Descripción'),
//                               const SizedBox(height: 16),
                              
//                               TextFormField(
//                                 controller: _descriptionController,
//                                 decoration: InputDecoration(
//                                   labelText: 'Descripción detallada',
//                                   alignLabelWithHint: true,
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: Colors.grey.shade300),
//                                   ),
//                                   enabledBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: Colors.grey.shade300),
//                                   ),
//                                   focusedBorder: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                     borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
//                                   ),
//                                   filled: true,
//                                   fillColor: Colors.grey.shade50,
//                                   prefixIcon: const Icon(Icons.description),
//                                   contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//                                 ),
//                                 maxLines: 5,
//                                 validator: (value) => value!.isEmpty ? 'La descripción es requerida' : null,
//                               ),
//                               const SizedBox(height: 24),
                              
//                               // Sección: Imágenes
//                               _buildSectionTitle('Imágenes'),
//                               const SizedBox(height: 16),
                              
//                               Center(
//                                 child: Container(
//                                   width: double.infinity,
//                                   padding: const EdgeInsets.all(20),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade50,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade200),
//                                   ),
//                                   child: Column(
//                                     children: [
//                                       Icon(
//                                         Icons.photo_library,
//                                         size: 48,
//                                         color: const Color.fromARGB(255, 202, 121, 148),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       const Text(
//                                         'Selecciona imágenes de la propiedad',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Puedes seleccionar múltiples imágenes y ordenarlas',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       ElevatedButton.icon(
//                                         onPressed: _pickImages,
//                                         icon: const Icon(Icons.add_photo_alternate),
//                                         label: const Text('Seleccionar Imágenes'),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: const Color.fromARGB(255, 202, 121, 148),
//                                           foregroundColor: Colors.white,
//                                           padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(30),
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
                              
//                               if (_selectedImages.isNotEmpty) ...[
//                                 const SizedBox(height: 20),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                   children: [
//                                     Text(
//                                       'Imágenes seleccionadas (${_selectedImages.length})',
//                                       style: const TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     Text(
//                                       'La primera imagen será la principal',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Colors.grey.shade600,
//                                         fontStyle: FontStyle.italic,
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
                                
//                                 // Previsualización de imágenes con miniaturas
//                                 Container(
//                                   height: 120,
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade100,
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: ListView.builder(
//                                     scrollDirection: Axis.horizontal,
//                                     itemCount: _selectedImages.length,
//                                     itemBuilder: (context, index) {
//                                       return Padding(
//                                         padding: const EdgeInsets.all(8.0),
//                                         child: Stack(
//                                           children: [
//                                             // Miniatura de la imagen
//                                             GestureDetector(
//                                               onTap: () => _showFullImagePreview(index),
//                                               child: Container(
//                                                 width: 100,
//                                                 height: 100,
//                                                 decoration: BoxDecoration(
//                                                   border: index == 0 
//                                                     ? Border.all(
//                                                         color: const Color.fromARGB(255, 202, 121, 148),
//                                                         width: 3,
//                                                       )
//                                                     : null,
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   boxShadow: [
//                                                     BoxShadow(
//                                                       color: Colors.black.withOpacity(0.1),
//                                                       blurRadius: 4,
//                                                       offset: const Offset(0, 2),
//                                                     ),
//                                                   ],
//                                                 ),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.circular(8),
//                                                   child: kIsWeb
//                                                     ? Image.network(
//                                                         _selectedImages[index].path,
//                                                         fit: BoxFit.cover,
//                                                       )
//                                                     : Image.file(
//                                                         File(_selectedImages[index].path),
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                 ),
//                                               ),
//                                             ),
                                            
//                                             // Botón para eliminar la imagen
//                                             Positioned(
//                                               right: -5,
//                                               top: -5,
//                                               child: Material(
//                                                 color: Colors.transparent,
//                                                 child: InkWell(
//                                                   onTap: () {
//                                                     setState(() {
//                                                       _selectedImages.removeAt(index);
//                                                     });
//                                                   },
//                                                   borderRadius: BorderRadius.circular(20),
//                                                   child: Container(
//                                                     padding: const EdgeInsets.all(4),
//                                                     decoration: BoxDecoration(
//                                                       color: Colors.red,
//                                                       shape: BoxShape.circle,
//                                                       boxShadow: [
//                                                         BoxShadow(
//                                                           color: Colors.black.withOpacity(0.2),
//                                                           blurRadius: 2,
//                                                           offset: const Offset(0, 1),
//                                                         ),
//                                                       ],
//                                                     ),
//                                                     child: const Icon(
//                                                       Icons.close,
//                                                       size: 16,
//                                                       color: Colors.white,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                             ),
                                            
//                                             // Indicador de imagen principal
//                                             if (index == 0)
//                                               Positioned(
//                                                 left: 5,
//                                                 top: 5,
//                                                 child: Container(
//                                                   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
//                                                   decoration: BoxDecoration(
//                                                     color: const Color.fromARGB(255, 202, 121, 148),
//                                                     borderRadius: BorderRadius.circular(4),
//                                                   ),
//                                                   child: const Text(
//                                                     'Principal',
//                                                     style: TextStyle(
//                                                       color: Colors.white,
//                                                       fontSize: 10,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                 ),
//                                               ),
//                                           ],
//                                         ),
//                                       );
//                                     },
//                                   ),
//                                 ),
                                
//                                 const SizedBox(height: 16),
                                
//                                 // Lista reordenable de imágenes
//                                 Container(
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.grey.shade50,
//                                     borderRadius: BorderRadius.circular(12),
//                                     border: Border.all(color: Colors.grey.shade200),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Ordenar imágenes',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         'Arrastra las imágenes para cambiar su orden o usa los botones para moverlas',
//                                         style: TextStyle(
//                                           fontSize: 14,
//                                           color: Colors.grey.shade600,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
                                      
//                                       ReorderableListView.builder(
//                                         shrinkWrap: true,
//                                         physics: const NeverScrollableScrollPhysics(),
//                                         itemCount: _selectedImages.length,
//                                         onReorder: (oldIndex, newIndex) {
//                                           setState(() {
//                                             if (newIndex > oldIndex) {
//                                               newIndex -= 1;
//                                             }
//                                             final item = _selectedImages.removeAt(oldIndex);
//                                             _selectedImages.insert(newIndex, item);
//                                           });
//                                         },
//                                         itemBuilder: (context, index) {
//                                           final image = _selectedImages[index];
//                                           return Card(
//                                             key: ValueKey(image.path),
//                                             margin: const EdgeInsets.only(bottom: 8),
//                                             child: ListTile(
//                                               leading: ClipRRect(
//                                                 borderRadius: BorderRadius.circular(4),
//                                                 child: SizedBox(
//                                                   width: 60,
//                                                   height: 60,
//                                                   child: kIsWeb
//                                                     ? Image.network(
//                                                         image.path,
//                                                         fit: BoxFit.cover,
//                                                       )
//                                                     : Image.file(
//                                                         File(image.path),
//                                                         fit: BoxFit.cover,
//                                                       ),
//                                                 ),
//                                               ),
//                                               title: Row(
//                                                 children: [
//                                                   Text(
//                                                     'Imagen ${index + 1}',
//                                                     style: const TextStyle(fontWeight: FontWeight.bold),
//                                                   ),
//                                                   if (index == 0)
//                                                     Container(
//                                                       margin: const EdgeInsets.only(left: 8),
//                                                       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
//                                                       decoration: BoxDecoration(
//                                                         color: const Color.fromARGB(255, 202, 121, 148),
//                                                         borderRadius: BorderRadius.circular(4),
//                                                       ),
//                                                       child: const Text(
//                                                         'Principal',
//                                                         style: TextStyle(
//                                                           color: Colors.white,
//                                                           fontSize: 12,
//                                                         ),
//                                                       ),
//                                                     ),
//                                                 ],
//                                               ),
//                                               subtitle: Text(
//                                                 image.name,
//                                                 maxLines: 1,
//                                                 overflow: TextOverflow.ellipsis,
//                                               ),
//                                               trailing: Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   IconButton(
//                                                     icon: const Icon(Icons.arrow_upward),
//                                                     onPressed: index > 0 ? () => _moveImageUp(index) : null,
//                                                     tooltip: 'Mover arriba',
//                                                     color: index > 0 ? Colors.blue : Colors.grey,
//                                                   ),
//                                                   IconButton(
//                                                     icon: const Icon(Icons.arrow_downward),
//                                                     onPressed: index < _selectedImages.length - 1 
//                                                       ? () => _moveImageDown(index) 
//                                                       : null,
//                                                     tooltip: 'Mover abajo',
//                                                     color: index < _selectedImages.length - 1 
//                                                       ? Colors.blue 
//                                                       : Colors.grey,
//                                                   ),
//                                                   IconButton(
//                                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                                     onPressed: () {
//                                                       setState(() {
//                                                         _selectedImages.removeAt(index);
//                                                       });
//                                                     },
//                                                     tooltip: 'Eliminar',
//                                                   ),
//                                                 ],
//                                               ),
//                                             ),
//                                           );
//                                         },
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
                    
//                     // Pie del formulario con botones
//                     Container(
//                       padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//                       decoration: BoxDecoration(
//                         color: Colors.grey.shade50,
//                         borderRadius: const BorderRadius.only(
//                           bottomLeft: Radius.circular(16),
//                           bottomRight: Radius.circular(16),
//                         ),
//                         border: Border(
//                           top: BorderSide(color: Colors.grey.shade200),
//                         ),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           OutlinedButton.icon(
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                               _clearForm();
//                             },
//                             icon: const Icon(Icons.cancel),
//                             label: const Text('Cancelar'),
//                             style: OutlinedButton.styleFrom(
//                               foregroundColor: Colors.grey.shade700,
//                               side: BorderSide(color: Colors.grey.shade300),
//                               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                             ),
//                           ),
//                           const SizedBox(width: 16),
//                           ElevatedButton.icon(
//                             onPressed: _submitProperty,
//                             icon: Icon(_editingId == null ? Icons.save : Icons.update),
//                             label: Text(_editingId == null ? 'Guardar Propiedad' : 'Actualizar Propiedad'),
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color.fromARGB(255, 202, 121, 148),
//                               foregroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                               elevation: 2,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
          
//           // Diálogo de previsualización de imagen
//           if (_showImagePreview && _selectedImages.isNotEmpty)
//             _buildImagePreviewDialog(),
//         ],
//       ),
//     );
//   }

//   // Método para construir títulos de sección
//   Widget _buildSectionTitle(String title) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.grey.shade800,
//           ),
//         ),
//         const SizedBox(height: 4),
//         Container(
//           width: 50,
//           height: 3,
//           decoration: BoxDecoration(
//             color: const Color.fromARGB(255, 202, 121, 148),
//             borderRadius: BorderRadius.circular(10),
//           ),
//         ),
//       ],
//     );
//   }

//   // Método para construir campos de entrada
//   Widget _buildInputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     String? prefixText,
//     String? suffixText,
//     String? Function(String?)? validator,
//   }) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         prefixIcon: Icon(icon),
//         prefixText: prefixText,
//         suffixText: suffixText,
//         contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       ),
//       keyboardType: keyboardType,
//       validator: validator,
//     );
//   }

//   // Método para construir campos de selección
//   Widget _buildDropdownField({
//     required String label,
//     required IconData icon,
//     required String value,
//     required List<DropdownMenuItem<String>> items,
//     required void Function(String?) onChanged,
//   }) {
//     return DropdownButtonFormField<String>(
//       value: value,
//       items: items,
//       onChanged: onChanged,
//       decoration: InputDecoration(
//         labelText: label,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: Colors.grey.shade300),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
//         ),
//         filled: true,
//         fillColor: Colors.grey.shade50,
//         prefixIcon: Icon(icon),
//         contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//       ),
//       icon: const Icon(Icons.arrow_drop_down_circle_outlined),
//       dropdownColor: Colors.white,
//       borderRadius: BorderRadius.circular(12),
//     );
//   }

//   void _clearForm() {
//     setState(() {
//       _editingId = null;
//       _titleController.clear();
//       _priceController.clear();
//       _locationController.clear();
//       _bedroomsController.clear();
//       _bathroomsController.clear();
//       _areaController.clear();
//       _descriptionController.clear();
//       _typeController.text = 'venta';
//       _estadoController.text = 'disponible'; 
//       _selectedImages = [];
//       _showImagePreview = false;
//     });
//   }

//   void _showErrorDialog(String message) {
//     if (!mounted) return;
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.error, color: Colors.red),
//             SizedBox(width: 8),
//             Text('Error'),
//           ],
//         ),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context), 
//             child: const Text('OK'),
//           )
//         ],
//       ),
//     );
//   }

//   void _confirmDelete(int id) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Row(
//           children: [
//             Icon(Icons.warning, color: Colors.orange),
//             SizedBox(width: 8),
//             Text('Confirmar'),
//           ],
//         ),
//         content: const Text('¿Estás seguro que deseas eliminar esta propiedad?'),
//         actions: [
//           TextButton.icon(
//             onPressed: () => Navigator.pop(context), 
//             icon: const Icon(Icons.cancel),
//             label: const Text('Cancelar'),
//           ),
//           TextButton.icon(
//             onPressed: () {
//               Navigator.pop(context);
//               _deleteProperty(id);
//             },
//             icon: const Icon(Icons.delete, color: Colors.red),
//             label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }
  
//   void _toggleAdvancedFilters() {
//     setState(() {
//       _showAdvancedFilters = !_showAdvancedFilters;
//     });
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     _titleController.dispose();
//     _priceController.dispose();
//     _locationController.dispose();
//     _bedroomsController.dispose();
//     _bathroomsController.dispose();
//     _areaController.dispose();
//     _descriptionController.dispose();
//     _typeController.dispose();
//     _estadoController.dispose(); 
//     _searchController.dispose();
//     _bedroomsFilterController.dispose();
//     _bathroomsFilterController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: const Navbar(),
//       body: NestedScrollView(
//         headerSliverBuilder: (context, innerBoxIsScrolled) {
//           return [
//             SliverToBoxAdapter(
//               child: Column(
//                 children: [
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [const Color.fromARGB(255, 121, 76, 91), const Color.fromARGB(255, 202, 121, 148)],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Panel de Administración',
//                           style: TextStyle(
//                             fontSize: 24,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                         const SizedBox(height: 8),
//                         Text(
//                           'Gestiona tus propiedades de forma sencilla',
//                           style: TextStyle(
//                             fontSize: 16,
//                             color: Colors.white.withOpacity(0.9),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: Card(
//                                 elevation: 4,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     children: [
//                                       const Icon(Icons.home, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         '$totalProperties', // Usar el getter para el total
//                                         style: const TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Text('Propiedades'),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Card(
//                                 elevation: 4,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     children: [
//                                       const Icon(Icons.sell, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         '$ventaProperties', // Usar el getter para propiedades en venta
//                                         style: const TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Text('En Venta'),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Card(
//                                 elevation: 4,
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(16),
//                                   child: Column(
//                                     children: [
//                                       const Icon(Icons.apartment, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
//                                       const SizedBox(height: 8),
//                                       Text(
//                                         '$alquilerProperties', // Usar el getter para propiedades en alquiler
//                                         style: const TextStyle(
//                                           fontSize: 24,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const Text('En Alquiler'),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
                  
//                   Container(
//                     color: Colors.grey.shade100,
//                     child: Column(
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             children: [
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: TextField(
//                                       controller: _searchController,
//                                       decoration: InputDecoration(
//                                         hintText: 'Buscar propiedades...',
//                                         prefixIcon: const Icon(Icons.search),
//                                         suffixIcon: _searchController.text.isNotEmpty
//                                             ? IconButton(
//                                                 icon: const Icon(Icons.clear),
//                                                 onPressed: () {
//                                                   _searchController.clear();
//                                                   _searchProperties();
//                                                 },
//                                               )
//                                             : null,
//                                         border: OutlineInputBorder(
//                                           borderRadius: BorderRadius.circular(30),
//                                         ),
//                                         filled: true,
//                                         fillColor: Colors.white,
//                                       ),
//                                       onSubmitted: (_) => _searchProperties(),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 16),
//                                   // Filtro de estado (disponible, reservado, vendido)
//                                   DropdownButton<String>(
//                                     value: _estadoFilter, 
//                                     items: [
//                                       const DropdownMenuItem(value: 'todos', child: Text('Todos')),
//                                       DropdownMenuItem(
//                                         value: 'disponible',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.check_circle, color: Colors.green, size: 18),
//                                             const SizedBox(width: 8),
//                                             const Text('Disponible'),
//                                           ],
//                                         ),
//                                       ),
//                                       DropdownMenuItem(
//                                         value: 'reservado',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.access_time, color: Colors.orange, size: 18),
//                                             const SizedBox(width: 8),
//                                             const Text('Reservado'),
//                                           ],
//                                         ),
//                                       ),
//                                       DropdownMenuItem(
//                                         value: 'vendido',
//                                         child: Row(
//                                           children: [
//                                             Icon(Icons.not_interested, color: Colors.red, size: 18),
//                                             const SizedBox(width: 8),
//                                             const Text('Vendido'),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                     onChanged: (value) {
//                                       setState(() {
//                                         _estadoFilter = value!;
//                                       });
//                                       _searchProperties();
//                                     },
//                                     hint: const Text('Estado'),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   IconButton(
//                                     icon: Icon(
//                                       _showAdvancedFilters ? Icons.filter_list_off : Icons.filter_list,
//                                       color: const Color.fromARGB(255, 202, 121, 148),
//                                     ),
//                                     onPressed: _toggleAdvancedFilters,
//                                     tooltip: 'Filtros avanzados',
//                                   ),
//                                   const SizedBox(width: 8),
//                                   ElevatedButton.icon(
//                                     onPressed: () {
//                                       _clearForm();
//                                       _showPropertyForm();
//                                     },
//                                     icon: const Icon(Icons.add),
//                                     label: const Text('Nueva Propiedad'),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: const Color.fromARGB(255, 202, 121, 148),
//                                       foregroundColor: Colors.white,
//                                       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//                                       shape: RoundedRectangleBorder(
//                                         borderRadius: BorderRadius.circular(30),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
                              
//                               if (_showAdvancedFilters)
//                                 AnimatedContainer(
//                                   duration: const Duration(milliseconds: 300),
//                                   margin: const EdgeInsets.only(top: 16),
//                                   padding: const EdgeInsets.all(16),
//                                   decoration: BoxDecoration(
//                                     color: Colors.white,
//                                     borderRadius: BorderRadius.circular(8),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black.withOpacity(0.05),
//                                         blurRadius: 5,
//                                         offset: const Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       const Text(
//                                         'Filtros avanzados',
//                                         style: TextStyle(
//                                           fontSize: 16,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                             child: TextField(
//                                               controller: _bedroomsFilterController,
//                                               decoration: const InputDecoration(
//                                                 labelText: 'Dormitorios (mín.)',
//                                                 border: OutlineInputBorder(),
//                                                 prefixIcon: Icon(Icons.bed),
//                                               ),
//                                               keyboardType: TextInputType.number,
//                                             ),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           Expanded(
//                                             child: TextField(
//                                               controller: _bathroomsFilterController,
//                                               decoration: const InputDecoration(
//                                                 labelText: 'Baños (mín.)',
//                                                 border: OutlineInputBorder(),
//                                                 prefixIcon: Icon(Icons.bathroom),
//                                               ),
//                                               keyboardType: TextInputType.number,
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       const SizedBox(height: 16),
//                                       Row(
//                                         mainAxisAlignment: MainAxisAlignment.end,
//                                         children: [
//                                           TextButton(
//                                             onPressed: () {
//                                               _bedroomsFilterController.clear();
//                                               _bathroomsFilterController.clear();
//                                             },
//                                             child: const Text('Limpiar filtros'),
//                                           ),
//                                           const SizedBox(width: 16),
//                                           ElevatedButton(
//                                             onPressed: _searchProperties,
//                                             style: ElevatedButton.styleFrom(
//                                               backgroundColor: const Color.fromARGB(255, 202, 121, 148),
//                                               foregroundColor: Colors.white,
//                                             ),
//                                             child: const Text('Aplicar filtros'),
//                                           ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                             ],
//                           ),
//                         ),
//                         TabBar(
//                           controller: _tabController,
//                           tabs: const [
//                             Tab(text: 'Todas las Propiedades'),
//                             Tab(text: 'En Venta'),
//                             Tab(text: 'En Alquiler'),
//                           ],
//                           labelColor: const Color.fromARGB(255, 202, 121, 148),
//                           unselectedLabelColor: Colors.grey,
//                           indicatorColor: const Color.fromARGB(255, 202, 121, 148),
//                           onTap: (index) {
//                             setState(() {
//                               if (index == 0) {
//                                 _filterType = 'todos';
//                               } else if (index == 1) {
//                                 _filterType = 'venta';
//                               } else if (index == 2) {
//                                 _filterType = 'alquiler';
//                               }
//                             });
//                             _searchProperties();
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ];
//         },
//         body: TabBarView(
//           controller: _tabController,
//           children: [
//             _buildPropertyList(filteredProperties),
//             _buildPropertyList(properties.where((p) => p['tipo'] == 'venta').toList()),
//             _buildPropertyList(properties.where((p) => p['tipo'] == 'alquiler').toList()),
//           ],
//         ),
//       ),
//     );
//   }
  
//   Widget _buildPropertyList(List<dynamic> propertyList) {
//     if (isLoading) {
//       return const Center(
//         child: CircularProgressIndicator(
//           valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 202, 121, 148)),
//         ),
//       );
//     }
    
//     if (propertyList.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.home_work, size: 64, color: Colors.grey.shade400),
//             const SizedBox(height: 16),
//             Text(
//               'No hay propiedades disponibles',
//               style: TextStyle(
//                 fontSize: 18,
//                 color: Colors.grey.shade600,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               'Intenta con otros filtros de búsqueda',
//               style: TextStyle(
//                 fontSize: 14,
//                 color: Colors.grey.shade500,
//               ),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton.icon(
//               onPressed: () {
//                 _clearForm();
//                 _showPropertyForm();
//               },
//               icon: const Icon(Icons.add),
//               label: const Text('Agregar Propiedad'),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color.fromARGB(255, 202, 121, 148),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       );
//     }
    
//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: propertyList.length,
//       itemBuilder: (context, index) {
//         final property = propertyList[index];
//         debugPrint('Propiedad #${index + 1}: ID=${property['id']}, Estado=${property['estado']}');
        
//         return Card(
//           margin: const EdgeInsets.only(bottom: 16),
//           elevation: 3,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               LayoutBuilder(
//                 builder: (context, constraints) {
//                   final isWideScreen = constraints.maxWidth > 600;
                  
//                   if (isWideScreen) {
//                     return Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: const BorderRadius.only(
//                                 topLeft: Radius.circular(12),
//                                 bottomLeft: Radius.circular(12),
//                               ),
//                               child: property['imageSrc'] != null && 
//                                       (property['imageSrc'] as List).isNotEmpty
//                                   ? Image.network(
//                                       'http://localhost:3004${property['imageSrc'][0]}',
//                                       height: 240,
//                                       width: 300,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, __, ___) => Container(
//                                         height: 240,
//                                         width: 300,
//                                         color: Colors.grey.shade300,
//                                         child: const Icon(Icons.home, size: 64, color: Colors.white),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 240,
//                                       width: 300,
//                                       color: Colors.grey.shade300,
//                                       child: const Icon(Icons.home, size: 64, color: Colors.white),
//                                     ),
//                             ),
//                             Positioned(
//                               top: 10,
//                               left: 10,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: property['tipo'] == 'venta' ? Colors.green : Colors.blue,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   property['tipo'] == 'venta' ? 'VENTA' : 'ALQUILER',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Banner de estado (reservado o vendido)
//                             if (property['estado'] != null && property['estado'] != 'disponible')
//                               Positioned(
//                                 top: 10,
//                                 right: 10,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: property['estado'] == 'reservado' ? Colors.orange : Colors.red,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     property['estado'] == 'reservado' ? 'RESERVADO' : 'VENDIDO',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
                        
//                         Expanded(
//                           child: Padding(
//                             padding: const EdgeInsets.all(16),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text(
//                                   property['title'],
//                                   style: const TextStyle(
//                                     fontSize: 20,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 Row(
//                                   children: [
//                                     const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         property['location'],
//                                         style: TextStyle(color: Colors.grey.shade700),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   '\$${property['price']}',
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                    color: Color.fromARGB(255, 202, 121, 148),
//                                   ),
//                                 ),
//                                 const SizedBox(height: 12),
//                                 Text(
//                                   property['description'],
//                                   style: TextStyle(
//                                     color: Colors.grey.shade800,
//                                     fontSize: 14,
//                                   ),
//                                   maxLines: 3,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   children: [
//                                     _buildFeatureChip(Icons.bed, '${property['bedrooms']}'),
//                                     const SizedBox(width: 8),
//                                     _buildFeatureChip(Icons.bathroom, '${property['bathrooms']}'),
//                                     const SizedBox(width: 8),
//                                     _buildFeatureChip(Icons.square_foot, '${property['area']}m²'),
//                                   ],
//                                 ),
//                                 const SizedBox(height: 16),
//                                 Row(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   children: [
//                                     TextButton.icon(
//                                       onPressed: () => _editProperty(property),
//                                       icon: const Icon(Icons.edit, color: Colors.blue),
//                                       label: const Text('Editar', style: TextStyle(color: Colors.blue)),
//                                     ),
//                                     const SizedBox(width: 8),
//                                     TextButton.icon(
//                                       onPressed: () => _confirmDelete(property['id']),
//                                       icon: const Icon(Icons.delete, color: Colors.red),
//                                       label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     );
//                   } else {
//                     return Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Stack(
//                           children: [
//                             ClipRRect(
//                               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//                               child: property['imageSrc'] != null && 
//                                       (property['imageSrc'] as List).isNotEmpty
//                                   ? Image.network(
//                                       'http://localhost:3004${property['imageSrc'][0]}',
//                                       height: 200,
//                                       width: double.infinity,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (_, __, ___) => Container(
//                                         height: 200,
//                                         width: double.infinity,
//                                         color: Colors.grey.shade300,
//                                         child: const Icon(Icons.home, size: 64, color: Colors.white),
//                                       ),
//                                     )
//                                   : Container(
//                                       height: 200,
//                                       width: double.infinity,
//                                       color: Colors.grey.shade300,
//                                       child: const Icon(Icons.home, size: 64, color: Colors.white),
//                                     ),
//                             ),
//                             Positioned(
//                               top: 10,
//                               left: 10,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                 decoration: BoxDecoration(
//                                   color: property['tipo'] == 'venta' ? Colors.green : Colors.blue,
//                                   borderRadius: BorderRadius.circular(20),
//                                 ),
//                                 child: Text(
//                                   property['tipo'] == 'venta' ? 'VENTA' : 'ALQUILER',
//                                   style: const TextStyle(
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                     fontSize: 12,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             // Banner de estado (reservado o vendido)
//                             if (property['estado'] != null && property['estado'] != 'disponible')
//                               Positioned(
//                                 top: 10,
//                                 right: 10,
//                                 child: Container(
//                                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                                   decoration: BoxDecoration(
//                                     color: property['estado'] == 'reservado' ? Colors.orange : Colors.red,
//                                     borderRadius: BorderRadius.circular(20),
//                                   ),
//                                   child: Text(
//                                     property['estado'] == 'reservado' ? 'RESERVADO' : 'VENDIDO',
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                           ],
//                         ),
                        
//                         Padding(
//                           padding: const EdgeInsets.all(16),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 property['title'],
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               Row(
//                                 children: [
//                                   const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                                   const SizedBox(width: 4),
//                                   Expanded(
//                                     child: Text(
//                                       property['location'],
//                                       style: TextStyle(color: Colors.grey.shade700),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 '\$${property['price']}',
//                                 style: const TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color.fromARGB(255, 202, 121, 148),
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Text(
//                                 property['description'],
//                                 style: TextStyle(
//                                   color: Colors.grey.shade800,
//                                   fontSize: 14,
//                                 ),
//                                 maxLines: 3,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 children: [
//                                   _buildFeatureChip(Icons.bed, '${property['bedrooms']}'),
//                                   const SizedBox(width: 8),
//                                   _buildFeatureChip(Icons.bathroom, '${property['bathrooms']}'),
//                                   const SizedBox(width: 8),
//                                   _buildFeatureChip(Icons.square_foot, '${property['area']}m²'),
//                                 ],
//                               ),
//                               const SizedBox(height: 16),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.end,
//                                 children: [
//                                   TextButton.icon(
//                                     onPressed: () => _editProperty(property),
//                                     icon: const Icon(Icons.edit, color: Colors.blue),
//                                     label: const Text('Editar', style: TextStyle(color: Colors.blue)),
//                                   ),
//                                   const SizedBox(width: 8),
//                                   TextButton.icon(
//                                     onPressed: () => _confirmDelete(property['id']),
//                                     icon: const Icon(Icons.delete, color: Colors.red),
//                                     label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     );
//                   }
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   Widget _buildFeatureChip(IconData icon, String text) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 16, color: const Color.fromARGB(255, 202, 121, 148)),
//           const SizedBox(width: 4),
//           Text(text, style: const TextStyle(fontSize: 14)),
//         ],
//       ),
//     );
//   }
// }














































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
  List<dynamic> allProperties = []; 
  bool isLoading = true;
  final ImagePicker _picker = ImagePicker();
  List<XFile> _selectedImages = [];
  late TabController _tabController;
  String _filterType = 'todos';
  String _estadoFilter = 'todos'; 
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
  final _estadoController = TextEditingController(text: 'disponible');
  int? _editingId;
  
  // Para previsualización de imágenes
  int _currentImageIndex = 0;
  bool _showImagePreview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchProperties();
    _searchController.addListener(_onSearchChanged);
  }

  DateTime? _lastSearchTime;
  void _onSearchChanged() {
    final now = DateTime.now();
    _lastSearchTime = now;
    
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
        final data = json.decode(response.body);
        debugPrint('Propiedades recibidas: ${data.length}');
        setState(() {
          properties = data;
          allProperties = List.from(data);
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
  
  Future<void> _searchProperties() async {
    if (!mounted) return;
    
    setState(() => isLoading = true);
    
    try {
      final queryParams = <String, String>{};
      
      if (_searchController.text.isNotEmpty) {
        queryParams['query'] = _searchController.text;
      }
      
      if (_filterType != 'todos') {
        queryParams['type'] = _filterType;
      }
      
      if (_estadoFilter != 'todos') {
        queryParams['estado'] = _estadoFilter; 
      }
      
      if (_bedroomsFilterController.text.isNotEmpty) {
        queryParams['bedrooms'] = _bedroomsFilterController.text;
      }
      
      if (_bathroomsFilterController.text.isNotEmpty) {
        queryParams['bathrooms'] = _bathroomsFilterController.text;
      }
      
      final uri = Uri.http('localhost:3004', '/api/properties/search', queryParams);
      
      debugPrint('Buscando propiedades con: $queryParams');
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('Resultados de búsqueda: ${data.length}');
        setState(() {
          properties = data;
          // Si no hay filtros, actualizar también allProperties
          if (queryParams.isEmpty) {
            allProperties = List.from(data);
          }
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

  // Filtrar propiedades solo por estado (disponible, reservado, vendido)
  List<dynamic> get filteredProperties {
    if (_estadoFilter == 'todos') return properties;
    
    return properties.where((p) {
      return p['estado'] == _estadoFilter;
    }).toList();
  }

  // Obtener contadores para las propiedades usando allProperties
  int get totalProperties => allProperties.length;
  int get ventaProperties => allProperties.where((p) => p['tipo'] == 'venta').length;
  int get alquilerProperties => allProperties.where((p) => p['tipo'] == 'alquiler').length;

  Future<void> _pickImages() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1920,
      );
      if (images.isNotEmpty) {
        setState(() => _selectedImages.addAll(images));
      }
    } catch (e) {
      _showErrorDialog('Error al seleccionar imágenes: $e');
    }
  }

  // Mover imagen hacia arriba en la lista 
  void _moveImageUp(int index) {
    if (index <= 0) return;
    
    setState(() {
      final temp = _selectedImages[index];
      _selectedImages[index] = _selectedImages[index - 1];
      _selectedImages[index - 1] = temp;
    });
    
    // Añadir debug para verificar que la función se está ejecutando
    debugPrint('Imagen movida hacia arriba: índice $index');
  }

  // Mover imagen hacia abajo en la lista 
  void _moveImageDown(int index) {
    if (index >= _selectedImages.length - 1) return;
    
    setState(() {
      final temp = _selectedImages[index];
      _selectedImages[index] = _selectedImages[index + 1];
      _selectedImages[index + 1] = temp;
    });
    
    // Añadir debug para verificar que la función se está ejecutando
    debugPrint('Imagen movida hacia abajo: índice $index');
  }

  // Mostrar previsualización de imagen a tamaño completo
  void _showFullImagePreview(int index) {
    setState(() {
      _currentImageIndex = index;
      _showImagePreview = true;
    });
  }

  // Cerrar previsualización de imagen
  void _closeImagePreview() {
    setState(() {
      _showImagePreview = false;
    });
  }

  // Navegar a la imagen anterior
  void _previousImage() {
    if (_currentImageIndex > 0) {
      setState(() {
        _currentImageIndex--;
      });
    }
  }

  // Navegar a la imagen siguiente
  void _nextImage() {
    if (_currentImageIndex < _selectedImages.length - 1) {
      setState(() {
        _currentImageIndex++;
      });
    }
  }

  Future<void> _submitProperty() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final url = _editingId == null 
          ? 'http://localhost:3004/api/properties'
          : 'http://localhost:3004/api/properties/$_editingId';

      debugPrint('Enviando a: $url');
      debugPrint('Estado seleccionado: ${_estadoController.text}');

      var request = http.MultipartRequest(
        _editingId == null ? 'POST' : 'PUT',
        Uri.parse(url),
      );

      request.headers['Authorization'] = 'Bearer ${widget.token}';
      request.headers['Accept'] = 'application/json';

      request.fields.addAll({
        'title': _titleController.text,
        'price': _priceController.text,
        'location': _locationController.text,
        'bedrooms': _bedroomsController.text,
        'bathrooms': _bathroomsController.text,
        'area': _areaController.text,
        'description': _descriptionController.text,
        'tipo': _typeController.text,
        'estado': _estadoController.text, 
      });

      // Log de todos los campos que se envían
      request.fields.forEach((key, value) {
        debugPrint('Campo enviado: $key = $value');
      });

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

      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (!mounted) return;

      debugPrint('Respuesta del servidor ($url):');
      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: $responseData');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        Navigator.of(context).pop();
        
        // Forzar recarga completa
        setState(() {
          properties = [];
          allProperties = [];
          isLoading = true;
        });
        
        await _fetchProperties();
        _clearForm();
        
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
      // Mostrar indicador de carga
      setState(() => isLoading = true);
      
      final response = await http.delete(
        Uri.parse('http://localhost:3004/api/properties/$id'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (!mounted) return;

      // Log para depuración
      debugPrint('Respuesta de eliminación: ${response.statusCode}');
      debugPrint('Cuerpo de respuesta: ${response.body}');

      if (response.statusCode == 200) {
        // Forzar recarga completa
        setState(() {
          properties = [];
          allProperties = [];
          isLoading = true;
        });
        
        await _fetchProperties();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Propiedad eliminada correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception('Error al eliminar: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Error al eliminar propiedad: $e');
    }
  }

  // Agregar esta función para cargar imágenes existentes de una propiedad
  Future<void> _loadExistingImages(List<dynamic> imagePaths) async {
    if (imagePaths.isEmpty) return;
    
    setState(() => isLoading = true);
    
    try {
      List<XFile> loadedImages = [];
      
      for (String path in List<String>.from(imagePaths)) {
        final url = 'http://localhost:3004$path';
        final fileName = path.split('/').last;
        
        // Crear un XFile a partir de la URL
        final xFile = XFile(url, name: fileName);
        loadedImages.add(xFile);
      }
      
      setState(() {
        _selectedImages = loadedImages;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => isLoading = false);
      _showErrorDialog('Error al cargar imágenes existentes: $e');
    }
  }

  // Modificar el método _editProperty para cargar las imágenes existentes
  void _editProperty(Map<String, dynamic> property) {
    debugPrint('Editando propiedad: ${property['id']}');
    debugPrint('Estado actual: ${property['estado']}');
    
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
      _estadoController.text = property['estado'] ?? 'disponible'; 
      _selectedImages = []; // Limpiar imágenes seleccionadas
    });

    // Cargar imágenes existentes si hay
    if (property['imageSrc'] != null && (property['imageSrc'] as List).isNotEmpty) {
      _loadExistingImages(property['imageSrc']);
    }

    _showPropertyForm();
  }

  // Widget para mostrar la previsualización de imagen a tamaño completo
  Widget _buildImagePreviewDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withOpacity(0.9),
        child: Stack(
          children: [
            // Imagen central
            Center(
              child: Image.network(
                _selectedImages[_currentImageIndex].path,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 300,
                  height: 300,
                  color: Colors.grey.shade800,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.white, size: 64),
                      const SizedBox(height: 16),
                      Text(
                        'No se pudo cargar la imagen',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botones de navegación
            Positioned(
              left: 20,
              top: 0,
              bottom: 0,
              child: _currentImageIndex > 0
                ? Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 36),
                        onPressed: _previousImage,
                      ),
                    ),
                  )
                : const SizedBox(),
            ),
            
            Positioned(
              right: 20,
              top: 0,
              bottom: 0,
              child: _currentImageIndex < _selectedImages.length - 1
                ? Center(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 36),
                        onPressed: _nextImage,
                      ),
                    ),
                  )
                : const SizedBox(),
            ),
            
            // Botón de cerrar
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 36),
                  onPressed: _closeImagePreview,
                ),
              ),
            ),
            
            // Contador de imágenes
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Imagen ${_currentImageIndex + 1} de ${_selectedImages.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_currentImageIndex == 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 202, 121, 148),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRINCIPAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Miniaturas en la parte inferior
            Positioned(
              bottom: 70,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                child: Center(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _currentImageIndex = index;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _currentImageIndex == index 
                                ? const Color.fromARGB(255, 202, 121, 148)
                                : Colors.white,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(2),
                            child: Image.network(
                              _selectedImages[index].path,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey.shade800,
                                child: const Icon(Icons.broken_image, color: Colors.white, size: 24),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPropertyForm() {
    showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          Dialog(
            insetPadding: const EdgeInsets.all(20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Encabezado del formulario
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [const Color.fromARGB(255, 202, 121, 148), const Color.fromARGB(255, 164, 97, 119)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _editingId == null ? Icons.add_home : Icons.edit,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            _editingId == null ? 'Nueva Propiedad' : 'Editar Propiedad',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _clearForm();
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Contenido del formulario
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Sección: Información básica
                              _buildSectionTitle('Información básica'),
                              const SizedBox(height: 16),
                              
                              // Tipo y Estado
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Tipo de propiedad',
                                      icon: Icons.category,
                                      value: _typeController.text,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'venta',
                                          child: Row(
                                            children: [
                                              Icon(Icons.sell, color: Colors.green, size: 18),
                                              const SizedBox(width: 8),
                                              const Text('Venta'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'alquiler',
                                          child: Row(
                                            children: [
                                              Icon(Icons.apartment, color: Colors.blue, size: 18),
                                              const SizedBox(width: 8),
                                              const Text('Alquiler'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) => _typeController.text = value!,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildDropdownField(
                                      label: 'Estado',
                                      icon: Icons.info_outline,
                                      value: _estadoController.text,
                                      items: [
                                        DropdownMenuItem(
                                          value: 'disponible',
                                          child: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green, size: 18),
                                              const SizedBox(width: 8),
                                              const Text('Disponible'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'reservado',
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time, color: Colors.orange, size: 18),
                                              const SizedBox(width: 8),
                                              const Text('Reservado'),
                                            ],
                                          ),
                                        ),
                                        DropdownMenuItem(
                                          value: 'vendido',
                                          child: Row(
                                            children: [
                                              Icon(Icons.not_interested, color: Colors.red, size: 18),
                                              const SizedBox(width: 8),
                                              const Text('Vendido'),
                                            ],
                                          ),
                                        ),
                                      ],
                                      onChanged: (value) => _estadoController.text = value!,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Título y Precio
                              _buildInputField(
                                controller: _titleController,
                                label: 'Título de la propiedad',
                                icon: Icons.title,
                                validator: (value) => value!.isEmpty ? 'El título es requerido' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                controller: _priceController,
                                label: 'Precio',
                                icon: Icons.attach_money,
                                keyboardType: TextInputType.number,
                                prefixText: '\$ ',
                                validator: (value) => value!.isEmpty ? 'El precio es requerido' : null,
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                controller: _locationController,
                                label: 'Ubicación',
                                icon: Icons.location_on,
                                validator: (value) => value!.isEmpty ? 'La ubicación es requerida' : null,
                              ),
                              const SizedBox(height: 24),
                              
                              // Sección: Características
                              _buildSectionTitle('Características'),
                              const SizedBox(height: 16),
                              
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _bedroomsController,
                                      label: 'Dormitorios',
                                      icon: Icons.bed,
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _buildInputField(
                                      controller: _bathroomsController,
                                      label: 'Baños',
                                      icon: Icons.bathroom,
                                      keyboardType: TextInputType.number,
                                      validator: (value) => value!.isEmpty ? 'Requerido' : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              _buildInputField(
                                controller: _areaController,
                                label: 'Área (m²)',
                                icon: Icons.square_foot,
                                keyboardType: TextInputType.number,
                                suffixText: 'm²',
                                validator: (value) => value!.isEmpty ? 'El área es requerida' : null,
                              ),
                              const SizedBox(height: 24),
                              
                              // Sección: Descripción
                              _buildSectionTitle('Descripción'),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _descriptionController,
                                decoration: InputDecoration(
                                  labelText: 'Descripción detallada',
                                  alignLabelWithHint: true,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: Colors.grey.shade300),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
                                  ),
                                  filled: true,
                                  fillColor: Colors.grey.shade50,
                                  prefixIcon: const Icon(Icons.description),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                ),
                                maxLines: 5,
                                validator: (value) => value!.isEmpty ? 'La descripción es requerida' : null,
                              ),
                              const SizedBox(height: 24),
                              
                              // Sección: Imágenes
                              _buildSectionTitle('Imágenes'),
                              const SizedBox(height: 16),
                              
                              Center(
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        size: 48,
                                        color: const Color.fromARGB(255, 202, 121, 148),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Selecciona imágenes de la propiedad',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Puedes seleccionar múltiples imágenes y ordenarlas',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      ElevatedButton.icon(
                                        onPressed: _pickImages,
                                        icon: const Icon(Icons.add_photo_alternate),
                                        label: const Text('Seleccionar Imágenes'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color.fromARGB(255, 202, 121, 148),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(30),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              if (_selectedImages.isNotEmpty) ...[
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Imágenes seleccionadas (${_selectedImages.length})',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'La primera imagen será la principal',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                
                                // Previsualización de imágenes con miniaturas
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: _selectedImages.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Stack(
                                          children: [
                                            // Miniatura de la imagen
                                            GestureDetector(
                                              onTap: () => _showFullImagePreview(index),
                                              child: Container(
                                                width: 100,
                                                height: 100,
                                                decoration: BoxDecoration(
                                                  border: index == 0 
                                                    ? Border.all(
                                                        color: const Color.fromARGB(255, 202, 121, 148),
                                                        width: 3,
                                                      )
                                                    : null,
                                                  borderRadius: BorderRadius.circular(8),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black.withOpacity(0.1),
                                                      blurRadius: 4,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(8),
                                                  child: kIsWeb
                                                    ? Image.network(
                                                        _selectedImages[index].path,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(_selectedImages[index].path),
                                                        fit: BoxFit.cover,
                                                      ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Botón para eliminar la imagen
                                            Positioned(
                                              right: -5,
                                              top: -5,
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      _selectedImages.removeAt(index);
                                                    });
                                                  },
                                                  borderRadius: BorderRadius.circular(20),
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red,
                                                      shape: BoxShape.circle,
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.2),
                                                          blurRadius: 2,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            
                                            // Indicador de imagen principal
                                            if (index == 0)
                                              Positioned(
                                                left: 5,
                                                top: 5,
                                                child: Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: const Color.fromARGB(255, 202, 121, 148),
                                                    borderRadius: BorderRadius.circular(4),
                                                  ),
                                                  child: const Text(
                                                    'Principal',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Lista reordenable de imágenes - CORREGIDA
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade200),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ordenar imágenes',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Arrastra las imágenes para cambiar su orden o usa los botones para moverlas',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      
                                      ReorderableListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: _selectedImages.length,
                                        onReorder: (oldIndex, newIndex) {
                                          setState(() {
                                            if (newIndex > oldIndex) {
                                              newIndex -= 1;
                                            }
                                            final item = _selectedImages.removeAt(oldIndex);
                                            _selectedImages.insert(newIndex, item);
                                          });
                                        },
                                        itemBuilder: (context, index) {
                                          final image = _selectedImages[index];
                                          return Card(
                                            key: ValueKey(image.path),
                                            margin: const EdgeInsets.only(bottom: 8),
                                            child: ListTile(
                                              leading: ClipRRect(
                                                borderRadius: BorderRadius.circular(4),
                                                child: SizedBox(
                                                  width: 60,
                                                  height: 60,
                                                  child: kIsWeb
                                                    ? Image.network(
                                                        image.path,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.file(
                                                        File(image.path),
                                                        fit: BoxFit.cover,
                                                      ),
                                                ),
                                              ),
                                              title: Row(
                                                children: [
                                                  Text(
                                                    'Imagen ${index + 1}',
                                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                                  ),
                                                  if (index == 0)
                                                    Container(
                                                      margin: const EdgeInsets.only(left: 8),
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color.fromARGB(255, 202, 121, 148),
                                                        borderRadius: BorderRadius.circular(4),
                                                      ),
                                                      child: const Text(
                                                        'Principal',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              subtitle: Text(
                                                image.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  // Botón para mover hacia arriba - CORREGIDO
                                                  IconButton(
                                                    icon: const Icon(Icons.arrow_upward),
                                                    onPressed: index > 0 
                                                      ? () {
                                                          debugPrint('Botón arriba presionado para índice $index');
                                                          _moveImageUp(index);
                                                        } 
                                                      : null,
                                                    tooltip: 'Mover arriba',
                                                    color: index > 0 ? Colors.blue : Colors.grey,
                                                  ),
                                                  // Botón para mover hacia abajo - CORREGIDO
                                                  IconButton(
                                                    icon: const Icon(Icons.arrow_downward),
                                                    onPressed: index < _selectedImages.length - 1 
                                                      ? () {
                                                          debugPrint('Botón abajo presionado para índice $index');
                                                          _moveImageDown(index);
                                                        } 
                                                      : null,
                                                    tooltip: 'Mover abajo',
                                                    color: index < _selectedImages.length - 1 
                                                      ? Colors.blue 
                                                      : Colors.grey,
                                                  ),
                                                  // Botón para eliminar - CORREGIDO
                                                  IconButton(
                                                    icon: const Icon(Icons.delete, color: Colors.red),
                                                    onPressed: () {
                                                      debugPrint('Eliminando imagen en índice $index');
                                                      setState(() {
                                                        _selectedImages.removeAt(index);
                                                      });
                                                    },
                                                    tooltip: 'Eliminar',
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    
                    // Pie del formulario con botones
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(16),
                          bottomRight: Radius.circular(16),
                        ),
                        border: Border(
                          top: BorderSide(color: Colors.grey.shade200),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              _clearForm();
                            },
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.grey.shade700,
                              side: BorderSide(color: Colors.grey.shade300),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: _submitProperty,
                            icon: Icon(_editingId == null ? Icons.save : Icons.update),
                            label: Text(_editingId == null ? 'Guardar Propiedad' : 'Actualizar Propiedad'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 202, 121, 148),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Diálogo de previsualización de imagen
          if (_showImagePreview && _selectedImages.isNotEmpty)
            _buildImagePreviewDialog(),
        ],
      ),
    );
  }

  // Método para construir títulos de sección
  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 202, 121, 148),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  // Método para construir campos de entrada
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? prefixText,
    String? suffixText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon),
        prefixText: prefixText,
        suffixText: suffixText,
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }

  // Método para construir campos de selección
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String value,
    required List<DropdownMenuItem<String>> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: const Color.fromARGB(255, 202, 121, 148), width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      icon: const Icon(Icons.arrow_drop_down_circle_outlined),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(12),
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
      _estadoController.text = 'disponible'; 
      _selectedImages = [];
      _showImagePreview = false;
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
    _estadoController.dispose(); 
    _searchController.dispose();
    _bedroomsFilterController.dispose();
    _bathroomsFilterController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Navbar(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [const Color.fromARGB(255, 121, 76, 91), const Color.fromARGB(255, 202, 121, 148)],
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
                                      const Icon(Icons.home, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$totalProperties', // Usar el getter para el total
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
                                      const Icon(Icons.sell, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$ventaProperties', // Usar el getter para propiedades en venta
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
                                      const Icon(Icons.apartment, size: 32, color: Color.fromARGB(255, 202, 121, 148)),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$alquilerProperties', // Usar el getter para propiedades en alquiler
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
                                  // Filtro de estado (disponible, reservado, vendido)
                                  DropdownButton<String>(
                                    value: _estadoFilter, 
                                    items: [
                                      const DropdownMenuItem(value: 'todos', child: Text('Todos')),
                                      DropdownMenuItem(
                                        value: 'disponible',
                                        child: Row(
                                          children: [
                                            Icon(Icons.check_circle, color: Colors.green, size: 18),
                                            const SizedBox(width: 8),
                                            const Text('Disponible'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'reservado',
                                        child: Row(
                                          children: [
                                            Icon(Icons.access_time, color: Colors.orange, size: 18),
                                            const SizedBox(width: 8),
                                            const Text('Reservado'),
                                          ],
                                        ),
                                      ),
                                      DropdownMenuItem(
                                        value: 'vendido',
                                        child: Row(
                                          children: [
                                            Icon(Icons.not_interested, color: Colors.red, size: 18),
                                            const SizedBox(width: 8),
                                            const Text('Vendido'),
                                          ],
                                        ),
                                      ),
                                    ],
                                    onChanged: (value) {
                                      setState(() {
                                        _estadoFilter = value!;
                                      });
                                      _searchProperties();
                                    },
                                    hint: const Text('Estado'),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: Icon(
                                      _showAdvancedFilters ? Icons.filter_list_off : Icons.filter_list,
                                      color: const Color.fromARGB(255, 202, 121, 148),
                                    ),
                                    onPressed: _toggleAdvancedFilters,
                                    tooltip: 'Filtros avanzados',
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      _clearForm();
                                      _showPropertyForm();
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Nueva Propiedad'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 202, 121, 148),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
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
                                              backgroundColor: const Color.fromARGB(255, 202, 121, 148),
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
                          labelColor: const Color.fromARGB(255, 202, 121, 148),
                          unselectedLabelColor: Colors.grey,
                          indicatorColor: const Color.fromARGB(255, 202, 121, 148),
                          onTap: (index) {
                            setState(() {
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
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPropertyList(filteredProperties),
            _buildPropertyList(properties.where((p) => p['tipo'] == 'venta').toList()),
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
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromARGB(255, 202, 121, 148)),
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
                backgroundColor: const Color.fromARGB(255, 202, 121, 148),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: propertyList.length,
      itemBuilder: (context, index) {
        final property = propertyList[index];
        debugPrint('Propiedad #${index + 1}: ID=${property['id']}, Estado=${property['estado']}');
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWideScreen = constraints.maxWidth > 600;
                  
                  if (isWideScreen) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            // Banner de estado (reservado o vendido)
                            if (property['estado'] != null && property['estado'] != 'disponible')
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: property['estado'] == 'reservado' ? Colors.orange : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    property['estado'] == 'reservado' ? 'RESERVADO' : 'VENDIDO',
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
                                   color: Color.fromARGB(255, 202, 121, 148),
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
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                            // Banner de estado (reservado o vendido)
                            if (property['estado'] != null && property['estado'] != 'disponible')
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: property['estado'] == 'reservado' ? Colors.orange : Colors.red,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    property['estado'] == 'reservado' ? 'RESERVADO' : 'VENDIDO',
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
                                  color: Color.fromARGB(255, 202, 121, 148),
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
          Icon(icon, size: 16, color: const Color.fromARGB(255, 202, 121, 148)),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }
}