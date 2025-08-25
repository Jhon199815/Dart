import 'dart:io';

class archivo {
  String nombre;
  double tamanoMb;
  String tipo;          
  DateTime fechaCreacion;
  String ruta;          

  archivo(this.nombre, this.tamanoMb, this.tipo, this.ruta)
      : fechaCreacion = DateTime.now();

  @override
  String toString() {
    return '$nombre | ${tamanoMb.toStringAsFixed(2)} MB | $tipo | ${fechaCreacion.toLocal()} | $ruta';
  }
}

void main() {
  List<archivo> archivos = [];

  while (true) {
    print('1) agregar archivo');
    print('2) listar archivos');
    print('3) buscar por nombre');
    print('4) buscar por tipo');
    print('5) calcular espacio usado');
    print('6) organizar por fecha');
    print('7) organizar por tamano');
    print('8) transferir archivo entre carpetas');
    print('9) listar agrupados por carpeta');
    print('0) salir');
    stdout.write('opcion: ');
    String op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('nombre: ');
      String nombre = stdin.readLineSync() ?? '';

      stdout.write('tamano (MB): ');
      double tamMb = double.parse((stdin.readLineSync() ?? '0').replaceAll(',', '.'));

      stdout.write('tipo (doc,img,video,audio,otro o extension): ');
      String tipo = (stdin.readLineSync() ?? '').toLowerCase().trim();

      stdout.write('ruta (ej: /documentos, /fotos): ');
      String ruta = stdin.readLineSync() ?? '/';

      archivos.add(archivo(nombre, tamMb, tipo, ruta));
      print('agregado.');

    } else if (op == '2') {
      if (archivos.isEmpty) {
        print('(no hay archivos)');
      } else {
        print(' archivos');
        for (int i = 0; i < archivos.length; i++) {
          print('#$i  ${archivos[i]}');
        }
      }

    } else if (op == '3') {
      stdout.write('buscar nombre (contiene): ');
      String q = (stdin.readLineSync() ?? '').toLowerCase();
      List<archivo> res = [];
      for (final a in archivos) {
        if (a.nombre.toLowerCase().contains(q)) {
          res.add(a);
        }
      }
      if (res.isEmpty) {
        print('sin resultados');
      } else {
        print('resultados por nombre');
        for (final a in res) {
          print(a);
        }
      }

    } else if (op == '4') {
      stdout.write('tipo a buscar (ej: img, doc, pdf): ');
      String t = (stdin.readLineSync() ?? '').toLowerCase().trim();
      List<archivo> res = [];
      for (final a in archivos) {
        if (a.tipo == t) {
          res.add(a);
        }
      }
      if (res.isEmpty) {
        print('sin resultados.');
      } else {
        print('resultados por tipo ($t) ');
        for (final a in res) {
          print(a);
        }
      }

    } else if (op == '5') {
      double total = 0;
      for (final a in archivos) {
        total += a.tamanoMb;
      }
      print('espacio usado: ${total.toStringAsFixed(2)} MB');

    } else if (op == '6') {
      if (archivos.length < 2) {
        print('no hay suficientes archivos para ordenar');
      } else {
        stdout.write('orden (asc/desc): ');
        String ord = (stdin.readLineSync() ?? 'asc').toLowerCase().trim();
        archivos.sort((a, b) => a.fechaCreacion.compareTo(b.fechaCreacion));
        if (ord == 'desc') {
          archivos = archivos.reversed.toList();
        }
        print('ordenados por fecha ($ord). usa opcion 2 para verlos');
      }

    } else if (op == '7') {
      if (archivos.length < 2) {
        print('no hay suficientes archivos para ordenar.');
      } else {
        stdout.write('orden (asc,desc): ');
        String ord = (stdin.readLineSync() ?? 'asc').toLowerCase().trim();
        archivos.sort((a, b) => a.tamanoMb.compareTo(b.tamanoMb));
        if (ord == 'desc') {
          archivos = archivos.reversed.toList();
        }
        print('ordenados por tamano ($ord). usa opcion 2 para verlos.');
      }

    } else if (op == '8') {
      if (archivos.isEmpty) {
        print('no hay archivos para transferir.');
      } else {
        print('nelige un archivo a mover:');
        for (int i = 0; i < archivos.length; i++) {
          print('#$i  ${archivos[i]}');
        }
        stdout.write('indice: ');
        int idx = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        if (idx >= 0 && idx < archivos.length) {
          stdout.write('nueva ruta (ej: descargas, fotos,vacaciones): ');
          String nuevaRuta = stdin.readLineSync() ?? '/';
          archivos[idx].ruta = nuevaRuta;
          print('transferido a $nuevaRuta.');
        } else {
          print('indice invalido.');
        }
      }

    } else if (op == '9') {
      if (archivos.isEmpty) {
        print('(no hay archivos)');
      } else {
        Map<String, List<archivo>> porCarpeta = {};
        for (final a in archivos) {
          porCarpeta[a.ruta] = porCarpeta[a.ruta] ?? [];
          porCarpeta[a.ruta]!.add(a);
        }
        print('archivos por carpeta-');
        for (final ruta in porCarpeta.keys) {
          print('[$ruta]');
          for (final a in porCarpeta[ruta]!) {
            print(' - $a');
          }
        }
      }

    } else if (op == '0') {
      print('salit');
      break;

    } else {
      print('no valida.');
    }
  }
}
