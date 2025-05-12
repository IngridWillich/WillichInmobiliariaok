import 'package:flutter/material.dart';
import 'package:flutter_web/screens/property/login.dart';

class Navbar extends StatefulWidget implements PreferredSizeWidget {
  const Navbar({super.key});

  @override
  NavbarState createState() => NavbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class NavbarState extends State<Navbar> {
  bool isDrawerOpen = false;

  void toggleDrawer() {
    setState(() {
      isDrawerOpen = !isDrawerOpen;
    });
    
    if (isDrawerOpen) {
      _showMobileMenu(context);
    }
  }

  void _showLoginDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
  }
  
  
  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min, 
            children: [
              _buildDrawerItem("Inicio", "/"),
              _buildDrawerItem("Ventas", "/venta"),
              _buildDrawerItem("Alquileres", "/alquiler"),
              _buildDrawerItem("Tasaciones", "/tasaciones"),
              _buildDrawerItem("Administraciones", "/administraciones"),
              _buildDrawerItem("Nosotros", "/sobreNosotros"),
              _buildDrawerItem("Contacto", "/contacto"),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CERRAR',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    ).then((_) {
      
      setState(() {
        isDrawerOpen = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= 800;

    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo clickeable para admin
          GestureDetector(
            onTap: () => _showLoginDialog(context),
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Image.asset(
                'assets/logito.png',
                width: 300, 
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
          if (isMobile)
            IconButton(
              icon: Icon(isDrawerOpen ? Icons.close : Icons.menu, color: Colors.white),
              onPressed: toggleDrawer,
            ),
        ],
      ),
      automaticallyImplyLeading: false,
      actions: [
        if (!isMobile) ...[
          const NavLink(title: "Inicio", route: "/"),
          const NavLink(title: "Nosotros", route: "/sobreNosotros"),
          const NavLink(title: "Alquiler", route: "/alquiler"),
          const NavLink(title: "Venta", route: "/venta"),
          const NavLink(title: "Tasaciones", route: "/tasaciones"),
          const NavLink(title: "Administraciones", route: "/administraciones"),
          const NavLink(title: "Contacto", route: "/contacto"),
          const SizedBox(width: 20),
        ],
      ],
    );
  }

  Widget _buildDrawerItem(String title, String route) {
    return ListTile(
      title: Text(
        title, 
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
      onTap: () {
        Navigator.pop(context); // Cierra el modal
        Navigator.pushNamed(context, route);
        setState(() {
          isDrawerOpen = false;
        });
      },
    );
  }
}

class NavLink extends StatelessWidget {
  final String title;
  final String route;

  const NavLink({super.key, required this.title, required this.route});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pushNamed(context, route),
      child: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}


