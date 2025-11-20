# 🔥 SOLUCIONAR PROBLEMA DE INDEXES EN FIRESTORE

## Problema
Cuando regresas del detalle de un estudiante, aparece un error de indexes en Firestore.

## ¿Qué son los indexes?
Firestore requiere **indexes compuestos** cuando haces consultas con múltiples filtros (`where`) y ordenamiento (`orderBy`) al mismo tiempo.

## ✅ Solución Automática (RECOMENDADO)

### Paso 1: Reproduce el error
1. Abre la app en el navegador (Chrome/Edge) con DevTools abierto (F12)
2. Ve al panel de administración
3. Entra al detalle de un estudiante
4. Regresa a la lista

### Paso 2: Copia el link del error
En la consola del navegador verás un error como:

```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

### Paso 3: Haz clic en el link
1. El link te llevará a Firebase Console
2. Haz clic en **"Crear índice"** o **"Create Index"**
3. Espera 2-5 minutos a que se cree el index
4. Recarga la app y prueba nuevamente

## 🔧 Solución Manual

Si el link no aparece, crea los indexes manualmente:

### Para lista de estudiantes con filtros:

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Abre tu proyecto: **resiliencia-85ff4**
3. Ve a **Firestore Database** → **Indexes**
4. Haz clic en **"Create Index"** o **"Crear índice"**
5. Crea estos indexes:

#### Index 1: Estudiantes por rol y fecha
```
Collection: usuarios
Fields:
  - rol (Ascending)
  - fechaRegistro (Descending)
Query scope: Collection
```

#### Index 2: Estudiantes por rol y facultad
```
Collection: usuarios
Fields:
  - rol (Ascending)
  - facultad (Ascending)
  - fechaRegistro (Descending)
Query scope: Collection
```

#### Index 3: Tests de ansiedad por usuario y fecha
```
Collection: tests_ansiedad
Fields:
  - usuarioId (Ascending)
  - fechaRealizacion (Descending)
Query scope: Collection
```

#### Index 4: Observaciones por estudiante y fecha
```
Collection: observaciones
Fields:
  - estudianteId (Ascending)
  - fechaCreacion (Descending)
Query scope: Collection
```

#### Index 5: Citas por estudiante y fecha
```
Collection: citas
Fields:
  - estudianteId (Ascending)
  - fechaCita (Descending)
Query scope: Collection
```

## ⏱️ Tiempo de creación

Los indexes toman entre **2-10 minutos** en crearse. Mientras se crean verás un ícono de reloj.

Una vez creados, el error desaparecerá y las consultas serán mucho más rápidas.

## 🚀 Verifica que funciona

1. Espera a que todos los indexes muestren estado **"Enabled"** o **"Habilitado"**
2. Recarga tu app: `Ctrl+R` o `flutter run`
3. Navega al detalle del estudiante y regresa
4. El error no debería aparecer más

## ⚠️ Nota sobre Web vs Emulador

- En **desarrollo con emulador local**, los indexes NO son necesarios
- En **producción (Web con Firebase)**, los indexes SON obligatorios
- Por eso funciona cuando actualizas (hot reload) pero falla al navegar

---

## 📋 Resumen

El error de indexes es normal cuando usas consultas complejas en Firestore. Firebase te da el link directo para crear el index automáticamente. Solo haz clic y espera a que se cree.
