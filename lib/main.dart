import 'dart:io';
import 'package:flutter/material.dart';
import 'print_ticket.dart';
import 'raw_printer.dart';

void main() {
  runApp(const DemoPrinterApp());
}

class DemoPrinterApp extends StatelessWidget {
  const DemoPrinterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Demo Impresora USB / Térmica Directa',
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
  double _anchoTicketMm = 80.0;
  bool _useDirectRaw = true;
  List<String> _availablePrinters = [];
  String? _selectedPrinter;

  @override
  void initState() {
    super.initState();
    _loadPrinters();
  }

  void _loadPrinters() {
    if (Platform.isWindows) {
      final list = RawThermalPrinter.getWindowsPrinters();
      setState(() {
        _availablePrinters = list;
        if (list.isNotEmpty && _selectedPrinter == null) {
          // Buscar una con nombre POS, Thermal o Seleccionar la primera
          _selectedPrinter = list.firstWhere(
            (p) => p.toUpperCase().contains('POS') || p.toUpperCase().contains('THERMAL') || p.toUpperCase().contains('80'),
            orElse: () => list.first,
          );
        }
      });
    }
  }

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

  Future<void> _handlePrintTicket() async {
    if (_useDirectRaw && (Platform.isWindows || Platform.isLinux)) {
      if (_selectedPrinter == null || _selectedPrinter!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor seleccione una impresora USB.')),
        );
        return;
      }

      await runPrintAction(context, () async {
        final bytes = await RawThermalPrinter.generateTicketEscPos(
          config: _config,
          credito: _sampleCredito,
        );

        bool success = false;
        if (Platform.isWindows) {
          success = await RawThermalPrinter.printRawWindows(
            printerName: _selectedPrinter!,
            bytes: bytes,
          );
        } else if (Platform.isLinux) {
          success = await RawThermalPrinter.printRawLinux(
            printerName: _selectedPrinter!,
            bytes: bytes,
          );
        }

        if (success) {
          return '¡Ticket impreso directamente en ${_selectedPrinter!}!';
        } else {
          return 'No se pudo enviar el trabajo a la impresora USB. Verifique la conexión.';
        }
      });
    } else {
      // Fallback PDF tradicional
      await runPrintAction(context, () {
        return printTicket(
          config: _config,
          credito: _sampleCredito,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impresora Térmica USB (ESC/POS Directo)'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadPrinters,
            tooltip: 'Recargar Impresoras',
          ),
        ],
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
                            const Icon(Icons.usb, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              'Modo de Impresión',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Impresión Directa USB (ESC/POS 100% Térmico)'),
                          subtitle: const Text('Imprime al instante sin cuadro de diálogo ni ajuste de márgenes'),
                          value: _useDirectRaw,
                          onChanged: (val) {
                            setState(() => _useDirectRaw = val);
                          },
                        ),
                        if (_useDirectRaw && Platform.isWindows) ...[
                          const SizedBox(height: 8),
                          const Text('Impresora USB seleccionada:'),
                          const SizedBox(height: 4),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedPrinter,
                            isExpanded: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            items: _availablePrinters.map((p) {
                              return DropdownMenuItem(value: p, child: Text(p));
                            }).toList(),
                            onChanged: (val) {
                              setState(() => _selectedPrinter = val);
                            },
                          ),
                        ],
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
                            const Icon(Icons.print, color: Colors.deepOrange),
                            const SizedBox(width: 8),
                            Text(
                              'Ancho de Papel Térmico',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const Divider(),
                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<double>(
                            segments: const [
                              ButtonSegment<double>(
                                value: 80.0,
                                label: Text('80 mm (Recomendado)'),
                                icon: Icon(Icons.receipt),
                              ),
                              ButtonSegment<double>(
                                value: 58.0,
                                label: Text('58 mm'),
                                icon: Icon(Icons.receipt_long),
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
                              'Acciones de Impresión',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _handlePrintTicket,
                          icon: const Icon(Icons.print),
                          label: Text(
                            _useDirectRaw ? 'Imprimir Ticket Directo (USB ESC/POS)' : 'Imprimir Ticket (Vista Previa PDF)',
                          ),
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
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
                          label: const Text('Imprimir Orden de Despacho (PDF)'),
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
                          label: const Text('Imprimir Corte de Caja (PDF)'),
                          style: ElevatedButton.styleFrom(
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
