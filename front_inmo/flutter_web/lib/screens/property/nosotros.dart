import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart'; 

class NosotrosPage extends StatelessWidget {
  const NosotrosPage({super.key});

  Future<void> _launchWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/5493434662544?text=Hola,%20me%20gustaría%20obtener%20más%20información%20sobre%20sus%20servicios");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

  Future<void> _launchFacebook() async {
    const facebookUrl = "https://www.facebook.com/willichinmobiliaria";
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      appBar: Navbar(),
      backgroundColor: Color.fromARGB(255, 241, 241, 241),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // parte degradada
            Container(
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
                      'SOBRE NOSOTROS',
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
                      color: Colors.pink,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Conozca a nuestro equipo y nuestra historia',
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
                      child: const Text('Contáctenos'),
                    ),
                  ],
                ),
              ),
            ),

            // Sección de presentación
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'WILLICH ROCIO INMOBILIARIA',
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
                  const SizedBox(height: 24),
                  
                  // Perfil ro
                  isMobile
                      ? _buildMobileProfileSection()
                      : _buildDesktopProfileSection(),
                  
                  const SizedBox(height: 40),
                  
                  // Misión y Visión
                  isMobile
                      ? _buildMobileMissionVision()
                      : _buildDesktopMissionVision(),
                ],
              ),
            ),

            // Sección de servicios
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Color.fromARGB(255, 241, 241, 241),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'NUESTROS SERVICIOS',
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
                  const SizedBox(height: 40),
                  
                  // Servicios
                  isMobile
                      ? _buildMobileServices()
                      : _buildDesktopServices(),
                ],
              ),
            ),

           
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Colors.white,
              child: isMobile 
                  ? _buildMobileClientGallery() 
                  : _buildDesktopClientGallery(),
            ),

            
            const Footer(),
          ],
        ),
      ),
    );
  }

 
  Widget _buildMobileProfileSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
     
        Container(
          width: 200,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(100),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Image.asset(
              'assets/rocioperfil.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Rocio Willich',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'Corredora Inmobiliaria Mat.: 1237',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        Text(
          'WILLICH INMOBILIARIA es una empresa de administración de propiedades que provee servicios de administración de casas, condominios, departamentos, etc., en Entre Ríos, Argentina. Nuestro equipo de profesionales tiene más de 5 años de experiencia en la administración de propiedades para inversionistas.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Text(
          'Nuestra meta es conseguir la mayor satisfacción de nuestros clientes.',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
            height: 1.6,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDesktopProfileSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //foto de la ro
        Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(125),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(125),
            child: Image.asset(
              'assets/rocioperfil.jpeg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rocio Willich',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Corredora Inmobiliaria Mat.: 1237',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'WILLICH INMOBILIARIA es una empresa de administración de propiedades que provee servicios de administración de casas, condominios, departamentos, etc., en Entre Ríos, Argentina. Nuestro equipo de profesionales tiene más de 5 años de experiencia en la administración de propiedades para inversionistas.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nuestra meta es conseguir la mayor satisfacción de nuestros clientes.',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMissionVision() {
    return Column(
      children: [
        _buildInfoCard(
          'NUESTRA MISIÓN',
          'Nuestro objetivo es brindar un servicio inmobiliario de alta calidad, responsable e idóneo tanto en la compra, venta o alquiler de propiedades, promoviendo la excelencia en el trato humano y profesional.',
          Icons.flag,
        ),
        const SizedBox(height: 24),
        _buildInfoCard(
          'NUESTRA VISIÓN',
          'Queremos brindarte la mejor opción, revolucionando el sector inmobiliario, a través de nuestros valores como el respeto y la transparencia de nuestros servicios.',
          Icons.remove_red_eye,
        ),
      ],
    );
  }

  Widget _buildDesktopMissionVision() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildInfoCard(
            'NUESTRA MISIÓN',
            'Nuestro objetivo es brindar un servicio inmobiliario de alta calidad, responsable e idóneo tanto en la compra, venta o alquiler de propiedades, promoviendo la excelencia en el trato humano y profesional.',
            Icons.flag,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildInfoCard(
            'NUESTRA VISIÓN',
            'Queremos brindarte la mejor opción, revolucionando el sector inmobiliario, a través de nuestros valores como: respeto, la transparencia de nuestros servicios.',
            Icons.remove_red_eye,
          ),
        ),
      ],
    );
  }

  Widget _buildMobileClientGallery() {
    return Column(
      children: [
        _buildClientImage('assets/clientes1.jpeg'),
        const SizedBox(height: 24),
        _buildClientImage('assets/clientes2.jpeg'),
        const SizedBox(height: 24),
        _buildClientImage('assets/clientes3.jpeg'),
      ],
    );
  }

  Widget _buildDesktopClientGallery() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildClientImage('assets/clientes1.jpeg'),
        const SizedBox(width: 24),
        _buildClientImage('assets/clientes2.jpeg'),
        const SizedBox(width: 24),
        _buildClientImage('assets/clientes3.jpeg'),
      ],
    );
  }

  Widget _buildClientImage(String imagePath) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          imagePath,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade800, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileServices() {
    return Column(
      children: [
        _buildServiceCard(
          'Administración de Propiedades',
          'Servicio completo de administración para inversionistas institucionales, propietarios o inversionistas individuales.',
          Icons.business,
        ),
        const SizedBox(height: 24),
        _buildServiceCard(
          'Comunicación con Inquilinos',
          'Trabajamos para proveer la mejor comunicación relacionada con inquilinos.',
          Icons.chat,
        ),
        const SizedBox(height: 24),
        _buildServiceCard(
          'Compra y Venta',
          'Asesoramiento profesional para la compra y venta de propiedades.',
          Icons.home_work,
        ),
        const SizedBox(height: 24),
        _buildServiceCard(
          'Alquileres',
          'Gestión completa de alquileres, desde la búsqueda hasta la administración.',
          Icons.home,
        ),
      ],
    );
  }

  Widget _buildDesktopServices() {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildServiceCard(
                'Administración de Propiedades',
                'Servicio completo de administración para inversionistas institucionales, propietarios o inversionistas individuales.',
                Icons.business,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildServiceCard(
                'Comunicación con Inquilinos',
                'Trabajamos para proveer la mejor comunicación relacionada con inquilinos.',
                Icons.chat,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildServiceCard(
                'Compra y Venta',
                'Asesoramiento profesional para la compra y venta de propiedades.',
                Icons.home_work,
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: _buildServiceCard(
                'Alquileres',
                'Gestión completa de alquileres, desde la búsqueda hasta la administración.',
                Icons.home,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(24),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade800, size: 40),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}