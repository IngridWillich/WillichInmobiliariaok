import 'package:flutter/material.dart';
import 'package:flutter_web/screens/property/administraciones.dart';
import 'package:flutter_web/screens/property/alquileresview.dart';
import 'package:flutter_web/screens/property/contacto.dart';
import 'package:flutter_web/screens/property/nosotros.dart';
import 'package:flutter_web/screens/property/tasaciones.dart';
import 'package:flutter_web/screens/property/ventaview.dart';

import "screens/property/home.dart";


MaterialColor myCustomColor = MaterialColor(0xFFFDA2EE, {
  50: const Color(0xFFFFF0FA),
  100: const Color(0xFFFFE0F5),
  200: const Color(0xFFFFCFEF),
  300: const Color(0xFFFFBDE9),
  400: const Color(0xFFFFB2E6),
  500: const Color(0xFFFDA2EE), // Color base
  600: const Color(0xFFF893E9),
  700: const Color(0xFFF683E4),
  800: const Color(0xFFF573DF),
  900: const Color(0xFFF253DA),
});   
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Willich Inmobiliaria',
      theme: ThemeData(
        primarySwatch: myCustomColor,
        
      ), 
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(),
       '/sobreNosotros': (context) =>const  NosotrosPage(),
       
         '/contacto': (context) => const ContactoPage(),
         '/alquiler':(context)=> const AlquilerPage(),
          '/venta':(context)=> const VentaPage(),
        '/tasaciones':(context)=> const TasacionesPage(),
        '/administraciones':(context)=> const AdministracionesPage(),
      },
    );
  }
}


