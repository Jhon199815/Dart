import 'dart:io';
import 'dart:math';

class Cancion {
  String titulo;
  String artista;
  int duracionSeg; 
  String genero;
  double calificacion; 
  int reproducciones = 0;

  Cancion(this.titulo, this.artista, this.duracionSeg, this.genero, this.calificacion);

  void reproducir() {
    reproducciones++;
  }

  @override
  String toString() {
    final mm = (duracionSeg ~/ 60).toString().padLeft(2, '0');
    final ss = (duracionSeg % 60).toString().padLeft(2, '0');
    return '"$titulo" - $artista | $genero | $mm:$ss | ★${calificacion.toStringAsFixed(1)} | plays:$reproducciones';
    }
}

class Playlist {
  String nombre;
  List<Cancion> canciones = [];
  final _rand = Random();

  Playlist(this.nombre);

  void agregar(Cancion c) {
    canciones.add(c);
  }

  void quitar(int index) {
    if (index >= 0 && index < canciones.length) {
      canciones.removeAt(index);
    }
  }

  Cancion? reproducirAleatoria() {
    if (canciones.isEmpty) return null;
    final i = _rand.nextInt(canciones.length);
    final c = canciones[i];
    c.reproducir();
    return c;
  }

  int duracionTotalSeg() {
    int total = 0;
    for (final c in canciones) {
      total += c.duracionSeg;
    }
    return total;
  }

  List<Cancion> filtrarPorGenero(String g) {
    return canciones.where((c) => c.genero.toLowerCase() == g.toLowerCase()).toList();
  }

  Map<String, dynamic> estadisticas() {
    int totalrepro = 0;
    for (final c in canciones) {
      totalrepro += c.reproducciones;
    }

    Cancion? maescuchada;
    for (final c in canciones) {
      if (maescuchada == null || c.reproducciones > maescuchada.reproducciones) {
        maescuchada = c;
      }
    }

    Map<String, int> reprporgenero = {};
    for (final c in canciones) {
      reprporgenero[c.genero] = (reprporgenero[c.genero] ?? 0) + c.reproducciones;
    }

    return {
      'totalcanciones': canciones.length,
      'totalreproduciones': totalrepro,
      'maescuchada': maescuchada,
      'reprporgenero': reprporgenero,
    };
  }

  @override
  String toString() => 'Playlist "$nombre" (${canciones.length} canciones)';
}

void main() {
  Playlist? playlist;

  while (true) {
    print('1) crear playlit');
    print('2) agregar cancion');
    print('3) quitar cancion');
    print('4) listar canciones');
    print('5) reproducir aleatoria');
    print('6) duración total');
    print('7) filtrar por genero');
    print('8) estadisticas');
    print('0) salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('nombre de la playlit: ');
      final nombre = stdin.readLineSync() ?? 'mi Playlit';
      playlist = Playlist(nombre);
      print('creada: $playlist');

    } else if (op == '2') {
      if (playlist == null) {
        print('primero crea una playlit (opcion 1).');
        continue;
      }
      stdout.write('titulo: ');
      final titulo = stdin.readLineSync() ?? '';
      stdout.write('artista: ');
      final artista = stdin.readLineSync() ?? '';
      stdout.write('duracion en segundos (ej: 215): ');
      final durSeg = int.tryParse((stdin.readLineSync() ?? '0')) ?? 0;
      stdout.write('genero: ');
      final genero = stdin.readLineSync() ?? '';
      stdout.write('calificacion (0.0 a 5.0): ');
      final calif = double.tryParse((stdin.readLineSync() ?? '0').replaceAll(',', '.')) ?? 0.0;

      final c = Cancion(titulo, artista, durSeg, genero, calif);
      playlist.agregar(c);
      print('agregada: $c');

    } else if (op == '3') {
      if (playlist == null || playlist.canciones.isEmpty) {
        print('no hay canciones');
        continue;
      }
      for (int i = 0; i < playlist.canciones.length; i++) {
        print('#$i  ${playlist.canciones[i]}');
      }
      stdout.write('indice a quitar: ');
      final idx = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
      playlist.quitar(idx);
      print('ok');

    } else if (op == '4') {
      if (playlist == null) {
        print('crea una playlit primero.');
        continue;
      }
      if (playlist.canciones.isEmpty) {
        print('(playlit vacia)');
      } else {
        print('${playlist.nombre}');
        for (int i = 0; i < playlist.canciones.length; i++) {
          print('#$i  ${playlist.canciones[i]}');
        }
      }

    } else if (op == '5') {
      if (playlist == null) {
        print('crea una playlit primero.');
        continue;
      }
      final c = playlist.reproducirAleatoria();
      if (c == null) {
        print('playlit vacia.');
      } else {
        print('reproduciendo: $c');
      }

    } else if (op == '6') {
      if (playlist == null) {
        print('crea una playlit primero.');
        continue;
      }
      final total = playlist.duracionTotalSeg();
      final mm = (total ~/ 60).toString().padLeft(2, '0');
      final ss = (total % 60).toString().padLeft(2, '0');
      print('duracion total: $mm:$ss (${total}s)');

    } else if (op == '7') {
      if (playlist == null) {
        print('crea una playlit primero.');
        continue;
      }
      stdout.write('genero a filtrar: ');
      final g = stdin.readLineSync() ?? '';
      final res = playlist.filtrarPorGenero(g);
      if (res.isEmpty) {
        print('sin resultados para "$g".');
      } else {
        print('Resultados ($g) ');
        for (final c in res) {
          print(c);
        }
      }

    } else if (op == '8') {
      if (playlist == null) {
        print('crea una playlit primero.');
        continue;
      }
      final est = playlist.estadisticas();
      print('playlit: ${playlist.nombre}');
      print('total canciones: ${est['totalCanciones']}');
      print('total reproducciones: ${est['totalReproducciones']}');
      final top = est['maescuchada'] as Cancion?;
      print('más escuchada: ${top == null ? "(ninguna)" : top.titulo + " - " + top.artista + " (plays: " + top.reproducciones.toString() + ")"}');
      final reprporgenero = est['reprporgenero'] as Map<String, int>;
      if (reprporgenero.isEmpty) {
        print('reproducciones por genero: (sin datos)');
      } else {
        print('reproducciones por genero:');
        reprporgenero.forEach((g, n) => print('- $g: $n'));
      }

    } else if (op == '0') {
      print('salir');
      break;

    } else {
      print('no valida.');
    }
  }
}