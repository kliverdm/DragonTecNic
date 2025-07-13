import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class VentasListaPage extends StatelessWidget {
  const VentasListaPage({Key? key}) : super(key: key);

  String _formatearFecha(String fechaTexto) {
    try {
      final fecha = DateTime.parse(fechaTexto);
      return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
    } catch (_) {
      return fechaTexto;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Ventas')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ventas')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No hay ventas registradas.'));
          }

          final ventas = snapshot.data!.docs;

          return ListView.builder(
            itemCount: ventas.length,
            itemBuilder: (context, index) {
              final data = ventas[index].data() as Map<String, dynamic>;
              final imei = data['imei'] ?? '';
              final factura = data['factura'] ?? '';
              final tienda = data['tienda'] ?? '';
              final precio = data['precio'] ?? 0;
              final moneda = data['moneda'] ?? 'USD';
              final fecha = data['fecha'] ?? '';
              final imagenBase64 = data['imagenBase64'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: imagenBase64 != null
                      ? Image.memory(
                          base64Decode(imagenBase64),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image_not_supported),
                  title: Text('IMEI: $imei'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Factura: $factura'),
                      Text('Tienda: $tienda'),
                      Text('Precio: $precio $moneda'),
                      Text('Fecha: ${_formatearFecha(fecha)}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
