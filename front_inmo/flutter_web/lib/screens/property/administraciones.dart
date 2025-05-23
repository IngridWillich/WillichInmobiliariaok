



import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart'; 

class AdministracionesPage extends StatelessWidget {
  const AdministracionesPage({super.key});

  Future<void> _launchWhatsApp() async {
    final whatsappUrl = Uri.parse("https://wa.me/5493434662544?text=Hola,%20estoy%20interesado%20en%20sus%20servicios%20de%20administración%20de%20propiedades");
    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      appBar: Navbar(),
      backgroundColor: const Color.fromARGB(255, 241, 241, 241),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner superior
            Container(
              height: 280,
              width: double.infinity,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      image: const DecorationImage(
                        image: AssetImage('assets/rocioperfil.jpeg'),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black,
                          BlendMode.darken,
                        ),
                      ),
                    ),
                  ),
                  Container(
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
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'ADMINISTRACIÓN DE PROPIEDADES',
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
                          'Gestión profesional para su tranquilidad',
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
                          child: const Text('Consultar servicios'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Perfil profesional
            Container(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              color: Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isMobile) ...[
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
                        image: const DecorationImage(
                          image: AssetImage('assets/rocioperfil.jpeg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isMobile) ...[
                          Center(
                            child: Container(
                              width: 150,
                              height: 150,
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(75),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                                image: const DecorationImage(
                                  image: AssetImage('assets/profile_placeholder.jpg'),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                        const Text(
                          'Rocio Willich',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
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
                            'Mat. 1237',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Como administradora, mi función principal es brindar una gestión clara, eficiente y profesional, '
                          'ya sea para un consorcio de propietarios (edificio o complejo habitacional), un conjunto de casas '
                          'o incluso una sola propiedad particular, en los casos en que el dueño desea delegar la administración '
                          'de su inmueble.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade800,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: _launchWhatsApp,
                              icon: Icon(Icons.chat, color: Colors.grey.shade800),
                              label: Text('Contactar', style: TextStyle(color: Colors.grey.shade800)),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: Colors.grey.shade400),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Servicios
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: const Color.fromARGB(255, 241, 241, 241),
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
                     color: Color.fromARGB(255, 202, 121, 148),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Trabajo con:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 40),
                  
                  isMobile
                      ? _buildMobileServiceCards()
                      : _buildDesktopServiceCards(),
                ],
              ),
            ),
            
            // Beneficios
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BENEFICIOS DE NUESTRA ADMINISTRACIÓN',
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
                  const SizedBox(height: 40),
                  
                  GridView.count(
                    crossAxisCount: isMobile ? 1 : 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 24,
                    crossAxisSpacing: 24,
                    childAspectRatio: isMobile ? 4 : 2.5,
                    children: [
                      _buildBenefitItem('Gestión transparente y eficiente', Icons.visibility),
                      _buildBenefitItem('Atención personalizada', Icons.person),
                      _buildBenefitItem('Respuesta rápida ante emergencias', Icons.speed),
                      _buildBenefitItem('Mantenimiento preventivo', Icons.build),
                      _buildBenefitItem('Reportes periódicos detallados', Icons.description),
                      _buildBenefitItem('Asesoramiento legal', Icons.gavel),
                    ],
                  ),
                ],
              ),
            ),
            
            // Sección de contacto
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Colors.grey.shade900,
              child: Column(
                children: [
                  const Text(
                    '¿DESEA DELEGAR LA ADMINISTRACIÓN DE SU PROPIEDAD?',
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
                       color: Color.fromARGB(255, 202, 121, 148),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Contáctenos para conocer nuestros servicios y tarifas personalizadas.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _launchWhatsApp,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.grey.shade900,
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: const Text('CONTACTAR AHORA'),
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
  
  Widget _buildMobileServiceCards() {
    return Column(
      children: [
        _buildServiceCard(
          'Consorcios tradicionales',
          'Administración de edificios y complejos bajo el régimen de propiedad horizontal.',
          Icons.apartment,
        ),
        const SizedBox(height: 24),
        _buildServiceCard(
          'Conjuntos o barrios',
          'Gestión de conjuntos o barrios con espacios y servicios comunes.',
          Icons.holiday_village,
        ),
        const SizedBox(height: 24),
        _buildServiceCard(
          'Propiedades individuales',
          'Administración de casas particulares o alquiladas para propietarios que desean delegar la gestión.',
          Icons.home,
        ),
      ],
    );
  }
  
  Widget _buildDesktopServiceCards() {
    return Row(
      children: [
        Expanded(
          child: _buildServiceCard(
            'Consorcios tradicionales',
            'Administración de edificios y complejos bajo el régimen de propiedad horizontal.',
            Icons.apartment,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildServiceCard(
            'Conjuntos o barrios',
            'Gestión de conjuntos o barrios con espacios y servicios comunes.',
            Icons.holiday_village,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildServiceCard(
            'Propiedades individuales',
            'Administración de casas particulares o alquiladas para propietarios que desean delegar la gestión.',
            Icons.home,
          ),
        ),
      ],
    );
  }
  
  Widget _buildServiceCard(String title, String description, IconData icon) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 200,
      ),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.grey.shade800, size: 32),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBenefitItem(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade800, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}