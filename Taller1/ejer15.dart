import 'dart:io';

class cliente {
  int id;
  String nombre;
  String ubic;
  Set<int> solicitudes = {};
  Set<int> pagos = {};
  List<String> avisos = [];
  cliente(this.id, this.nombre, this.ubic);
}

class prestador {
  int id;
  String nombre;
  Set<String> categorias = {};
  Set<int> servicios = {};
  Set<DateTime> agenda = {};
  Set<int> trabajos = {};
  double ingresos = 0.0;
  List<int> califs = [];
  List<String> avisos = [];
  prestador(this.id, this.nombre);
}

class servicio {
  int id;
  int idPrestador;
  String titulo;
  String categoria;
  String desc;
  double tarifa;
  servicio(this.id, this.idPrestador, this.titulo, this.categoria, this.desc, this.tarifa);
  @override
  String toString() => '#$id $titulo | $categoria | base ${tarifa.toStringAsFixed(2)} | p:$idPrestador';
}

class solicitud {
  int id;
  int idCliente;
  int idPrestador;
  int idServicio;
  DateTime fecha;
  String estado; // creada,cotizada,aceptada,en_camino,en_progreso,completada,cancelada
  double? precio;
  String ubicCliente;
  String seg; // texto de seguimiento
  solicitud(this.id, this.idCliente, this.idPrestador, this.idServicio, this.fecha, this.ubicCliente)
      : estado = 'creada',
        seg = '';
  @override
  String toString() {
    final f = '${fecha.year}-${_2(fecha.month)}-${_2(fecha.day)} ${_2(fecha.hour)}:${_2(fecha.minute)}';
    final pr = precio == null ? '-' : precio!.toStringAsFixed(2);
    return '#$id cli:$idCliente pre:$idPrestador serv:$idServicio | $f | $estado | $pr | $ubicCliente ${seg.isEmpty ? '' : '| '+seg}';
  }
}

class pago {
  int id;
  int idSolicitud;
  double monto;
  String estado; // pendiente,pagado,fallido
  String metodo;
  DateTime fecha;
  pago(this.id, this.idSolicitud, this.monto, this.metodo)
      : estado = 'pagado',
        fecha = DateTime.now();
  @override
  String toString() => '#$id sol:$idSolicitud | ${monto.toStringAsFixed(2)} | $estado | $metodo';
}

class calificacion {
  int id;
  int idSolicitud;
  int deUser;
  int paraUser;
  int estrellas;
  String texto;
  DateTime fecha;
  calificacion(this.id, this.idSolicitud, this.deUser, this.paraUser, this.estrellas, this.texto)
      : fecha = DateTime.now();
}

int cid = 1, pid = 1, sid = 1, soid = 1, payid = 1, calid = 1;

final clientes = <int, cliente>{};
final prestadores = <int, prestador>{};
final servicios = <int, servicio>{};
final solicitudes = <int, solicitud>{};
final pagos = <int, pago>{};
final cals = <int, calificacion>{};

cliente? cliA;
prestador? preA;

void main() {
  seed();
  while (true) {
    print('\n=== marketplace servicios (opt novato) ===');
    print('1 nuevo cliente     2 nuevo prestador   3 activar cliente   4 activar prestador');
    print('5 crear servicio    6 listar servicios  7 solicitar cotizacion (cliente)');
    print('8 cotizar (prest)   9 aceptar cotizacion (cliente)');
    print('10 iniciar/seguimiento (prest)   11 completar y pago');
    print('12 calificar ambos  13 historial cliente  14 panel prestador');
    print('0 salir');
    stdout.write('opcion: ');
    final op = stdin.readLineSync() ?? '';

    if (op == '1') {
      final n = ask('nombre'); final u = ask('ubicacion');
      final c = cliente(cid++, n, u); clientes[c.id] = c; cliA = c;
      print('cliente id:${c.id} activo');

    } else if (op == '2') {
      final n = ask('nombre');
      final p = prestador(pid++, n); prestadores[p.id] = p; preA = p;
      final cats = ask('categorias coma (plomeria,limpieza,jardineria)'); 
      if (cats.trim().isNotEmpty) p.categorias = cats.toLowerCase().split(',').map((x)=>x.trim()).where((x)=>x.isNotEmpty).toSet();
      print('prestador id:${p.id} activo');

    } else if (op == '3') {
      if (clientes.isEmpty) { print('sin clientes'); continue; }
      clientes.forEach((k,v)=>print('id $k ${v.nombre}'));
      cliA = clientes[askInt('id')]; print(cliA==null?'no':'activo ${cliA!.nombre}');

    } else if (op == '4') {
      if (prestadores.isEmpty) { print('sin prestadores'); continue; }
      prestadores.forEach((k,v)=>print('id $k ${v.nombre}'));
      preA = prestadores[askInt('id')]; print(preA==null?'no':'activo ${preA!.nombre}');

    } else if (op == '5') {
      if (preA==null) { print('sin prestador activo'); continue; }
      final t = ask('titulo'); final cat = ask('categoria').toLowerCase().trim();
      final d = ask('descripcion'); final tf = askD('tarifa base');
      final s = servicio(sid++, preA!.id, t, cat, d, tf); servicios[s.id]=s; preA!.servicios.add(s.id);
      print('ok $s');

    } else if (op == '6') {
      if (servicios.isEmpty) { print('sin'); continue; }
      final fcat = ask('filtrar categoria (enter para todas)').toLowerCase().trim();
      for (final s in servicios.values) {
        if (fcat.isEmpty || s.categoria == fcat) print(s);
      }

    } else if (op == '7') {
      if (cliA==null) { print('sin cliente activo'); continue; }
      servicios.forEach((k,v)=>print(v));
      final ids = askInt('id servicio'); final s = servicios[ids]; if (s==null) { print('no'); continue; }
      final f = parseFecha(ask('fecha yyyy-mm-dd hh:mm')); if (f==null) { print('fecha no'); continue; }
      final ubi = ask('direccion/ubicacion');
      final pr = prestadores[s.idPrestador]!;
      if (pr.agenda.contains(f)) { print('prestador ocupado'); continue; }
      final so = solicitud(soid++, cliA!.id, pr.id, s.id, f, ubi);
      solicitudes[so.id] = so; cliA!.solicitudes.add(so.id);
      pr.avisos.add('nueva solicitud #${so.id} para ${s.titulo}'); 
      print('solicitud creada #${so.id} estado ${so.estado}');

    } else if (op == '8') {
      if (preA==null) { print('sin prestador activo'); continue; }
      final pend = solicitudes.values.where((x)=>x.idPrestador==preA!.id && x.estado=='creada').toList();
      if (pend.isEmpty) { print('sin pendientes'); continue; }
      for (final x in pend) print(x);
      final id = askInt('id solicitud'); final so = solicitudes[id]; if (so==null||so.idPrestador!=preA!.id||so.estado!='creada'){ print('no'); continue; }
      final pz = askD('precio cotizado');
      so.precio = pz; so.estado = 'cotizada';
      clientes[so.idCliente]?.avisos.add('cotizacion #${so.id} por ${pz.toStringAsFixed(2)}');
      print('cotizada');

    } else if (op == '9') {
      if (cliA==null) { print('sin cliente activo'); continue; }
      final mis = solicitudes.values.where((x)=>x.idCliente==cliA!.id && x.estado=='cotizada').toList();
      if (mis.isEmpty) { print('sin cotizadas'); continue; }
      for (final x in mis) print(x);
      final id = askInt('id solicitud'); final so = solicitudes[id]; if (so==null||so.idCliente!=cliA!.id||so.estado!='cotizada'){ print('no'); continue; }
      final pr = prestadores[so.idPrestador]!;
      if (pr.agenda.contains(so.fecha)) { print('ya reservado'); continue; }
      pr.agenda.add(so.fecha); so.estado = 'aceptada';
      print('aceptada y agendada');

    } else if (op == '10') {
      if (preA==null) { print('sin prestador'); continue; }
      final mis = solicitudes.values.where((x)=>x.idPrestador==preA!.id && (x.estado=='aceptada'||x.estado=='en_camino'||x.estado=='en_progreso')).toList();
      if (mis.isEmpty) { print('sin'); continue; }
      for (final x in mis) print(x);
      final id = askInt('id solicitud'); final so = solicitudes[id]; if (so==null||so.idPrestador!=preA!.id){ print('no'); continue; }
      final act = ask('accion (camino, progreso, eta Xmin, ubic X)');
      if (act=='camino') { so.estado='en_camino'; }
      else if (act=='progreso') { so.estado='en_progreso'; }
      else if (act.startsWith('eta ')) { so.seg='eta ' + act.split(' ').last; }
      else if (act.startsWith('ubic ')) { so.seg='ubic ' + act.substring(5); }
      print('ok ${so.estado} ${so.seg}');

    } else if (op == '11') {
      final id = askInt('id solicitud'); final so = solicitudes[id]; if (so==null){ print('no'); continue; }
      if (so.estado!='en_progreso' && so.estado!='aceptada') { print('no completada'); continue; }
      if (so.precio==null) { print('sin precio'); continue; }
      so.estado = 'completada';
      final p = pago(payid++, so.id, so.precio!, 'tarjeta'); pagos[p.id]=p;
      clientes[so.idCliente]?.pagos.add(p.id);
      final pr = prestadores[so.idPrestador]!;
      pr.ingresos += so.precio!;
      pr.trabajos.add(so.id);
      print('completada y pago ok ${p.toString()}');

    } else if (op == '12') {
      final id = askInt('id solicitud'); final so = solicitudes[id]; if (so==null||so.estado!='completada'){ print('no'); continue; }
      var e1 = askInt('estrellas cliente->prest 1..5'); if (e1<1)e1=1; if (e1>5)e1=5;
      final t1 = ask('texto c->p');
      final cx1 = calificacion(calid++, so.id, so.idCliente, so.idPrestador, e1, t1); cals[cx1.id]=cx1;
      prestadores[so.idPrestador]?.califs.add(e1);
      var e2 = askInt('estrellas prest->cliente 1..5'); if (e2<1)e2=1; if (e2>5)e2=5;
      final t2 = ask('texto p->c');
      final cx2 = calificacion(calid++, so.id, so.idPrestador, so.idCliente, e2, t2); cals[cx2.id]=cx2;
      print('gracias');

    } else if (op == '13') {
      if (cliA==null) { print('sin cliente'); continue; }
      final hist = solicitudes.values.where((x)=>x.idCliente==cliA!.id && x.estado=='completada').toList();
      if (hist.isEmpty) { print('sin historial'); continue; }
      for (final x in hist) print(x);

    } else if (op == '14') {
      if (preA==null) { print('sin prestador'); continue; }
      final p = preA!;
      final total = p.trabajos.length;
      final ing = p.ingresos;
      double prom = 0; if (p.califs.isNotEmpty) { for (final v in p.califs) prom+=v; prom/=p.califs.length; }
      final prox = solicitudes.values.where((x)=>x.idPrestador==p.id && (x.estado=='aceptada'||x.estado=='cotizada')).toList()
        ..sort((a,b)=>a.fecha.compareTo(b.fecha));
      print('trabajos $total | ingresos ${ing.toStringAsFixed(2)} | rating ${prom.toStringAsFixed(2)}');
      print('proximas citas:');
      for (final x in prox.take(5)) print(x);

    } else if (op == '0') {
      print('adios'); break;

    } else {
      print('no valida');
    }
  }
}

String ask(String l){ stdout.write('$l: '); return stdin.readLineSync()??''; }
int askInt(String l){ return int.tryParse(ask(l))??-1; }
double askD(String l){ return double.tryParse(ask(l).replaceAll(',', '.'))??0.0; }
String _2(int x)=>x.toString().padLeft(2,'0');

DateTime? parseFecha(String s){
  final t=s.trim().replaceAll(' ','T');
  try{ return DateTime.parse(t); }catch(_){ return null; }
}

void seed(){
  final c=cliente(cid++,'ana','calle 1'); clientes[c.id]=c; cliA=c;
  final p=prestador(pid++,'carlos'); p.categorias={'plomeria','limpieza'}; prestadores[p.id]=p; preA=p;
  final s=servicio(sid++,p.id,'destape','plomeria','destape rapido',50.0); servicios[s.id]=s; p.servicios.add(s.id);
}