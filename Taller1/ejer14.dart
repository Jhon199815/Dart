import 'dart:io';

class organizador {
  int id;
  String nombre;
  Set<int> eventos = {};
  List<String> avisos = [];
  organizador(this.id, this.nombre);
}

class participante {
  int id;
  String nombre;
  Set<String> intereses = {};
  Set<int> registros = {};
  Set<int> pagos = {};
  Set<int> checkins = {};
  Map<int, int> califs = {};
  Map<int, String> textos = {};
  List<String> avisos = [];
  participante(this.id, this.nombre);
}

class ubicacionx {
  int id;
  String nombre;
  String direccion;
  String ciudad;
  ubicacionx(this.id, this.nombre, this.direccion, this.ciudad);
  @override
  String toString() => '#$id $nombre, $direccion, $ciudad';
}

class evento {
  int id;
  String titulo;
  String categoria;
  int idUbicacion;
  DateTime fecha;
  double precio;
  int cupo;
  int idOrganizador;
  Set<int> inscritos = {};
  Set<int> pagados = {};
  Set<int> asistieron = {};
  evento(this.id, this.titulo, this.categoria, this.idUbicacion, this.fecha, this.precio, this.cupo, this.idOrganizador);
  String qrPara(int idUser) => 'EV$id-U$idUser';
  @override
  String toString() {
    final f = '${fecha.year.toString().padLeft(4,'0')}-${fecha.month.toString().padLeft(2,'0')}-${fecha.day.toString().padLeft(2,'0')} ${fecha.hour.toString().padLeft(2,'0')}:${fecha.minute.toString().padLeft(2,'0')}';
    return '#$id $titulo | $categoria | $f | precio ${precio.toStringAsFixed(2)} | cupo $cupo | inscritos ${inscritos.length}';
  }
}

class resena {
  int idEvento;
  int idAutor;
  int estrellas;
  String texto;
  DateTime fecha;
  resena(this.idEvento, this.idAutor, this.estrellas, this.texto) : fecha = DateTime.now();
}

int uid = 1;
int oid = 1;
int eid = 1;
int ubid = 1;

final orgs = <int, organizador>{};
final parts = <int, participante>{};
final evts = <int, evento>{};
final ubis = <int, ubicacionx>{};
final resenas = <resena>[];

organizador? orgActivo;
participante? parActivo;

void main() {
  _seed();
  while (true) {
    print('\n=== eventos locales (opt novato) ===');
    print('1 crear organizador');
    print('2 crear participante');
    print('3 activar organizador');
    print('4 activar participante');
    print('5 crear ubicacion');
    print('6 crear evento (organizador)');
    print('7 listar eventos');
    print('8 registrar a evento (participante)');
    print('9 pagar evento (participante)');
    print('10 ver/generar qr (participante)');
    print('11 checkin qr (organizador)');
    print('12 notificaciones');
    print('13 evaluar evento (participante)');
    print('14 estadisticas evento (organizador)');
    print('0 salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      final n = _ask('nombre');
      final o = organizador(oid++, n);
      orgs[o.id] = o;
      orgActivo = o;
      print('organizador id:${o.id} activo');

    } else if (op == '2') {
      final n = _ask('nombre');
      final p = participante(uid++, n);
      parts[p.id] = p;
      parActivo = p;
      print('participante id:${p.id} activo');

    } else if (op == '3') {
      if (orgs.isEmpty) { print('sin organizadores'); continue; }
      orgs.forEach((k,v)=>print('id:$k ${v.nombre}'));
      final id = _askInt('id organizador');
      orgActivo = orgs[id];
      print(orgActivo == null ? 'no existe' : 'activo ${orgActivo!.nombre}');

    } else if (op == '4') {
      if (parts.isEmpty) { print('sin participantes'); continue; }
      parts.forEach((k,v)=>print('id:$k ${v.nombre}'));
      final id = _askInt('id participante');
      parActivo = parts[id];
      print(parActivo == null ? 'no existe' : 'activo ${parActivo!.nombre}');
      if (parActivo != null) {
        final it = _ask('intereses por coma (ej: musica,tech,deporte) o enter para omitir');
        if (it.trim().isNotEmpty) {
          parActivo!.intereses = it.toLowerCase().split(',').map((x)=>x.trim()).where((x)=>x.isNotEmpty).toSet();
        }
      }

    } else if (op == '5') {
      final n = _ask('nombre ubicacion');
      final d = _ask('direccion');
      final c = _ask('ciudad');
      final u = ubicacionx(ubid++, n, d, c);
      ubis[u.id] = u;
      print('ok $u');

    } else if (op == '6') {
      if (orgActivo == null) { print('sin organizador activo'); continue; }
      final t = _ask('titulo');
      final cat = _ask('categoria');
      if (ubis.isEmpty) { print('primero crea ubicacion'); continue; }
      ubis.forEach((k,v)=>print(v));
      final idu = _askInt('id ubicacion');
      if (!ubis.containsKey(idu)) { print('ubicacion no existe'); continue; }
      final f = _ask('fecha yyyy-mm-dd hh:mm');
      final fecha = _parseFecha(f);
      if (fecha == null) { print('fecha invalida'); continue; }
      final pr = _askDouble('precio');
      final cp = _askInt('cupo');
      final e = evento(eid++, t, cat.toLowerCase().trim(), idu, fecha, pr, cp, orgActivo!.id);
      evts[e.id] = e;
      orgActivo!.eventos.add(e.id);
      _notiNuevoEvento(e);
      print('ok $e');

    } else if (op == '7') {
      if (evts.isEmpty) { print('sin eventos'); continue; }
      for (final e in evts.values) {
        final u = ubis[e.idUbicacion];
        print('${e.toString()} | ${u == null ? '' : u.ciudad}');
      }

    } else if (op == '8') {
      if (parActivo == null) { print('sin participante activo'); continue; }
      evts.forEach((k,v)=>print(v));
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null) { print('no existe'); continue; }
      if (e.inscritos.length >= e.cupo) { print('cupo lleno'); continue; }
      if (parActivo!.registros.contains(e.id)) { print('ya inscrito'); continue; }
      e.inscritos.add(parActivo!.id);
      parActivo!.registros.add(e.id);
      print('inscrito en ${e.titulo}');
      if (e.precio > 0) print('requiere pago: ${e.precio.toStringAsFixed(2)}');

    } else if (op == '9') {
      if (parActivo == null) { print('sin participante activo'); continue; }
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null) { print('no existe'); continue; }
      if (!parActivo!.registros.contains(e.id)) { print('no inscrito'); continue; }
      if (parActivo!.pagos.contains(e.id)) { print('ya pagado'); continue; }
      parActivo!.pagos.add(e.id);
      e.pagados.add(parActivo!.id);
      print('pago ok');

    } else if (op == '10') {
      if (parActivo == null) { print('sin participante activo'); continue; }
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null) { print('no existe'); continue; }
      if (!parActivo!.registros.contains(e.id)) { print('no inscrito'); continue; }
      final code = e.qrPara(parActivo!.id);
      print('qr: $code');

    } else if (op == '11') {
      if (orgActivo == null) { print('sin organizador activo'); continue; }
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null || e.idOrganizador != orgActivo!.id) { print('no existe o no eres organizador'); continue; }
      final code = _ask('codigo qr');
      final ok = code == e.qrPara(_extraerUid(code));
      if (!ok) { print('qr invalido'); continue; }
      final uidc = _extraerUid(code);
      if (!e.inscritos.contains(uidc)) { print('usuario no inscrito'); continue; }
      e.asistieron.add(uidc);
      parts[uidc]?.checkins.add(e.id);
      print('checkin ok');

    } else if (op == '12') {
      _recordatorios();
      if (orgActivo != null && orgActivo!.avisos.isNotEmpty) {
        print('avisos organizador:');
        for (final a in orgActivo!.avisos) print('- $a');
        orgActivo!.avisos.clear();
      }
      if (parActivo != null && parActivo!.avisos.isNotEmpty) {
        print('avisos participante:');
        for (final a in parActivo!.avisos) print('- $a');
        parActivo!.avisos.clear();
      }
      if ((orgActivo==null || orgActivo!.avisos.isEmpty) && (parActivo==null || parActivo!.avisos.isEmpty)) {
        print('sin avisos');
      }

    } else if (op == '13') {
      if (parActivo == null) { print('sin participante activo'); continue; }
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null) { print('no existe'); continue; }
      if (!parActivo!.checkins.contains(e.id)) { print('solo asistentes pueden evaluar'); continue; }
      if (DateTime.now().isBefore(e.fecha)) { print('el evento aun no ocurre'); continue; }
      var est = _askInt('estrellas 1..5');
      if (est < 1) est = 1; if (est > 5) est = 5;
      final txt = _ask('texto corto (opcional)');
      parActivo!.califs[e.id] = est;
      parActivo!.textos[e.id] = txt;
      resenas.add(resena(e.id, parActivo!.id, est, txt));
      print('gracias');

    } else if (op == '14') {
      if (orgActivo == null) { print('sin organizador activo'); continue; }
      final id = _askInt('id evento');
      final e = evts[id];
      if (e == null || e.idOrganizador != orgActivo!.id) { print('no existe o no eres organizador'); continue; }
      final inscritos = e.inscritos.length;
      final pagados = e.pagados.length;
      final asis = e.asistieron.length;
      double prom = 0;
      int n = 0;
      for (final r in resenas) {
        if (r.idEvento == e.id) { prom += r.estrellas; n++; }
      }
      final rating = n == 0 ? 0.0 : prom / n;
      print('evento ${e.titulo}');
      print('inscritos $inscritos | pagados $pagados | asistencia $asis | rating ${rating.toStringAsFixed(2)}');

    } else if (op == '0') {
      print('adios');
      break;

    } else {
      print('no valida');
    }
  }
}

String _ask(String label) { stdout.write('$label: '); return stdin.readLineSync() ?? ''; }
int _askInt(String label) { return int.tryParse(_ask(label)) ?? -1; }
double _askDouble(String label) { return double.tryParse(_ask(label).replaceAll(',', '.')) ?? 0.0; }

DateTime? _parseFecha(String s) {
  final t = s.trim().replaceAll(' ', 'T');
  try { return DateTime.parse(t); } catch (_) { return null; }
}

int _extraerUid(String code) {
  final p = code.split('-');
  if (p.length != 2) return -1;
  final u = p[1].replaceFirst('U','');
  return int.tryParse(u) ?? -1;
}

void _notiNuevoEvento(evento e) {
  for (final p in parts.values) {
    if (p.intereses.contains(e.categoria)) {
      p.avisos.add('nuevo evento ${e.titulo} de ${e.categoria}');
    }
  }
  final o = orgs[e.idOrganizador];
  o?.avisos.add('evento creado #${e.id}');
}

void _recordatorios() {
  final ahora = DateTime.now();
  for (final e in evts.values) {
    final dif = e.fecha.difference(ahora).inHours;
    if (dif > 0 && dif <= 48) {
      for (final uid in e.inscritos) {
        parts[uid]?.avisos.add('recordatorio ${e.titulo} en ${dif}h');
      }
    }
  }
}

void _seed() {
  final u1 = ubicacionx(ubid++, 'centro cultural', 'calle 1', 'bogota');
  final u2 = ubicacionx(ubid++, 'parque norte', 'av 10', 'medellin');
  ubis[u1.id] = u1; ubis[u2.id] = u2;
  final o = organizador(oid++, 'acme');
  orgs[o.id] = o; orgActivo = o;
  final p = participante(uid++, 'ana');
  p.intereses = {'musica','tech'};
  parts[p.id] = p; parActivo = p;
  final e = evento(eid++, 'feria tech', 'tech', u1.id, DateTime.now().add(Duration(days: 3, hours: 2)), 20.0, 100, o.id);
  evts[e.id] = e; o.eventos.add(e.id);
}