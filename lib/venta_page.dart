import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:dragontectapp/login_page.dart';
import 'venta_lista_page.dart';

class VentaPage extends StatefulWidget {
  @override
  _VentaPageState createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  final _imeiController = TextEditingController();
  final _facturaController = TextEditingController();
  final _tiendaController = TextEditingController();
  final _precioController = TextEditingController();

  String _monedaSeleccionada = 'USD';
  File? _imagenSeleccionada;
  bool _guardando = false;
  final picker = ImagePicker();

  Future<void> _seleccionarImagen() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imagenSeleccionada = File(pickedFile.path));
    }
  }

  Future<String> _convertirImagenABase64(File imagen) async {
    final bytes = await imagen.readAsBytes();
    return base64Encode(bytes);
  }

  // Future<void> _guardarVenta() async {
  //   final imei = _imeiController.text.trim();

  //   if (imei.isEmpty || _imagenSeleccionada == null) {
  //     _mostrarMensaje('Faltan campos obligatorios');
  //     return;
  //   }

  //   if (!RegExp(r'^\d{15}$').hasMatch(imei)) {
  //     _mostrarMensaje('El IMEI debe tener exactamente 15 dígitos numéricos');
  //     return;
  //   }

  //   setState(() => _guardando = true);

  //   try {
  //     final imagenBase64 = await _convertirImagenABase64(_imagenSeleccionada!);

  //     final ventaData = {
  //       'userId': FirebaseAuth.instance.currentUser!.uid,
  //       'imei': imei,
  //       'factura': _facturaController.text.trim(),
  //       'tienda': _tiendaController.text.trim(),
  //       'precio': double.tryParse(_precioController.text) ?? 0,
  //       'moneda': _monedaSeleccionada,
  //       'imagenBase64': imagenBase64,
  //       'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
  //     };

  //     await FirebaseFirestore.instance.collection('ventas').add(ventaData);
  //     _mostrarMensaje('Venta guardada correctamente');
  //     _nuevaVenta();
  //   } catch (e) {
  //     _mostrarMensaje('Error al guardar: $e');
  //   } finally {
  //     setState(() => _guardando = false);
  //   }
  // }

  Future<void> _guardarVenta() async {
    if (_imeiController.text.isEmpty || _imagenSeleccionada == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Faltan campos obligatorios')));
      return;
    }

    if (!RegExp(r'^\d{15}$').hasMatch(_imeiController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('El IMEI debe tener exactamente 15 dígitos numéricos'),
        ),
      );
      return;
    }
    setState(() => _guardando = true);

    try {
      final imagenBase64 = await _convertirImagenABase64(_imagenSeleccionada!);

      final ventaData = {
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'imei': _imeiController.text.trim(),
        'factura': _facturaController.text.trim(),
        'tienda': _tiendaController.text.trim(),
        'precio': double.tryParse(_precioController.text) ?? 0,
        'moneda': _monedaSeleccionada,
        'imagenBase64': imagenBase64,
        'fecha': DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
      };

      await FirebaseFirestore.instance.collection('ventas').add(ventaData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Venta guardada correctamente')));
      _nuevaVenta();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      setState(() => _guardando = false);
    }
  }

  // void _mostrarMensaje(String mensaje) {
  //   ScaffoldMessenger.of(
  //     context,
  //   ).showSnackBar(SnackBar(content: Text(mensaje)));
  // }

  void _nuevaVenta() {
    _imeiController.clear();
    _facturaController.clear();
    _tiendaController.clear();
    _precioController.clear();
    setState(() {
      _imagenSeleccionada = null;
      _monedaSeleccionada = 'USD';
    });
  }

  Future<void> _cerrarSesion() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registro de Venta'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            tooltip: 'Ver ventas',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => VentasListaPage()),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: _cerrarSesion,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildTextField(
                  _imeiController,
                  'IMEI (15 dígitos)',
                  TextInputType.number,
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _seleccionarImagen,
                  child: Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: _imagenSeleccionada != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _imagenSeleccionada!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          )
                        : Center(child: Text('Toca para seleccionar imagen')),
                  ),
                ),
                const SizedBox(height: 10),
                _buildTextField(
                  _facturaController,
                  'Código de Factura',
                  TextInputType.text,
                ),
                _buildTextField(
                  _tiendaController,
                  'Tienda / Puesto de Venta',
                  TextInputType.text,
                ),
                _buildTextField(
                  _precioController,
                  'Precio',
                  TextInputType.number,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _monedaSeleccionada,
                  items: ['USD', 'NIO']
                      .map(
                        (moneda) => DropdownMenuItem(
                          value: moneda,
                          child: Text(moneda),
                        ),
                      )
                      .toList(),
                  onChanged: (valor) =>
                      setState(() => _monedaSeleccionada = valor!),
                  decoration: InputDecoration(
                    labelText: 'Tipo de Moneda',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _guardando
                    ? CircularProgressIndicator()
                    : Column(
                        children: [
                          ElevatedButton.icon(
                            onPressed: _guardarVenta,
                            icon: Icon(Icons.save),
                            label: Text('Guardar'),
                            style: ElevatedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          OutlinedButton.icon(
                            onPressed: _nuevaVenta,
                            icon: Icon(Icons.refresh),
                            label: Text('Nueva Venta'),
                            style: OutlinedButton.styleFrom(
                              minimumSize: Size(double.infinity, 50),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType tipo,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        maxLength: label.contains('IMEI') ? 15 : null,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          counterText: '',
        ),
      ),
    );
  }
}
