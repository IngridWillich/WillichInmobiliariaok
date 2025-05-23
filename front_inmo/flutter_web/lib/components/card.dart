//  import 'package:flutter/material.dart';

// class PropertyCard extends StatelessWidget {
//   final String imageSrc;
//   final String tipo;
//   final String title;
//   final String price;
//   final String location;
//   final int bedrooms;
//   final int bathrooms;
//   final String area;
//   final String description;
//   final String buttonText;
//   final VoidCallback onButtonClick;

//   const PropertyCard({
//     super.key,
//     required this.imageSrc,
//     required this.title,
//     required this.tipo,
//     required this.price,
//     required this.location,
//     required this.bedrooms,
//     required this.bathrooms,
//     required this.area,
//     required this.description,
//     required this.buttonText,
//     required this.onButtonClick,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final bool isSmallScreen = MediaQuery.of(context).size.width < 800;

//     return Card(
//       elevation: 4,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//       margin: const EdgeInsets.all(8),
//       child: ConstrainedBox(
//         constraints: BoxConstraints(
//           minHeight: 420,
//           maxHeight: 480,
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Imagen con altura fija
//             ClipRRect(
//               borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
//               child: AspectRatio(
//                 aspectRatio: 16/9,
//                 child: Image.network(
//                   imageSrc,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     color: Colors.grey[300],
//                     child: const Icon(Icons.home, size: 40, color: Colors.grey),
//                   ),
//                 ),
//               ),
//             ),

            
//             Padding(
//               padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Precio
//                   Text(
//                     price,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.pink,
//                     ),
//                   ),
//                   const SizedBox(height: 6),

//                   // Título
//                   Text(
//                     title,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   const SizedBox(height: 6),

//                   // Ubicación
//                   Row(
//                     children: [
//                       const Icon(Icons.location_on, size: 16, color: Colors.grey),
//                       const SizedBox(width: 4),
//                       Expanded(
//                         child: Text(
//                           location,
//                           style: const TextStyle(color: Colors.grey),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Características en Wrap
//                   Wrap(
//                     spacing: 8,
//                     runSpacing: 8,
//                     children: [
//                       _buildFeature(Icons.king_bed, "$bedrooms Hab."),
//                       _buildFeature(Icons.bathtub, "$bathrooms Baños"),
//                       _buildFeature(Icons.aspect_ratio, "$area m²"),
//                     ],
//                   ),
//                   const SizedBox(height: 10),

//                   // Descripción
//                   SizedBox(
//                     height: 40, 
//                     child: Text(
//                       description,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: Colors.grey[700], fontSize: 13),
//                     ),
//                   ),
//                   const SizedBox(height: 12),

//                   // Botón 
//                   SizedBox(
//                     height: 42,
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed: onButtonClick,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: const Color.fromARGB(255, 255, 83, 141),
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.zero,
//                       ),
//                       child: Text(buttonText),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildFeature(IconData icon, String text) {
//     return Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 18, color: Colors.pink),
//         const SizedBox(width: 4),
//         Text(
//           text,
//           style: const TextStyle(fontSize: 12),
//         ),
//       ],
//     );
//   }
// }









import 'package:flutter/material.dart';

class PropertyCard extends StatelessWidget {
  final String imageSrc;
  final String tipo;
  final String title;
  final String price;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final String description;
  final String buttonText;
  final VoidCallback onButtonClick;
  final String? status; // Para manejar el estado (reservado/vendido)

  const PropertyCard({
    super.key,
    required this.imageSrc,
    required this.title,
    required this.tipo,
    required this.price,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.description,
    required this.buttonText,
    required this.onButtonClick,
    this.status, // Parámetro opcional para el estado
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 800;
    
    // Determinar si mostrar el banner de estado
    final bool showStatusBanner = status != null && 
                                 (status == 'reservado' || status == 'vendido');

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: 420,
          maxHeight: 480,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen con altura fija y posible banner de estado
            Stack(
              children: [
                // Imagen
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: AspectRatio(
                    aspectRatio: 16/9,
                    child: Image.network(
                      imageSrc,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.home, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                
                // Banner de tipo (venta/alquiler)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: tipo == 'venta' ? Colors.green : Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tipo.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                
                // Banner de estado (reservado/vendido) - Igual al de tipo pero en la esquina derecha
                if (showStatusBanner)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: status == 'reservado' ? Colors.orange : Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status!.toUpperCase(),
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
              padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio
                  Text(
                    price,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 202, 121, 148),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Título
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Ubicación
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          location,
                          style: const TextStyle(color: Colors.grey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Características en Wrap
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFeature(Icons.king_bed, "$bedrooms Hab."),
                      _buildFeature(Icons.bathtub, "$bathrooms Baños"),
                      _buildFeature(Icons.aspect_ratio, "$area m²"),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Descripción
                  SizedBox(
                    height: 40, 
                    child: Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Botón 
                  SizedBox(
                    height: 42,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onButtonClick,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:   Color.fromARGB(255, 202, 121, 148),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                      ),
                      child: Text(buttonText), 
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color:  Color.fromARGB(255, 202, 121, 148),),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}


