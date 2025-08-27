import 'dart:io';

class usuario {
  String nombre;
  List<curso> cursosinscritos = [];
  Map<curso, progreso> progresos = {};

  usuario(this.nombre);

  void inscribirse(curso c) {
    if (!cursosinscritos.contains(c)) {
      cursosinscritos.add(c);
      progresos[c] = progreso(cursox: c);
      print('$nombre inscrito en ${c.titulo}');
    }
  }

  void verleccion(curso c, int indice) {
    if (!cursosinscritos.contains(c)) return;
    if (indice < 0 || indice >= c.lecciones.length) return;
    progresos[c]?.marcarcompletada(indice);
    print('$nombre completo la leccion: ${c.lecciones[indice].titulo}');
  }

  void calificarcurso(curso c, double cal) {
    if (cursosinscritos.contains(c)) {
      c.agregarcalificacion(cal);
    }
  }

  void mostrarprogreso() {
    for (var c in cursosinscritos) {
      var prog = progresos[c];
      print('${c.titulo}: ${prog?.porcentajecompletado().toStringAsFixed(1)}% completado');
      if (prog?.estacompleto() ?? false) {
        print('certificado obtenido');
      }
    }
  }

  void recomendaciones(List<curso> todos) {
    print('recomendaciones para $nombre:');
    for (var c in todos) {
      if (!cursosinscritos.contains(c)) {
        print('- ${c.titulo} (${c.categoria})');
      }
    }
  }
}

class curso {
  String titulo;
  String categoria;
  List<leccion> lecciones;
  List<double> calificaciones = [];

  curso({required this.titulo, required this.categoria, required this.lecciones});

  void agregarcalificacion(double cal) {
    if (cal >= 1 && cal <= 5) {
      calificaciones.add(cal);
    }
  }

  double promediocalificaciones() {
    if (calificaciones.isEmpty) return 0.0;
    return calificaciones.reduce((a, b) => a + b) / calificaciones.length;
  }
}

class leccion {
  String titulo;
  String contenido;

  leccion({required this.titulo, required this.contenido});
}

class progreso {
  curso cursox;
  List<bool> completadas;

  progreso({required this.cursox}) : completadas = List.filled(cursox.lecciones.length, false);

  void marcarcompletada(int indice) {
    if (indice >= 0 && indice < completadas.length) {
      completadas[indice] = true;
    }
  }

  double porcentajecompletado() {
    int done = completadas.where((c) => c).length;
    return (done / completadas.length) * 100;
  }

  bool estacompleto() {
    return completadas.every((c) => c);
  }
}

void main() {
  var c1 = curso(
    titulo: 'git basico',
    categoria: 'herramientas',
    lecciones: [
      leccion(titulo: 'repositorios', contenido: 'creacion y uso basico'),
      leccion(titulo: 'ramas', contenido: 'branch merge'),
      leccion(titulo: 'colaboracion', contenido: 'pull requests'),
    ],
  );

  var c2 = curso(
    titulo: 'sql inicial',
    categoria: 'datos',
    lecciones: [
      leccion(titulo: 'select', contenido: 'consultas basicas'),
      leccion(titulo: 'joins', contenido: 'relaciones'),
      leccion(titulo: 'group by', contenido: 'agrupaciones'),
    ],
  );

  var c3 = curso(
    titulo: 'html y css',
    categoria: 'frontend',
    lecciones: [
      leccion(titulo: 'etiquetas', contenido: 'estructura'),
      leccion(titulo: 'selectores', contenido: 'basico css'),
    ],
  );

  var todos = [c1, c2, c3];

  var u = usuario('ana');
  u.inscribirse(c1);
  u.inscribirse(c2);

  u.verleccion(c1, 0);
  u.verleccion(c2, 1);

  u.calificarcurso(c1, 4);
  u.calificarcurso(c2, 5);

  print('--- progreso ---');
  u.mostrarprogreso();

  print('--- estadisticas ---');
  for (var c in todos) {
    print('${c.titulo}: promedio ${c.promediocalificaciones().toStringAsFixed(2)}');
  }

  print('--- recomendaciones ---');
  u.recomendaciones(todos);
}