# Demo Printer Flutter (USB / Térmica)

Este proyecto es una demostración en **Flutter** para generar e imprimir tickets de venta, órdenes de despacho, cortes de caja y reportes generales en impresoras térmicas (58 mm / 80 mm) o impresoras estándar conectadas por **USB**, **Bluetooth** o **red**.

## 🚀 ¿Cómo funciona la impresión por USB?

En Windows, macOS, Linux y Android, las impresoras USB térmicas (ESC/POS) se instalan como impresoras del sistema o se comunican mediante los controladores del SO. El paquete `printing` junto con `pdf` permite:
1. Generar el documento PDF adaptado exactamente al ancho del papel (58 mm / 80 mm).
2. Mandar a imprimir directamente a la impresora USB seleccionada mediante el diálogo nativo de impresión (`Printing.layoutPdf`).
3. En caso de fallos o falta de driver nativo, abrir automáticamente la vista previa del sistema o diálogo de compartir como fallback.

## 📁 Estructura del proyecto

- `lib/main.dart`: Interfaz gráfica básica de prueba con botones para ejecutar las impresiones y selector de ancho de papel (58mm / 80mm).
- `lib/print_ticket.dart`: Lógica principal de generación de PDFs y funciones de impresión (`printTicket`, `printOrdenDespacho`, `printCorteCaja`, `printReporteCobranza`, `printReporteClientes`).
- `lib/format.dart`: Utilidades de formato de fechas y cantidades.

## 🛠️ Cómo ejecutar

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Ejecutar en Windows (o tu plataforma deseada)
flutter run -d windows
```
