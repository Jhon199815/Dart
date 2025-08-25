import 'dart:io';

class notificacion {
  String titulo;
  String mensaje;
  String tipo;      
  DateTime fecha_hora;
  bool leida;

  notificacion(this.titulo, this.mensaje, this.tipo)
      : fecha_hora = DateTime.now(),
        leida = false;

  void marcarComoLeida() {
    leida = true;
  }

  @override
  String toString() {
    String estado = leida ? '✓' : '•';
    return '[$estado] ${tipo.toUpperCase()} | $titulo | ${fecha_hora.toLocal()} \n   $mensaje';
  }
}

class gestor_notificacion {
  List<notificacion> _items = [];

  notificacion crear(String titulo, String mensaje, String tipo) {
    if (!_esTipoValido(tipo)) {
      tipo = 'info';
    }
    final n = notificacion(titulo, mensaje, tipo);
    _items.add(n);
    return n;
  }

  void marcarComoLeida(int indice) {
    if (indice >= 0 && indice < _items.length) {
      _items[indice].marcarComoLeida();
    }
  }

  List<notificacion> filtrarPorTipo(String tipo) {
    return _items.where((n) => n.tipo == tipo).toList();
  }

  Map<String, int> estadisticas() {
    int total = _items.length;
    int leidas = _items.where((n) => n.leida).length;
    int noLeidas = total - leidas;
    int info = _items.where((n) => n.tipo == 'info').length;
    int advertencia = _items.where((n) => n.tipo == 'advertencia').length;
    int error = _items.where((n) => n.tipo == 'error').length;

    return {
      'total': total,
      'leidas': leidas,
      'noLeidas': noLeidas,
      'info': info,
      'advertencia': advertencia,
      'error': error,
    };
  }

  List<notificacion> todas() => _items;

  bool _esTipoValido(String t) {
    return t == 'info' || t == 'advertencia' || t == 'error';
  }
}

void main() {
  final gestor = gestor_notificacion();

  while (true) {
    print('simulador de notificaciones');
    print('1) crear notificacion');
    print('2) listar todas');
    print('3) marcar como leida');
    print('4) filtrar por tipo');
    print('5) ver estadísticas');
    print('0) salir');
    stdout.write('elige una opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('titulo: ');
      String titulo = stdin.readLineSync() ?? '';
      stdout.write('mensaje: ');
      String mensaje = stdin.readLineSync() ?? '';
      stdout.write('tipo (info / advertencia / error): ');
      String tipo = (stdin.readLineSync() ?? '').toLowerCase().trim();

      final n = gestor.crear(titulo, mensaje, tipo);
      print('creada:$n');

    } else if (op == '2') {
      final lista = gestor.todas();
      if (lista.isEmpty) {
        print('(No hay notificaciones)');
      } else {
        print('todas las notificaciones: ');
        for (int i = 0; i < lista.length; i++) {
          print('#$i  ${lista[i]}');
        }
      }

    } else if (op == '3') {
      stdout.write('indice a marcar como leida: ');
      final txt = stdin.readLineSync() ?? '0';
      final idx = int.tryParse(txt) ?? -1;
      gestor.marcarComoLeida(idx);
      print('listo.');

    } else if (op == '4') {
      stdout.write('tipo a filtrar (info / advertencia / error): ');
      String tipo = (stdin.readLineSync() ?? '').toLowerCase().trim();
      final filtradas = gestor.filtrarPorTipo(tipo);
      if (filtradas.isEmpty) {
        print('(no hay notificaciones de ese tipo)');
      } else {
        print(' filtradas ($tipo)');
        for (var n in filtradas) {
          print(n);
        }
      }

    } else if (op == '5') {
      final est = gestor.estadisticas();
      
      print('total:       ${est['total']}');
      print('leidas:      ${est['leidas']}');
      print('no leidas:   ${est['noLeidas']}');
      print('info:        ${est['info']}');
      print('advertencia: ${est['advertencia']}');
      print('error:       ${est['error']}');

    } else if (op == '0') {
      print('salir');
      break;

    } else {
      print(' no valida.');
    }
  }
}

