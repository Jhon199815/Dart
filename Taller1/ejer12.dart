import 'dart:io';

class usuario {
  int id;
  String nombre;
  Set<String> intereses = {};
  double reputacion = 0.0;
  int votos = 0;
  List<int> libros = [];
  List<int> intercambios = [];
  List<String> avisos = [];
  usuario(this.id, this.nombre);
}

class libro {
  int id;
  String titulo;
  String autor;
  String genero;
  String estado;
  int dueno;
  DateTime fecha;
  libro(this.id, this.titulo, this.autor, this.genero, this.dueno)
      : estado = 'disponible',
        fecha = DateTime.now();
  @override
  String toString() => '#$id | $titulo - $autor | $genero | $estado | u:$dueno';
}

class intercambio {
  int id;
  int solicitante;
  int oferente;
  int libroSolicitado;
  int? libroOfrecido;
  String estado;
  int? calSol;
  int? calOfe;
  String? txtSol;
  String? txtOfe;
  intercambio(this.id, this.solicitante, this.oferente, this.libroSolicitado, this.libroOfrecido)
      : estado = 'pendiente';
  @override
  String toString() {
    String p = 'intercambio #$id | $solicitante -> $oferente | $libroSolicitado';
    if (libroOfrecido != null) p += ' por ${libroOfrecido!}';
    return '$p | $estado';
  }
}

int uid = 1;
int lid = 1;
int iid = 1;

final Map<int, usuario> us = {};
final Map<int, libro> lb = {};
final Map<int, intercambio> it = {};

usuario? activo;

void main() {
  while (true) {
    print('\n=== red de libros (basico) ===');
    print('1 crear usuario');
    print('2 cambiar usuario activo');
    print('3 intereses del usuario');
    print('4 publicar libro');
    print('5 listar disponibles');
    print('6 buscar');
    print('7 solicitar intercambio');
    print('8 revisar solicitudes');
    print('9 finalizar y calificar');
    print('10 perfil y reputacion');
    print('11 avisos');
    print('0 salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      stdout.write('nombre: ');
      final n = stdin.readLineSync() ?? '';
      final u = usuario(uid++, n);
      us[u.id] = u;
      activo = u;
      print('listo id:${u.id}');

    } else if (op == '2') {
      if (us.isEmpty) {
        print('no hay usuarios');
      } else {
        for (final e in us.entries) {
          print('id:${e.key} nombre:${e.value.nombre}');
        }
        stdout.write('id: ');
        final id = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        activo = us[id];
        if (activo == null) print('no existe'); else print('activo: ${activo!.nombre}');
      }

    } else if (op == '3') {
      if (!_ok()) continue;
      stdout.write('intereses por coma: ');
      final t = (stdin.readLineSync() ?? '').toLowerCase();
      final s = t.split(',').map((x) => x.trim()).where((x) => x.isNotEmpty).toSet();
      activo!.intereses = s;
      print('ok: ${activo!.intereses.join(', ')}');

    } else if (op == '4') {
      if (!_ok()) continue;
      stdout.write('titulo: ');
      final t = stdin.readLineSync() ?? '';
      stdout.write('autor: ');
      final a = stdin.readLineSync() ?? '';
      stdout.write('genero: ');
      final g = (stdin.readLineSync() ?? '').toLowerCase().trim();
      final l = libro(lid++, t, a, g, activo!.id);
      lb[l.id] = l;
      activo!.libros.add(l.id);
      _avisarNuevo(l);
      print('publicado: $l');

    } else if (op == '5') {
      final xs = lb.values.where((x) => x.estado == 'disponible');
      if (xs.isEmpty) print('sin libros');
      for (final x in xs) print(x);

    } else if (op == '6') {
      stdout.write('titulo contiene: ');
      final ft = (stdin.readLineSync() ?? '').toLowerCase();
      stdout.write('autor contiene: ');
      final fa = (stdin.readLineSync() ?? '').toLowerCase();
      stdout.write('genero exacto: ');
      final fg = (stdin.readLineSync() ?? '').toLowerCase().trim();
      stdout.write('estado: ');
      final fe = (stdin.readLineSync() ?? '').toLowerCase().trim();

      final res = <libro>[];
      for (final x in lb.values) {
        if (ft.isNotEmpty && !x.titulo.toLowerCase().contains(ft)) continue;
        if (fa.isNotEmpty && !x.autor.toLowerCase().contains(fa)) continue;
        if (fg.isNotEmpty && x.genero != fg) continue;
        if (fe.isNotEmpty && x.estado != fe) continue;
        res.add(x);
      }
      if (res.isEmpty) print('sin resultados');
      for (final x in res) print(x);

    } else if (op == '7') {
      if (!_ok()) continue;
      stdout.write('id libro que quieres: ');
      final idl = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
      final l = lb[idl];
      if (l == null) { print('no existe'); continue; }
      if (l.dueno == activo!.id) { print('no pidas tu libro'); continue; }
      if (l.estado != 'disponible') { print('no disponible'); continue; }

      stdout.write('id libro tuyo para ofrecer (enter si no): ');
      final of = stdin.readLineSync() ?? '';
      int? idof;
      if (of.trim().isNotEmpty) {
        idof = int.tryParse(of) ?? -1;
        final lo = lb[idof];
        if (lo == null || lo.dueno != activo!.id) { print('oferta invalida'); continue; }
        if (lo.estado != 'disponible') { print('no disponible'); continue; }
      }

      final k = intercambio(iid++, activo!.id, l.dueno, l.id, idof);
      it[k.id] = k;
      l.estado = 'reservado';
      if (idof != null) {
        final lo = lb[idof];
        if (lo != null) lo.estado = 'reservado';
      }
      final du = us[l.dueno];
      du?.avisos.add('solicitud #${k.id} por libro #${l.id}');
      print('enviada: $k');

    } else if (op == '8') {
      if (!_ok()) continue;
      final rec = <intercambio>[];
      for (final x in it.values) {
        if (x.oferente == activo!.id && x.estado == 'pendiente') rec.add(x);
      }
      if (rec.isEmpty) { print('sin solicitudes'); continue; }
      for (final x in rec) print(x);
      stdout.write('id: ');
      final i = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
      final x = it[i];
      if (x == null || x.oferente != activo!.id || x.estado != 'pendiente') { print('no existe'); continue; }
      stdout.write('accion (a/r): ');
      final ac = (stdin.readLineSync() ?? '').toLowerCase().trim();
      if (ac == 'a') {
        x.estado = 'aceptado';
        us[x.solicitante]?.avisos.add('intercambio #${x.id} aceptado');
        print('aceptado');
      } else if (ac == 'r') {
        x.estado = 'rechazado';
        final s = lb[x.libroSolicitado]; s?.estado = 'disponible';
        if (x.libroOfrecido != null) { final o = lb[x.libroOfrecido!]; o?.estado = 'disponible'; }
        us[x.solicitante]?.avisos.add('intercambio #${x.id} rechazado');
        print('rechazado');
      } else {
        print('invalido');
      }

    } else if (op == '9') {
      if (!_ok()) continue;
      final xs = <intercambio>[];
      for (final x in it.values) {
        if ((x.solicitante == activo!.id || x.oferente == activo!.id) &&
            (x.estado == 'aceptado' || x.estado == 'completado')) xs.add(x);
      }
      if (xs.isEmpty) { print('sin intercambios'); continue; }
      for (final x in xs) print(x);
      stdout.write('id: ');
      final i = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
      final x = it[i];
      if (x == null) { print('no existe'); continue; }

      stdout.write('calificacion 1..5: ');
      int c = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
      if (c < 1) c = 1;
      if (c > 5) c = 5;
      stdout.write('resena (opcional): ');
      final rr = stdin.readLineSync() ?? '';

      final otro = x.solicitante == activo!.id ? x.oferente : x.solicitante;
      final uo = us[otro];
      if (uo != null) {
        uo.votos += 1;
        uo.reputacion = ((uo.reputacion * (uo.votos - 1)) + c) / uo.votos;
      }
      if (x.solicitante == activo!.id) { x.calSol = c; x.txtSol = rr; } else { x.calOfe = c; x.txtOfe = rr; }

      if (x.calSol != null && x.calOfe != null) {
        x.estado = 'completado';
        final s = lb[x.libroSolicitado]; if (s != null) s.estado = 'intercambiado';
        if (x.libroOfrecido != null) { final o = lb[x.libroOfrecido!]; if (o != null) o.estado = 'intercambiado'; }
        us[x.solicitante]?.intercambios.add(x.id);
        us[x.oferente]?.intercambios.add(x.id);
        print('completado');
      } else {
        print('registrado, falta la otra parte');
      }

    } else if (op == '10') {
      if (!_ok()) continue;
      final u = activo!;
      print('usuario ${u.nombre} | rep ${u.reputacion.toStringAsFixed(2)} | votos ${u.votos}');
      if (u.intercambios.isEmpty) {
        print('historial vacio');
      } else {
        for (final id in u.intercambios) {
          final x = it[id];
          if (x != null) print(x);
        }
      }

    } else if (op == '11') {
      if (!_ok()) continue;
      if (activo!.avisos.isEmpty) print('sin avisos');
      for (final n in activo!.avisos) print('- $n');
      activo!.avisos.clear();

    } else if (op == '0') {
      print('adios');
      break;

    } else {
      print('opcion no valida');
    }
  }
}

bool _ok() {
  if (activo == null) {
    print('no hay usuario activo');
    return false;
  }
  return true;
}

void _avisarNuevo(libro l) {
  for (final u in us.values) {
    if (u.id == l.dueno) continue;
    if (u.intereses.contains(l.genero)) {
      u.avisos.add('nuevo libro ${l.titulo} de ${l.autor} (${l.genero})');
    }
  }
}