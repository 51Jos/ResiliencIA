# Guía: Actualizar Datos del Último Test en Perfil de Usuario

## Problema Actual

Cuando un estudiante completa un test de ansiedad, los datos se guardan en la colección `tests_ansiedad`, pero **NO se actualizan en el documento del usuario** en la colección `usuarios`.

Esto causa:
- ❌ "Sin evaluaciones realizadas" en la lista de estudiantes
- ❌ Carga lenta (se hacía 1 query por estudiante para contar tests)
- ❌ No escalable con 1000+ estudiantes

## Solución Implementada

### 1. Campos Pre-calculados en el Documento del Usuario

Cuando un estudiante completa un test, debes actualizar estos campos en su documento en `usuarios`:

```dart
{
  // Campos existentes...
  'uid': 'abc123',
  'codigo': '2018102435',
  'email': 'estudiante@ucss.pe',
  'nombreCompleto': 'Juan Pérez',

  // ✅ CAMPOS NUEVOS A AGREGAR CUANDO SE COMPLETA UN TEST:
  'ultimoNivelAnsiedad': 'leve',        // Nivel del último test
  'puntajeUltimoTest': 15,              // Puntaje del último test (0-63)
  'fechaUltimoTest': Timestamp.now(),   // Fecha del último test
  'totalTests': 5,                      // Total de tests realizados
  'requiereAtencion': false,            // true si nivel es moderadaGrave o severa
}
```

### 2. Modificar `test_servicio.dart`

En el método `guardarResultado()`, después de guardar el test, actualiza el documento del usuario:

```dart
Future<String> guardarResultado(ResultadoTest resultado) async {
  try {
    // 1. Guardar el test (código existente)
    final datos = resultado.toFirestore();
    final datosEncriptados = EncriptacionServicio.encriptarResultado(
      resultado: datos,
      usuarioId: resultado.usuarioId,
    );

    final docRef = await _firestore
        .collection('tests_ansiedad')
        .add(datosEncriptados);

    print('✅ Test guardado con ID: ${docRef.id}');

    // 2. ⭐ NUEVO: Actualizar perfil del usuario con datos del último test
    await _actualizarPerfilUsuario(resultado);

    return docRef.id;
  } catch (e) {
    print('❌ Error al guardar resultado: $e');
    rethrow;
  }
}

// ⭐ NUEVO MÉTODO: Actualiza el perfil del usuario con datos del último test
Future<void> _actualizarPerfilUsuario(ResultadoTest resultado) async {
  try {
    // Contar total de tests del estudiante
    final testsSnapshot = await _firestore
        .collection('tests_ansiedad')
        .where('usuarioId', isEqualTo: resultado.usuarioId)
        .get();

    final totalTests = testsSnapshot.docs.length;

    // Determinar si requiere atención (moderadaGrave o severa)
    final requiereAtencion = resultado.nivelAnsiedad == NivelAnsiedad.moderadaGrave ||
                             resultado.nivelAnsiedad == NivelAnsiedad.severa;

    // Actualizar documento del usuario
    await _firestore.collection('usuarios').doc(resultado.usuarioId).update({
      'ultimoNivelAnsiedad': resultado.nivelAnsiedad.name,
      'puntajeUltimoTest': resultado.puntajeTotal,
      'fechaUltimoTest': Timestamp.fromDate(resultado.fechaRealizacion),
      'totalTests': totalTests,
      'requiereAtencion': requiereAtencion,
    });

    print('✅ Perfil de usuario actualizado con datos del último test');
  } catch (e) {
    print('⚠️ Error al actualizar perfil de usuario: $e');
    // No lanzar error, es una operación secundaria
  }
}
```

### 3. Actualizar `EstudianteInfo.fromFirestore()`

Verifica que el modelo lea estos campos correctamente:

```dart
factory EstudianteInfo.fromFirestore(DocumentSnapshot doc) {
  final data = doc.data() as Map<String, dynamic>;

  // Leer nivel de ansiedad
  NivelAnsiedad? nivelAnsiedad;
  final nivelString = data['ultimoNivelAnsiedad'] as String?;
  if (nivelString != null) {
    nivelAnsiedad = NivelAnsiedad.values.firstWhere(
      (e) => e.name == nivelString,
      orElse: () => NivelAnsiedad.minima,
    );
  }

  // Leer fecha del último test
  DateTime? fechaUltimoTest;
  final fechaTimestamp = data['fechaUltimoTest'] as Timestamp?;
  if (fechaTimestamp != null) {
    fechaUltimoTest = fechaTimestamp.toDate();
  }

  return EstudianteInfo(
    uid: doc.id,
    codigo: data['codigo'] ?? '',
    email: data['email'] ?? '',
    nombreCompleto: data['nombreCompleto'] ?? '',
    // ... otros campos ...

    // ✅ Campos del último test
    ultimoNivelAnsiedad: nivelAnsiedad,
    puntajeUltimoTest: data['puntajeUltimoTest'] as int?,
    fechaUltimoTest: fechaUltimoTest,
    totalTests: data['totalTests'] as int? ?? 0,
    requiereAtencion: data['requiereAtencion'] as bool? ?? false,
  );
}
```

## Ventajas de esta Solución

### ✅ **Rendimiento Optimizado**
- **Antes**: 1000 estudiantes = 1000 queries extras (1 por estudiante)
- **Ahora**: 1000 estudiantes = 1 sola query

### ✅ **Escalabilidad**
- Soporta 10,000+ estudiantes sin problemas
- Tiempo de carga consistente

### ✅ **Paginación**
- Carga 50 estudiantes a la vez
- Scroll infinito para cargar más

### ✅ **Datos Correctos**
- Muestra nivel de ansiedad, puntaje y fecha
- Ya no aparece "Sin evaluaciones realizadas"

## Migración de Datos Existentes

Si ya tienes estudiantes con tests en Firestore, necesitas ejecutar una migración única:

```dart
// Script de migración (ejecutar UNA VEZ)
Future<void> migrarDatosDeTests() async {
  final firestore = FirebaseFirestore.instance;

  // Obtener todos los estudiantes
  final usuariosSnapshot = await firestore
      .collection('usuarios')
      .where('rol', isEqualTo: 'estudiante')
      .get();

  print('📊 Migrando ${usuariosSnapshot.docs.length} estudiantes...');

  for (var userDoc in usuariosSnapshot.docs) {
    final userId = userDoc.id;

    // Obtener todos los tests del estudiante
    final testsSnapshot = await firestore
        .collection('tests_ansiedad')
        .where('usuarioId', isEqualTo: userId)
        .get();

    if (testsSnapshot.docs.isEmpty) {
      print('⏭️ Usuario $userId: sin tests');
      continue;
    }

    // Encontrar el test más reciente
    var ultimoTest = testsSnapshot.docs.first.data();
    var ultimaFecha = (ultimoTest['fechaRealizacion'] as Timestamp).toDate();

    for (var testDoc in testsSnapshot.docs) {
      final testData = testDoc.data();
      final fecha = (testData['fechaRealizacion'] as Timestamp).toDate();
      if (fecha.isAfter(ultimaFecha)) {
        ultimoTest = testData;
        ultimaFecha = fecha;
      }
    }

    // Actualizar usuario con datos del último test
    final nivelAnsiedad = ultimoTest['nivelAnsiedad'] as String;
    final requiereAtencion = nivelAnsiedad == 'moderadaGrave' ||
                             nivelAnsiedad == 'severa';

    await firestore.collection('usuarios').doc(userId).update({
      'ultimoNivelAnsiedad': nivelAnsiedad,
      'puntajeUltimoTest': ultimoTest['puntajeTotal'],
      'fechaUltimoTest': ultimoTest['fechaRealizacion'],
      'totalTests': testsSnapshot.docs.length,
      'requiereAtencion': requiereAtencion,
    });

    print('✅ Usuario $userId: migrado (${testsSnapshot.docs.length} tests)');
  }

  print('🎉 Migración completada!');
}
```

## Reglas de Seguridad de Firestore

Actualiza tus reglas para permitir que el estudiante actualice su propio perfil:

```javascript
match /usuarios/{userId} {
  // Leer: el usuario puede ver su propio perfil
  allow read: if request.auth != null && request.auth.uid == userId;

  // Escribir: solo puede actualizar ciertos campos
  allow update: if request.auth != null &&
                   request.auth.uid == userId &&
                   // Solo permitir actualizar estos campos
                   request.resource.data.diff(resource.data).affectedKeys()
                     .hasOnly(['ultimoNivelAnsiedad', 'puntajeUltimoTest',
                              'fechaUltimoTest', 'totalTests', 'requiereAtencion']);
}
```

## Resumen

1. ✅ **Optimización implementada** en `administracion_servicio.dart`
   - Paginación de 50 estudiantes
   - Sin queries adicionales por estudiante
   - Caché de 5 minutos

2. ⏳ **Pendiente**: Actualizar `test_servicio.dart`
   - Agregar método `_actualizarPerfilUsuario()`
   - Llamarlo después de guardar cada test

3. ⏳ **Pendiente**: Migración de datos existentes
   - Ejecutar script de migración una vez
   - Actualizar usuarios existentes con sus últimos tests

4. ⏳ **Pendiente**: Actualizar reglas de Firestore
   - Permitir que usuarios actualicen su perfil
   - Restringir campos modificables