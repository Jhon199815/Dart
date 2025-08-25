import 'dart:io';
import 'dart:math';

class Ubicacion {
  String nombre;
  double lat;
  double lon;
  String categoria; 
  String notas;

  Ubicacion(this.nombre, this.lat, this.lon, this.categoria, this.notas);

  @override
  String toString() {
    return '$nombre | ${categoria.toUpperCase()} | '
           'lat:${lat.toStringAsFixed(5)} lon:${lon.toStringAsFixed(5)} | $notas';
  }
}

void main() {
  List<Ubicacion> lugares = [];

  while (true) {
    print('1) agregar ubicacion');
    print('2) listar ubicacion');
    print('3) eliminar ubicacion');
    print('4) buscar por categoria');
    print('5) distancia entre dos ubicaciones');
    print('0) salir');
    stdout.write('opcion: ');
    String op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('nombre: ');
      String nombre = stdin.readLineSync() ?? '';

      stdout.write('latitud: ');
      double lat = double.parse((stdin.readLineSync() ?? '0').replaceAll(',', '.'));

      stdout.write('longitud: ');
      double lon = double.parse((stdin.readLineSync() ?? '0').replaceAll(',', '.'));

      stdout.write('categoria (casa, trabajo, restaurante, hospital): ');
      String cat = (stdin.readLineSync() ?? '').toLowerCase().trim();
      if (cat != 'casa' && cat != 'trabajo' && cat != 'restaurante' && cat != 'hospital') {
        cat = 'casa';
      }

      stdout.write('notas: ');
      String notas = stdin.readLineSync() ?? '';

      lugares.add(Ubicacion(nombre, lat, lon, cat, notas));
      print('agregada.');

    } else if (op == '2') {
      if (lugares.isEmpty) {
        print('(no hay ubicaciones)');
      } else {
        print('ubicaciones: ');
        for (int i = 0; i < lugares.length; i++) {
          print('#$i  ${lugares[i]}');
        }
      }

    } else if (op == '3') {
      if (lugares.isEmpty) {
        print('(no hay ubicaciones)');
      } else {
        stdout.write('indice a eliminar: ');
        int idx = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        if (idx >= 0 && idx < lugares.length) {
          lugares.removeAt(idx);
          print('eliminada.');
        } else {
          print('indice inválido.');
        }
      }

    } else if (op == '4') {
      stdout.write('categoria (casa, trabajo, restaurante, hospital): ');
      String cat = (stdin.readLineSync() ?? '').toLowerCase().trim();

      List<Ubicacion> resultado = [];
      for (int i = 0; i < lugares.length; i++) {
        if (lugares[i].categoria == cat) {
          resultado.add(lugares[i]);
        }
      }

      if (resultado.isEmpty) {
        print('(no hay ubicaciones para esa categoria)');
      } else {
        print('Resultados ($cat)');
        for (int i = 0; i < resultado.length; i++) {
          print(resultado[i]);
        }
      }

    } else if (op == '5') {
      if (lugares.length < 2) {
        print('necesitas al menos 2 ubicaciones.');
      } else {
        print('elige dos indices:');
        for (int i = 0; i < lugares.length; i++) {
          print('#$i  ${lugares[i]}');
        }
        stdout.write('indice a: ');
        int a = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        stdout.write('indice b: ');
        int b = int.tryParse(stdin.readLineSync() ?? '') ?? -1;

        if (a >= 0 && a < lugares.length && b >= 0 && b < lugares.length) {
          double lat1 = lugares[a].lat;
          double lon1 = lugares[a].lon;
          double lat2 = lugares[b].lat;
          double lon2 = lugares[b].lon;

          
          const R = 6371.0;
          double dLat = (lat2 - lat1) * (pi / 180.0);
          double dLon = (lon2 - lon1) * (pi / 180.0);
          double rLat1 = lat1 * (pi / 180.0);
          double rLat2 = lat2 * (pi / 180.0);

          double aHarv = sin(dLat / 2) * sin(dLat / 2) +
              cos(rLat1) * cos(rLat2) * sin(dLon / 2) * sin(dLon / 2);
          double c = 2 * atan2(sqrt(aHarv), sqrt(1 - aHarv));
          double dKm = R * c;

          print('distancia aproximada: ${dKm.toStringAsFixed(2)} km');
        } else {
          print('indices invalidos.');
        }
      }

    } else if (op == '0') {
      print('salir');
      break;

    } else {
      print('opcion no valida.');
    }
  }
}