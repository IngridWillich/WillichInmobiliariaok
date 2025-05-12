import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> _launchEmail(String email) async {
    final url = Uri.parse("mailto:$email");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final url = Uri.parse("https://wa.me/$phone?text=Hola,%20me%20gustaría%20obtener%20más%20información");
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade900,
            Colors.grey.shade800,
          ],
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila ultra compacta
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Columna Inmobiliaria
              Flexible(
                child: _buildContactColumn(
                  title: "WILLICH INMOBILIARIA",
                  items: [
                    _ContactItem(Icons.location_on, 'Blas Parera 516, Paraná', null),
                    _ContactItem(Icons.phone, '+54 9 3434 66-2544', 
                      () => _launchWhatsApp('5493434662544')),
                    _ContactItem(Icons.email, 'inmobiliariawillich@gmail.com', 
                      () => _launchEmail('inmobiliariawillich@gmail.com')),
                  ],
                ),
              ),

              // Columna Desarrollador
              Flexible(
                child: _buildContactColumn(
                  title: "DESARROLLO",
                  items: [
                    _ContactItem(Icons.person, 'Ingrid Willich', null),
                    _ContactItem(Icons.phone, '+54 9 3434 454 2323', 
                      () => _launchWhatsApp('5493434542323')),
                    _ContactItem(Icons.email, 'willichingrid@gmail.com', 
                      () => _launchEmail('willichingrid@gmail.com')),
                  ],
                ),
              ),
            ],
          ),

        
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 1,
                color: Colors.pink.shade300,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMicroIcon(Icons.facebook, () => _launchUrl('https://facebook.com/InmoRocioWillich')),
                  const SizedBox(width: 8),
                  _buildMicroIcon(Icons.camera_alt, () => _launchUrl('https://instagram.com/willichinmobiliaria')),
                  const SizedBox(width: 12),
                  Text(
                    '© ${DateTime.now().year}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactColumn({required String title, required List<_ContactItem> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.pink.shade300,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: _buildMicroContact(item),
        )),
      ],
    );
  }

  Widget _buildMicroContact(_ContactItem item) {
    return InkWell(
      onTap: item.onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            item.icon,
            size: 12,
            color: Colors.white.withOpacity(0.7),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              item.text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMicroIcon(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Icon(
        icon,
        size: 14,
        color: Colors.white.withOpacity(0.7),
      ),
    );
  }
}

class _ContactItem {
  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  _ContactItem(this.icon, this.text, this.onTap);
}