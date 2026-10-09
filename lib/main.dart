import 'package:flutter/material.dart';
import 'print_ticket.dart';

void main() {
  runApp(const DemoPrinterApp());
}

class DemoPrinterApp extends StatelessWidget {
  const DemoPrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Impresora USB / Térmica',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const PrinterHomePage(),
    );
  }
}

class PrinterHomePage extends StatefulWidget {
  const PrinterHomePage({super.key});

  @override
  State<PrinterHomePage> createState() => _PrinterHomePageState();
}

class _PrinterHomePageState extends State<PrinterHomePage> {
  double _anchoTicketMm = 58.0;

  Map<String, dynamic> get _config => {
        'nombre_negocio': 'Bear Helados & Café',
        'ancho_ticket_mm': _anchoTicketMm,
        'aplica_impuesto': true,
        'impuesto_porcentaje': 16.0,
      };

  final Map<String, dynamic> _sampleCredito = {
    'numero_factura': 'F-001089',
    'fecha_venta': DateTime.now().toIso8601String(),
    'fecha_vencimiento': DateTime.now().add(const Duration(days: 15)).toIso8601String(),
    'cliente_nombre': 'Juan Pérez',
    'cliente_codigo': 'CLI-042',
    'cliente_direccion': 'Av. Principal #123, Centro',
    'cliente_telefono': '555-0192',
    'vendedor_nombre': 'Carlos Gómez',
    'monto_total': 185.50,
    'items': [
      {
        'descripcion': 'Helado de Vainilla 1L',
        'detalle': 'Envase biodegradable',
        'cantidad': 2,
        'precio_unitario': 45.00,
      },
      {
        'descripcion': 'Café Americano 12oz',
        'detalle': 'Sin azúcar',
        'cantidad': 1,
        'precio_unitario': 35.50,
      },
      {
        'descripcion': 'Waffle Clásico',
        'detalle': 'Con mermelada de fresa',
        'cantidad': 1,
        'precio_unitario': 60.00,
      },
    ],
    'cuotas': [
      {'numero': 1, 'fecha_vencimiento': '2026-10-15', 'monto': 92.75},
      {'numero': 2, 'fecha_vencimiento': '2026-10-30', 'monto': 92.75},
    ],
  };

  final Map<String, dynamic> _sampleSesionCaja = {
    'id': 'CORTE-8821',
    'caja_nombre': 'Caja 01 - Principal',
    'usuario_nombre': 'María López',
    'fecha_apertura': DateTime.now().subtract(const Duration(hours: 8)).toIso8601String(),
    'fecha_cierre': DateTime.now().toIso8601String(),
    'monto_esperado': 1250.00,
    'monto_cierre_contado': 1250.00,
    'diferencia': 0.0,
    'notas': 'Cierre de turno sin novedades.',
  };

  final Map<String, dynamic> _sampleResumenCaja = {
    'monto_apertura': 200.00,
    'ventas': 850.00,
    'abonos': 300.00,
    'entradas': 50.00,
    'salidas': 150.00,
    'esperado': 1250.00,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impresión por USB / Térmica'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.print, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              'Configuración de Papel',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        const Text('Ancho del papel térmico:'),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<double>(
                            segments: const [
                              ButtonSegment<double>(
                                value: 58.0,
                                label: Text('58 mm (Estándar)'),
                                icon: Icon(Icons.receipt_long),
                              ),
                              ButtonSegment<double>(
                                value: 80.0,
                                label: Text('80 mm (Ancho)'),
                                icon: Icon(Icons.receipt),
                              ),
                            ],
                            selected: {_anchoTicketMm},
                            onSelectionChanged: (Set<double> selection) {
                              setState(() {
                                _anchoTicketMm = selection.first;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.receipt_long, color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(
                              'Impresión de Tickets',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            runPrintAction(context, () {
                              return printTicket(
                                config: _config,
                                credito: _sampleCredito,
                              );
                            });
                          },
                          icon: const Icon(Icons.receipt),
                          label: const Text('Imprimir Ticket de Venta'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            runPrintAction(context, () {
                              return printOrdenDespacho(
                                config: _config,
                                credito: _sampleCredito,
                              );
                            });
                          },
                          icon: const Icon(Icons.local_shipping),
                          label: const Text('Imprimir Orden de Despacho'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton.icon(
                          onPressed: () {
                            runPrintAction(context, () {
                              return printCorteCaja(
                                config: _config,
                                sesion: _sampleSesionCaja,
                                resumen: _sampleResumenCaja,
                              );
                            });
                          },
                          icon: const Icon(Icons.point_of_sale),
                          label: const Text('Imprimir Corte de Caja'),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.assessment, color: Colors.green),
                            const SizedBox(width: 8),
                            Text(
                              'Reportes Generales (A4 / Sistema)',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: () {
                            runPrintAction(context, () {
                              return printReporteCobranza(
                                config: _config,
                                reporte: {
                                  'periodo': 'Octubre 2026',
                                  'desde': '2026-10-01',
                                  'hasta': '2026-10-09',
                                  'creditos': [_sampleCredito],
                                  'lista_pagados': [],
                                  'lista_pendientes': [_sampleCredito],
                                  'totales': {'ventas': 185.50, 'cobrado': 0.0, 'saldo': 185.50},
                                  'resumen': {'total_creditos': 1, 'pagados': 0, 'pendientes': 1},
                                },
                              );
                            });
                          },
                          icon: const Icon(Icons.picture_as_pdf),
                          label: const Text('Generar Reporte de Cobranza'),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
