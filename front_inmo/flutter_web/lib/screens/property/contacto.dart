import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart'; 
class ContactoPage extends StatelessWidget {
  const ContactoPage({super.key});

  Future<void> _launchWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/5493434662544?text=Hola,%20me%20gustaría%20obtener%20más%20información");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

  Future<void> _launchFacebook() async {
    const facebookUrl = "https://www.facebook.com/InmoRocioWillich";
    if (await canLaunchUrl(Uri.parse(facebookUrl))) {
      await launchUrl(Uri.parse(facebookUrl));
    }
  }

  Future<void> _launchInstagram() async {
    const instagramUrl = "https://www.instagram.com/willichinmobiliaria";
    if (await canLaunchUrl(Uri.parse(instagramUrl))) {
      await launchUrl(Uri.parse(instagramUrl));
    }
  }

  Future<void> _launchEmail() async {
    final emailUrl = Uri.parse("mailto:inmobiliariawillich@gmail.com");
    if (await canLaunchUrl(emailUrl)) {
      await launchUrl(emailUrl);
    }
  }

  Future<void> _launchMaps() async {
    final mapsUrl = Uri.parse("https://maps.google.com/?q=Blas Parera 516, Paraná, Entre Ríos");
    if (await canLaunchUrl(mapsUrl)) {
      await launchUrl(mapsUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Navbar(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner superior
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                    Colors.grey.shade700,
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
                      'CONTÁCTENOS',
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
                       color: Color.fromARGB(255, 202, 121, 148),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Estamos aquí para ayudarle con todas sus necesidades inmobiliarias',
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
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF25D366),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text('Contáctenos por WhatsApp'),
                    ),
                  ],
                ),
              ),
            ),

            // Información de contacto
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24), 
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'INFORMACIÓN DE CONTACTO',
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
                    color: Color.fromARGB(255, 202, 121, 148),
                  ),
                  const SizedBox(height: 24),
                  
                  // Contactos 
                  _buildCompactContactInfo(),
                ],
              ),
            ),

            // Mapa y dirección
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24), // Padding reducido
              color: Colors.grey.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NUESTRA UBICACIÓN',
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
                     color: Color.fromARGB(255, 202, 121, 148),
                  ),
                  const SizedBox(height: 24),
                  
                  // Información 
                  Container(
                    padding: const EdgeInsets.all(16), // Padding reducido
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildInfoRow(
                          icon: Icons.location_on,
                          title: 'Dirección',
                          content: 'Blas Parera 516, Paraná, Entre Ríos',
                          onTap: _launchMaps,
                        ),
                        const Divider(),
                        _buildInfoRow(
                          icon: Icons.badge,
                          title: 'Matrícula',
                          content: 'Corredora Inmobiliaria Mat.: 1237',
                        ),
                       
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _launchMaps,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.grey.shade800,
                            ),
                            child: const Text('VER EN MAPAS'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactContactInfo() {
    return Column(
      children: [
        _buildContactChip(
          icon: Icons.phone,
          text: '+54 9 3434 66-2544',
          onTap: _launchWhatsApp,
          color: const Color(0xFF25D366),
        ),
        const SizedBox(height: 12),
        _buildContactChip(
          icon: Icons.facebook,
          text: 'Inmo Rocio Willich',
          onTap: _launchFacebook,
        ),
        const SizedBox(height: 12),
        _buildContactChip(
          icon: Icons.camera_alt,
          text: '@willichinmobiliaria',
          onTap: _launchInstagram,
        ),
        const SizedBox(height: 12),
        _buildContactChip(
          icon: Icons.email,
          text: 'inmobiliariawillich@gmail.com',
          onTap: _launchEmail,
        ),
      ],
    );
  }

  Widget _buildContactChip({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? Colors.grey.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade500),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 24, color: Colors.grey.shade800),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
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
}