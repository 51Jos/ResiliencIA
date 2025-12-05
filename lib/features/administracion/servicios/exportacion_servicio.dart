import 'dart:io';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import '../modelos/estudiante_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

/// Servicio para exportar datos de estudiantes a Excel
class ExportacionServicio {
  /// Exporta la lista de estudiantes a un archivo Excel
  /// Retorna la ruta del archivo generado o los bytes en web
  Future<dynamic> exportarEstudiantesAExcel({
    required List<EstudianteInfo> estudiantes,
    String? nombreArchivo,
  }) async {
    try {
      // Crear el archivo Excel
      final excel = Excel.createExcel();

      // Crear la hoja de estudiantes
      final sheet = excel['Estudiantes'];

      // Eliminar todas las hojas por defecto excepto "Estudiantes"
      final sheetNames = excel.tables.keys.toList();
      for (var sheetName in sheetNames) {
        if (sheetName != 'Estudiantes') {
          excel.delete(sheetName);
        }
      }

      // Definir el estilo del encabezado
      final headerStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#4A90A4'),
        fontColorHex: ExcelColor.fromHexString('#FFFFFF'),
      );

      // Agregar encabezados
      final headers = [
        'Código',
        'Nombre Completo',
        'Email',
        'Facultad',
        'Carrera',
        'Último Nivel de Ansiedad',
        'Último Puntaje',
        'Fecha Último Test',
        'Total de Evaluaciones',
        'Requiere Atención',
        'Fecha de Registro',
      ];

      for (var i = 0; i < headers.length; i++) {
        final cell = sheet.cell(
          CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0),
        );
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      // Agregar datos de estudiantes
      for (var i = 0; i < estudiantes.length; i++) {
        final estudiante = estudiantes[i];
        final rowIndex = i + 1;

        // Código
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.codigo);

        // Nombre Completo
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.nombreCompleto);

        // Email
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.email);

        // Facultad
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.facultad ?? 'N/A');

        // Carrera
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.programa ?? 'N/A');

        // Último Nivel de Ansiedad
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 5, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.ultimoNivelAnsiedad?.nombre ?? 'Sin evaluaciones');

        // Último Puntaje
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 6, rowIndex: rowIndex))
            .value = estudiante.puntajeUltimoTest != null
            ? IntCellValue(estudiante.puntajeUltimoTest!)
            : TextCellValue('N/A');

        // Fecha Último Test
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 7, rowIndex: rowIndex))
            .value = TextCellValue(
          estudiante.fechaUltimoTest != null
              ? _formatearFecha(estudiante.fechaUltimoTest!)
              : 'N/A',
        );

        // Total de Evaluaciones
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 8, rowIndex: rowIndex))
            .value = IntCellValue(estudiante.totalTests);

        // Requiere Atención
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 9, rowIndex: rowIndex))
            .value = TextCellValue(estudiante.requiereAtencion ? 'Sí' : 'No');

        // Fecha de Registro
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 10, rowIndex: rowIndex))
            .value = TextCellValue(_formatearFecha(estudiante.fechaRegistro));
      }

      // Ajustar ancho de columnas automáticamente
      for (var i = 0; i < headers.length; i++) {
        sheet.setColumnWidth(i, 20);
      }

      // Generar el archivo
      final fileBytes = excel.encode();
      if (fileBytes == null) {
        throw Exception('Error al generar el archivo Excel');
      }

      // Generar nombre del archivo si no se proporciona
      final fileName = nombreArchivo ??
          'estudiantes_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';

      if (kIsWeb) {
        // En web, descargar el archivo directamente
        final blob = html.Blob([fileBytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        html.Url.revokeObjectUrl(url);
        return fileName;
      } else {
        // En móvil/desktop, guardar en almacenamiento local
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      }
    } catch (e) {
      throw Exception('Error al exportar a Excel: $e');
    }
  }

  /// Formatea una fecha a string legible
  String _formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fecha);
  }
}
