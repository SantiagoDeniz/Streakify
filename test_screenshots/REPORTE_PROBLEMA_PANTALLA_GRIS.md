# Reporte de Problema: Pantalla Gris al Intentar Completar Actividad

**Fecha:** 2025-01-24 20:06:28  
**Test Case:** TC-ACT-012 (Alternativo)  
**Severidad:** ALTA  

---

## 🔴 Problema Detectado

Al intentar **completar una actividad que ya fue completada el mismo día**, la aplicación muestra una **pantalla gris** en lugar de:
- Mostrar un mensaje de error/advertencia
- Mantener la interfaz actual sin cambios
- Prevenir la acción silenciosamente

---

## 📋 Contexto del Test

### Situación Inicial
- **Actividad:** Test Ejercicio
- **Estado:** Completada HOY (durante TC-ACT-011)
- **Racha:** 1
- **Última Completación:** 2025-01-24

### Acción Ejecutada
1. Usuario abrió la app
2. Localizó la actividad "Test Ejercicio"
3. Verificó que mostraba como completada (racha = 1)
4. **Intentó presionar sobre la actividad nuevamente**
5. **RESULTADO:** Pantalla gris

---

## 📸 Evidencia

### Screenshot 01: Estado Antes del Problema
- **Archivo:** `01_TC-ACT-012_alt_estado_actual_200551.png`
- **Descripción:** Muestra "Test Ejercicio" correctamente completada
- **Racha mostrada:** 1
- **Estado visual:** Normal

### Screenshot 02: Pantalla Gris
- **Archivo:** `02_TC-ACT-012_alt_intento_doble_200628.png`
- **Descripción:** Captura de la pantalla gris que apareció
- **Timestamp:** 20:06:28

---

## 🔍 Análisis Técnico

### Comportamiento Esperado
Al intentar completar una actividad ya completada hoy, la app debería:
1. **Opción A:** Detectar que ya está completada y no permitir la acción
2. **Opción B:** Mostrar un SnackBar/Toast: "Ya completaste esta actividad hoy"
3. **Opción C:** Deshabilitar el botón de completar cuando ya está completada

### Comportamiento Actual
- La app muestra una **pantalla gris completa**
- Esto sugiere:
  - Navegación a una pantalla vacía/sin contenido
  - Error no manejado que resulta en pantalla en blanco
  - Widget que no renderiza correctamente
  - Posible setState() problemático

---

## 🛠️ Posibles Causas

### Hipótesis 1: Navegación Incorrecta
La lógica de completar actividad podría estar navegando a una pantalla de "detalles" o "resultado" que no maneja correctamente el caso de "ya completada".

```dart
// Código sospechoso (hipotético)
onTap: () {
  // Si la actividad ya está completada, esto podría fallar
  Navigator.push(context, MaterialPageRoute(
    builder: (_) => ActivityDetailScreen(activity: activity)
  ));
}
```

### Hipótesis 2: Error en setState
Al intentar actualizar el estado de una actividad ya completada, podría haber un error que rompe la UI.

```dart
// Posible código problemático
void completeActivity() {
  setState(() {
    // Si la lógica no valida que ya está completada...
    activity.complete(); // Esto podría fallar internamente
  });
}
```

### Hipótesis 3: Widget Condicional Mal Configurado
El widget que muestra la lista de actividades podría tener condiciones que resultan en renderizar un Container vacío.

```dart
// Ejemplo de código problemático
Widget build(BuildContext context) {
  if (activity.completedToday && someCondition) {
    return Container(); // Pantalla gris
  }
  return ActivityCard(...);
}
```

---

## 📊 Impacto

### Severidad: ALTA
- **Usuario:** Experiencia muy pobre, la app parece "rota"
- **Funcionalidad:** Impide que el usuario vuelva a ver sus actividades sin reiniciar
- **Credibilidad:** Da impresión de app inestable

### Casos Afectados
- ✅ TC-ACT-011: No afectado (primera completación funciona)
- ❌ TC-ACT-012: Bloqueado por este problema
- ❓ TC-ACT-013: Posiblemente afectado si el problema es en navegación

---

## 🔧 Recomendaciones de Investigación

### 1. Revisar Lógica de Completar Actividad
**Archivos a revisar:**
- `lib/screens/activities_list_screen.dart` (o similar)
- `lib/screens/activity_detail_screen.dart` (si existe)
- `lib/widgets/activity_card.dart` (o widget de actividad)

**Buscar:**
- `onTap` en ActivityCard
- Navegación con `Navigator.push`
- Validación de `isCompletedToday`

### 2. Revisar Logs de Error
**Comando sugerido:**
```powershell
adb logcat -d | Select-String -Pattern "flutter|error|exception" -CaseSensitive:$false
```

### 3. Verificar Estado de Navegación
**Pregunta clave:** ¿La pantalla gris es una pantalla nueva o la pantalla actual se volvió gris?
- Si es nueva pantalla: Problema en navegación
- Si es la misma: Problema en setState/rebuild

---

## ✅ Próximos Pasos

1. **INMEDIATO:** Revisar logs de Android con `adb logcat` para ver errores
2. **CORTO PLAZO:** 
   - Examinar código de `ActivityCard` o widget similar
   - Verificar lógica de navegación al tocar actividad completada
   - Añadir validación: "if (activity.isCompletedToday) return;"
3. **MEDIANO PLAZO:**
   - Implementar manejo de errores robusto
   - Añadir feedback visual claro para actividades completadas
   - Crear tests unitarios para este caso específico

---

## 📝 Notas Adicionales

- Este problema **no impide** probar TC-ACT-012 completo mañana (cuando "Test Ejercicio" pueda completarse nuevamente)
- Sugiere que puede haber **otros casos edge** no manejados correctamente
- La detección de este problema es **valiosa** - es mejor encontrarlo ahora que en producción

---

**Estado del Test:** ⚠️ INCOMPLETO - Problema encontrado  
**Acción Requerida:** Investigación de código + Corrección  
**Tests Bloqueados:** TC-ACT-012 (completo), posiblemente TC-ACT-013  
