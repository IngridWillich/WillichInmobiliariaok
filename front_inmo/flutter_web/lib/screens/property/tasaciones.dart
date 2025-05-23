
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../components/navbar.dart';
import '../../components/footer.dart'; 

class TasacionesPage extends StatelessWidget {
  const TasacionesPage({super.key});

  void _launchWhatsApp() async {
    final whatsappUrl = "https://wa.me/5493434662544?text=Hola,%20estoy%20interesado%20en%20realizar%20una%20tasación%20inmobiliaria";
    if (await canLaunch(whatsappUrl)) {
      await launch(whatsappUrl);
    } else {
      // Si no se puede abrir WhatsApp, no hacemos nada
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Scaffold(
      appBar: Navbar(),
      backgroundColor: Color.fromARGB(255, 241, 241, 241), // Mismo fondo que el Home
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Banner superior elegante
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
                      'TASACIONES INMOBILIARIAS',
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
                      'Valoración profesional y precisa de su propiedad',
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
                      child: const Text('Solicitar una tasación'),
                    ),
                  ],
                ),
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
                    // Foto del profesional (placeholder)
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
                          // Foto del profesional en versión móvil
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
                                  image: AssetImage('assets/rocioperfil.jpeg'),
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
                          'Como tasadora profesional, realizo cada tasación de manera objetiva, técnica y fundamentada, '
                          'utilizando criterios reconocidos dentro del ámbito inmobiliario y ajustados al tipo de propiedad '
                          'y finalidad de la tasación.',
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

            // Proceso de tasación
            Container(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              color: Color.fromARGB(255, 241, 241, 241), 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PROCESO DE TASACIÓN',
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
                  
                  // Proceso de tasación
                  isMobile
                      ? _buildMobileProcessSteps()
                      : _buildDesktopProcessSteps(),
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
                    '¿NECESITA CONOCER EL VALOR REAL DE SU PROPIEDAD?',
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
                    'Ya sea para vender, alquilar, sucesiones, divisiones de bienes o trámites bancarios, '
                    'una tasación profesional es fundamental.',
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
  
  Widget _buildMobileProcessSteps() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildProcessStep(
          '01',
          'Relevamiento del inmueble',
          'Realizo una visita al inmueble para relevar sus características físicas y funcionales. '
          'Verifico la superficie del terreno y de la edificación, estado de conservación, calidad constructiva, '
          'antigüedad, mejoras o refacciones, entorno y situación del inmueble. '
          'También registro datos fotográficos y catastrales.',
          Icons.home_work,
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          '02',
          'Análisis de documentación',
          'Solicito o verifico la documentación disponible, como planos, título o antecedentes posesorios '
          '(en caso de inmuebles sin escritura), y condiciones legales que puedan incidir en su valor '
          '(restricciones, servidumbres, afectaciones, etc.).',
          Icons.description,
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          '03',
          'Determinación de valores',
          'Para establecer el valor del inmueble aplico distintos enfoques, según corresponda: '
          'enfoque por el costo, clasificación de la edificación, enfoque comparativo de mercado '
          'y valoración del terreno.',
          Icons.calculate,
        ),
        const SizedBox(height: 30),
        _buildProcessStep(
          '04',
          'Informe de tasación',
          'Elaboro un informe técnico detallado que incluye memoria descriptiva del inmueble, '
          'metodología aplicada, cálculos, valores considerados y valor estimado final. '
          'El informe puede ser utilizado para venta, sucesiones, divisiones de bienes, '
          'trámites judiciales o bancarios, entre otros.',
          Icons.assignment,
        ),
      ],
    );
  }
  
  Widget _buildDesktopProcessSteps() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _buildProcessStep(
            '01',
            'Relevamiento del inmueble',
            'Realizo una visita al inmueble para relevar sus características físicas y funcionales. '
            'Verifico la superficie, estado de conservación, calidad constructiva y más.',
            Icons.home_work,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildProcessStep(
            '02',
            'Análisis de documentación',
            'Solicito o verifico la documentación disponible, como planos, título o antecedentes posesorios '
            'y condiciones legales que puedan incidir en su valor.',
            Icons.description,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildProcessStep(
            '03',
            'Determinación de valores',
            'Para establecer el valor del inmueble aplico distintos enfoques: costo, clasificación, '
            'comparativo de mercado y valoración del terreno.',
            Icons.calculate,
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: _buildProcessStep(
            '04',
            'Informe de tasación',
            'Elaboro un informe técnico detallado con memoria descriptiva, metodología, cálculos, '
            'valores considerados y valor estimado final.',
            Icons.assignment,
          ),
        ),
      ],
    );
  }
  
  Widget _buildProcessStep(String number, String title, String description, IconData icon) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            number,
            style: TextStyle(
               color: Color.fromARGB(255, 202, 121, 148),
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(icon, color: Colors.grey.shade800, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}