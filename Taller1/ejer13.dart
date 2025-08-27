import 'dart:io';

class usuario {
  int id;
  String nombre;
  Set<int> cuentas = {};
  double meta = 0.0;
  usuario(this.id, this.nombre);
}

class cuenta {
  int id;
  String nombre;
  String tipo;
  double saldo;
  List<int> txs = [];
  cuenta(this.id, this.nombre, this.tipo, this.saldo);
  @override
  String toString() => '#$id $nombre | $tipo | ${saldo.toStringAsFixed(2)}';
}

class tx {
  int id;
  int idCuenta;
  DateTime fecha;
  double monto;
  String desc;
  String cat;
  tx(this.id, this.idCuenta, this.monto, this.desc, this.cat) : fecha = DateTime.now();
  @override
  String toString() {
    final s = monto >= 0 ? '+' : '-';
    return '#$id ${_ymdHm(fecha)} | $s${monto.abs().toStringAsFixed(2)} | $cat | $desc';
  }
}

int uid = 1;
int cid = 1;
int tid = 1;

final usuarios = <int, usuario>{};
final cuentas = <int, cuenta>{};
final trans = <int, tx>{};
final presup = <String, double>{};
final reglas = <String, List<String>>{
  'comida': ['rest', 'food', 'pizza', 'almuerzo', 'cena', 'caf', 'bar'],
  'mercado': ['super', 'mercado', 'grocery', 'tienda'],
  'transporte': ['uber', 'bus', 'taxi', 'gas', 'peaje'],
  'servicios': ['luz', 'agua', 'internet', 'netflix', 'spotify', 'telefono'],
  'salud': ['farm', 'medic', 'clinica'],
  'educacion': ['curso', 'colegi', 'uni', 'libro'],
  'ocio': ['cine', 'juego', 'concierto'],
  'otros': [],
};

usuario? activo;

void main() {
  while (true) {
    print('\n=== finanzas (opt novato) ===');
    print('1 usuario nuevo');
    print('2 activar usuario');
    print('3 set meta mensual');
    print('4 crear cuenta');
    print('5 cuentas');
    print('6 nueva transaccion');
    print('7 transacciones de cuenta');
    print('8 set presupuesto mes/cat');
    print('9 reporte del mes');
    print('10 patrones del mes');
    print('11 alertas');
    print('0 salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      final n = _askStr('nombre');
      final u = usuario(uid++, n);
      usuarios[u.id] = u;
      activo = u;
      print('ok id:${u.id}');

    } else if (op == '2') {
      if (usuarios.isEmpty) { print('sin usuarios'); continue; }
      usuarios.forEach((k, v) => print('id:$k ${v.nombre}'));
      final id = _askInt('id');
      activo = usuarios[id];
      print(activo == null ? 'no existe' : 'activo ${activo!.nombre}');

    } else if (op == '3') {
      if (!_hasUser()) continue;
      activo!.meta = _askDouble('meta mensual');
      print('meta ${activo!.meta.toStringAsFixed(2)}');

    } else if (op == '4') {
      if (!_hasUser()) continue;
      final n = _askStr('nombre cuenta');
      final t = _askStr('tipo');
      final s = _askDouble('saldo inicial');
      final c = cuenta(cid++, n, t.toLowerCase().trim(), s);
      cuentas[c.id] = c;
      activo!.cuentas.add(c.id);
      print('ok ${c.toString()}');

    } else if (op == '5') {
      if (!_hasUser()) continue;
      if (activo!.cuentas.isEmpty) { print('sin cuentas'); continue; }
      for (final id in activo!.cuentas) { final c = cuentas[id]; if (c!=null) print(c); }

    } else if (op == '6') {
      if (!_hasUser()) continue;
      if (activo!.cuentas.isEmpty) { print('sin cuentas'); continue; }
      _printCuentas(activo!);
      final idc = _askInt('id cuenta');
      final c = cuentas[idc];
      if (c == null) { print('no existe'); continue; }
      final m = _askDouble('monto (+ ingreso, - gasto)');
      final d = _askStr('descripcion');
      var cat = _autoCat(d);
      final cx = _askStr('categoria (enter=auto:$cat)');
      if (cx.trim().isNotEmpty) cat = cx.toLowerCase().trim();
      final t = tx(tid++, idc, m, d, cat);
      trans[t.id] = t;
      c.saldo += m;
      c.txs.add(t.id);
      print('ok $t');
      _alertas();

    } else if (op == '7') {
      if (!_hasUser()) continue;
      final idc = _askInt('id cuenta');
      final c = cuentas[idc];
      if (c == null) { print('no existe'); continue; }
      if (c.txs.isEmpty) print('sin transacciones');
      for (final id in c.txs.reversed) { final t = trans[id]; if (t!=null) print(t); }
      print('saldo ${c.saldo.toStringAsFixed(2)}');

    } else if (op == '8') {
      final mes = _mes();
      final cat = _askStr('categoria (comida, mercado, transporte, servicios, salud, educacion, ocio, otros, todos)');
      final lim = _askDouble('limite para $mes');
      presup['$mes|$cat'] = lim;
      print('ok presupuesto [$mes] $cat = ${lim.toStringAsFixed(2)}');
      print('gastado actual: ${_gastoMes(mes, cat).toStringAsFixed(2)}');

    } else if (op == '9') {
      final mes = _mes();
      _reporte(mes);
      if (activo != null && activo!.meta > 0) {
        final ah = _ingresos(mes) - _gastos(mes);
        final pct = ah / (activo!.meta == 0 ? 1 : activo!.meta) * 100.0;
        print('meta ${activo!.meta.toStringAsFixed(2)} | ahorro ${ah.toStringAsFixed(2)} | ${pct.toStringAsFixed(1)}%');
      }

    } else if (op == '10') {
      _patrones(_mes());

    } else if (op == '11') {
      _alertas();

    } else if (op == '0') {
      print('adios');
      break;

    } else {
      print('no valida');
    }
  }
}

bool _hasUser() {
  if (activo == null) { print('sin usuario'); return false; }
  return true;
}

String _askStr(String label) { stdout.write('$label: '); return stdin.readLineSync() ?? ''; }
int _askInt(String label) { return int.tryParse(_askStr(label)) ?? -1; }
double _askDouble(String label) {
  final s = _askStr(label).replaceAll(',', '.');
  return double.tryParse(s) ?? 0.0;
}

String _mes() {
  final n = DateTime.now();
  return '${n.year.toString().padLeft(4,'0')}-${n.month.toString().padLeft(2,'0')}';
}

String _ymdHm(DateTime d) {
  final y='${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';
  final h='${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  return '$y $h';
}

void _printCuentas(usuario u) {
  for (final id in u.cuentas) { final c = cuentas[id]; if (c!=null) print(c); }
}

String _autoCat(String desc) {
  final d = desc.toLowerCase();
  for (final e in reglas.entries) {
    for (final p in e.value) {
      if (p.isEmpty) continue;
      if (d.contains(p)) return e.key;
    }
  }
  return 'otros';
}

double _gastoMes(String mes, String cat) {
  double s = 0;
  for (final t in trans.values) {
    final m = '${t.fecha.year.toString().padLeft(4,'0')}-${t.fecha.month.toString().padLeft(2,'0')}';
    if (m == mes && t.monto < 0 && (cat == 'todos' || t.cat == cat)) s += -t.monto;
  }
  return s;
}

double _gastos(String mes) {
  double s = 0;
  for (final t in trans.values) {
    final m = '${t.fecha.year.toString().padLeft(4,'0')}-${t.fecha.month.toString().padLeft(2,'0')}';
    if (m == mes && t.monto < 0) s += -t.monto;
  }
  return s;
}

double _ingresos(String mes) {
  double s = 0;
  for (final t in trans.values) {
    final m = '${t.fecha.year.toString().padLeft(4,'0')}-${t.fecha.month.toString().padLeft(2,'0')}';
    if (m == mes && t.monto > 0) s += t.monto;
  }
  return s;
}

void _reporte(String mes) {
  final ing = _ingresos(mes);
  final gas = _gastos(mes);
  print('mes $mes | ingresos ${ing.toStringAsFixed(2)} | gastos ${gas.toStringAsFixed(2)} | neto ${(ing-gas).toStringAsFixed(2)}');

  final porCat = <String,double>{};
  for (final t in trans.values) {
    final m = '${t.fecha.year.toString().padLeft(4,'0')}-${t.fecha.month.toString().padLeft(2,'0')}';
    if (m != mes || t.monto >= 0) continue;
    porCat[t.cat] = (porCat[t.cat] ?? 0) + (-t.monto);
  }
  if (porCat.isEmpty) { print('sin gastos'); return; }
  final top = porCat.entries.toList()..sort((a,b)=>b.value.compareTo(a.value));
  print('top categorias:');
  for (final e in top.take(5)) { print('- ${e.key}: ${e.value.toStringAsFixed(2)}'); }
}

void _patrones(String mes) {
  final porDia = List<double>.filled(7, 0.0);
  final porSem = List<double>.filled(6, 0.0);
  for (final t in trans.values) {
    final m = '${t.fecha.year.toString().padLeft(4,'0')}-${t.fecha.month.toString().padLeft(2,'0')}';
    if (m != mes || t.monto >= 0) continue;
    porDia[t.fecha.weekday % 7] += -t.monto;
    porSem[(t.fecha.day - 1) ~/ 7] += -t.monto;
  }
  int d = 0; for (int i=1;i<7;i++) if (porDia[i] > porDia[d]) d = i;
  int w = 0; for (int i=1;i<6;i++) if (porSem[i] > porSem[w]) w = i;
  final dias = ['dom','lun','mar','mie','jue','vie','sab'];
  print('pico dia ${dias[d]} ${porDia[d].toStringAsFixed(2)}');
  print('pico semana ${w+1} ${porSem[w].toStringAsFixed(2)}');
}

void _alertas() {
  for (final c in cuentas.values) {
    if (c.saldo < 0) print('alerta sobregiro cuenta #${c.id} ${c.saldo.toStringAsFixed(2)}');
  }
  final mes = _mes();
  for (final e in presup.entries) {
    final parts = e.key.split('|');
    if (parts.length != 2) continue;
    if (parts[0] != mes) continue;
    final cat = parts[1];
    final lim = e.value;
    final g = _gastoMes(mes, cat);
    if (g > lim) print('alerta presupuesto $cat ${g.toStringAsFixed(2)} / ${lim.toStringAsFixed(2)}');
  }
}