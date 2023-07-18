//autores Joel Bautista, Jhon chica, cristian quevedo, Jose Mejia
//Ultimo cambio 29/05/2005
//SENA-CBA 2023
//esta pantalla crea un dialog con todos los reportes

//importaciones de codigo

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../main.dart';

class ReportUtils {
  static void showReportOptions(BuildContext context,
      {required idPublic, required nameAutor, required namePublic}) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return CupertinoActionSheet(
          title: const Text(
            'Reportar',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Contenido inapropiado'),
              onPressed: () => _processReport(context, 'Contenido inapropiado',
                  idPublic, nameAutor, namePublic),
            ),
            CupertinoActionSheetAction(
              child: const Text('Spam'),
              onPressed: () => _processReport(
                  context, 'Spam', idPublic, nameAutor, namePublic),
            ),
            CupertinoActionSheetAction(
              child: const Text('Publicacion fradulenta'),
              onPressed: () => _processReport(context, 'Publicacion fradulenta',
                  idPublic, nameAutor, namePublic),
            ),
            CupertinoActionSheetAction(
              child: const Text('otros'),
              onPressed: () => _processReport(
                  context, 'otros', idPublic, nameAutor, namePublic),
            ),
          ],
          cancelButton: CupertinoActionSheetAction(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
        );
      },
    );
  }

  static Future<void> _processReport(BuildContext context, String reportType,
      String idPublic, String nameAutor, String namePublic) async {
    // Aquí puedes enviar una notificación al servidor o simplemente imprimir el tipo de reporte seleccionado
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    print(token);

    // enviar la información del registro al servidor
    http.post(
      Uri.parse('$url/sitem/reportes/'),
      headers: {
        'Authorization': '$token',
      },
      body: jsonEncode({
        'idPublic': idPublic,
        'reporte': reportType,
        'nameAutho': nameAutor,
        'namePublic': namePublic
      }),
    );
    print('Reporte: $reportType');
    Navigator.pop(context);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reporte enviado'),
          content: Text(
              'El reporte de $reportType ha sido enviado satisfactoriamente.'),
          actions: [
            TextButton(
                child: const Text('OK'),
                onPressed: () async {
                  Navigator.pop(context);
                }),
          ],
        );
      },
    );
  }
}
