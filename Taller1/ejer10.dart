import 'dart:io';

class resena {
  String usuario;
  int estrellas;       
  String comentario;
  DateTime fecha;
  int utilidad;

  resena(this.usuario, this.estrellas, this.comentario)
      : fecha = DateTime.now(),
        utilidad = 0;

  void marcarutil() {
    utilidad++;
  }

  String _estrellasTexto() {
    final llenas = List.filled(estrellas, '*').join();
    final vacias = List.filled(5 - estrellas, '-').join();
    return llenas + vacias;
  }

  @override
  String toString() {
    return '$usuario | ${_estrellasTexto()} | ${fecha.toLocal()} | util:$utilidad\n"$comentario"';
  }
}

void main() {
  List<resena> resenas = [];

  while (true) {
    print('1) agregar resena');
    print('2) listar resenas');
    print('3) promedio de calificaciones');
    print('4) filtrar por estrellas');
    print('5) marcar resena como util');
    print('6) resenas mas utiles (top 3)');
    print('7) estadisticas');
    print('0) salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('usuario: ');
      final user = stdin.readLineSync() ?? '';
      stdout.write('calificacion 1-5: ');
      int est = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
      if (est < 1) est = 1;
      if (est > 5) est = 5;
      stdout.write('comentario: ');
      final com = stdin.readLineSync() ?? '';
      final r = resena(user, est, com);
      resenas.add(r);
      print('agregada');

    } else if (op == '2') {
      if (resenas.isEmpty) {
        print('(no hay resenas)');
      } else {
        print('todas:');
        for (int i = 0; i < resenas.length; i++) {
          print('#$i  ${resenas[i]}\n');
        }
      }

    } else if (op == '3') {
      if (resenas.isEmpty) {
        print('promedio: 0.0 (sin resenas)');
      } else {
        int suma = 0;
        for (final r in resenas) {
          suma += r.estrellas;
        }
        final prom = suma / resenas.length;
        print('promedio de estrellas: ${prom.toStringAsFixed(2)} / 5');
      }

    } else if (op == '4') {
      stdout.write('estrellas a filtrar (1-5): ');
      int e = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
      if (e < 1) e = 1;
      if (e > 5) e = 5;
      final res = resenas.where((r) => r.estrellas == e).toList();
      if (res.isEmpty) {
        print('sin resenas de $e estrellas');
      } else {
        print('resenas de $e estrellas:');
        for (final r in res) {
          print('$r\n');
        }
      }

    } else if (op == '5') {
      if (resenas.isEmpty) {
        print('no hay resenas para marcar');
      } else {
        for (int i = 0; i < resenas.length; i++) {
          final r = resenas[i];
          print('#$i  ${r.usuario} | util:${r.utilidad} | ${r.estrellas}*');
        }
        stdout.write('indice a marcar util: ');
        final idx = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        if (idx >= 0 && idx < resenas.length) {
          resenas[idx].marcarutil();
          print('marcada como util');
        } else {
          print('indice invalido');
        }
      }

    } else if (op == '6') {
      if (resenas.isEmpty) {
        print('no hay resenas');
      } else {
        final copia = [...resenas];
        copia.sort((a, b) => b.utilidad.compareTo(a.utilidad));
        final top = copia.take(3).toList();
        print('mas utiles (top 3):');
        for (final r in top) {
          print('$r\n');
        }
      }

    } else if (op == '7') {
      final total = resenas.length;
      int suma = 0;
      final dist = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
      int utilTotal = 0;
      for (final r in resenas) {
        suma += r.estrellas;
        dist[r.estrellas] = (dist[r.estrellas] ?? 0) + 1;
        utilTotal += r.utilidad;
      }
      final prom = total == 0 ? 0.0 : (suma / total);
      print('estadisticas:');
      print('total resenas: $total');
      print('promedio: ${prom.toStringAsFixed(2)} / 5');
      print('distribucion: 1*=${dist[1]}, 2*=${dist[2]}, 3*=${dist[3]}, 4*=${dist[4]}, 5*=${dist[5]}');
      print('votos util totales: $utilTotal');

    } else if (op == '0') {
      print('salir');
      break;

    } else {
      print('opcion no valida');
    }
  }
}
