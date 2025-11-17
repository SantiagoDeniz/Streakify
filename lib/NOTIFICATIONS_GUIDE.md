# 🔔 Guía de Notificaciones Personalizadas por Actividad

## Descripción

El sistema de notificaciones personalizadas permite configurar recordatorios individuales para cada actividad en Streakify. Cada actividad puede tener su propia hora de notificación y mensaje personalizado.

## Características

### 🎯 Por Actividad
- Cada actividad tiene su propia configuración de notificación
- Habilitar/deshabilitar notificaciones independientemente
- Configuración persistente en SQLite

### ⏰ Horario Personalizado
- Selecciona la hora exacta (hora y minuto) para cada actividad
- Usa el TimePickerDialog nativo de Android
- Notificaciones diarias recurrentes

### 💬 Mensajes Personalizados
- Define un mensaje específico para cada actividad
- Mensaje por defecto si no se especifica: "¡Es hora de completar [nombre]!"
- Soporte para mensajes de múltiples líneas

### 🔄 Gestión Automática
- Las notificaciones se reprograman automáticamente al iniciar la app
- Al editar una actividad, sus notificaciones se actualizan
- Sistema de cancelación y reprogramación inteligente

## Cómo Usar

### Configurar Notificaciones

1. **Abrir configuración:**
   - En la lista de actividades, toca los 3 puntos (⋮) de cualquier actividad
   - Selecciona "Notificaciones"

2. **Habilitar/Deshabilitar:**
   - Usa el switch "Habilitar notificación"
   - El icono cambia según el estado (🔔 activo / 🔕 inactivo)

3. **Configurar hora:**
   - Toca el reloj grande para abrir el selector de tiempo
   - Selecciona hora y minuto
   - La notificación se enviará diariamente a esa hora

4. **Mensaje personalizado (opcional):**
   - Escribe tu mensaje en el campo de texto
   - Deja vacío para usar el mensaje por defecto
   - Soporta hasta 2 líneas

5. **Guardar:**
   - Toca "Guardar" para aplicar los cambios
   - Verás una confirmación con la hora configurada

### Gestionar Notificaciones

**Ver notificaciones activas:**
- Las actividades con notificaciones habilitadas muestran el icono 🔔 en el menú

**Editar notificación:**
- Abre nuevamente el diálogo desde el menú (⋮ → Notificaciones)
- Modifica hora, mensaje o estado
- Los cambios se aplican inmediatamente

**Desactivar notificación:**
- Abre el diálogo de notificaciones
- Desactiva el switch "Habilitar notificación"
- Guarda para cancelar la notificación programada

## Arquitectura Técnica

### Modelo de Datos

La clase `Activity` incluye 4 campos para notificaciones:

```dart
class Activity {
  // ... otros campos
  bool notificationsEnabled;      // Habilitar/deshabilitar
  int notificationHour;            // Hora (0-23)
  int notificationMinute;          // Minuto (0-59)
  String? customMessage;           // Mensaje personalizado (nullable)
}
```

**Valores por defecto:**
- `notificationsEnabled`: `false`
- `notificationHour`: `20` (8:00 PM)
- `notificationMinute`: `0`
- `customMessage`: `null`

### Base de Datos (SQLite v3)

**Tabla `activities` - Columnas de notificaciones:**

```sql
notificationsEnabled INTEGER DEFAULT 0,        -- 0=false, 1=true
notificationHour INTEGER DEFAULT 20,           -- Hora 24h
notificationMinute INTEGER DEFAULT 0,          -- Minuto
customMessage TEXT                             -- Mensaje o NULL
```

**Migración automática de v2 a v3:**

Al actualizar la app, la base de datos se migra automáticamente añadiendo estas 4 columnas con valores por defecto.

### NotificationService

**Métodos principales:**

1. **`scheduleActivityNotification(Activity activity)`**
   - Programa una notificación diaria para la actividad
   - Usa `activity.id.hashCode` como ID único de notificación
   - Solo programa si `notificationsEnabled == true`
   - Usa `AndroidScheduleMode.exactAllowWhileIdle` para precisión

2. **`cancelActivityNotification(Activity activity)`**
   - Cancela la notificación de la actividad
   - Útil al desactivar o eliminar actividades

3. **`updateActivityNotification(Activity activity)`**
   - Cancela y reprograma la notificación
   - Se usa al modificar configuración

4. **`rescheduleAllActivityNotifications(List<Activity> activities)`**
   - Cancela todas las notificaciones de actividades
   - Reprograma solo las que tienen `notificationsEnabled == true`
   - Se ejecuta automáticamente al iniciar la app

### Flujo de Datos

**Al iniciar la app:**
```
initState() 
  → _load() 
  → loadActivities() [ActivityService]
  → _initNotifications()
  → rescheduleAllActivityNotifications() [NotificationService]
```

**Al configurar notificación:**
```
Usuario abre diálogo
  → Modifica configuración (hora, mensaje, estado)
  → Guarda cambios
  → Actualiza Activity en setState()
  → _save() [ActivityService]
  → updateActivityNotification() [NotificationService]
  → Muestra SnackBar de confirmación
```

**Al recibir notificación:**
```
Sistema Android dispara notificación
  → Usuario toca notificación
  → _onNotificationTapped() [NotificationService]
  → payload contiene activity.id
  → (Futuro: navegar a la actividad específica)
```

## Canal de Notificaciones

**ID del canal:** `activity_reminders`
**Nombre:** Recordatorios de Actividades
**Descripción:** Recordatorios personalizados por actividad
**Importancia:** Alta
**Prioridad:** Alta

## Consideraciones

### Permisos
- Android 13+: Se requiere permiso `POST_NOTIFICATIONS`
- La app debe solicitar este permiso en tiempo de ejecución
- Las notificaciones no funcionarán sin este permiso

### Precisión
- Usa `AndroidScheduleMode.exactAllowWhileIdle`
- Garantiza que las notificaciones se envíen a tiempo exacto
- Funciona incluso si el dispositivo está en modo Doze

### Persistencia
- Las notificaciones sobreviven al reinicio de la app
- Se reprograman automáticamente al abrir la app
- La configuración se guarda en SQLite

### Limitaciones
- Máximo 500 notificaciones programadas (límite de Android)
- Las notificaciones no se disparan si la hora ya pasó hoy
- Se programan para el día siguiente en ese caso

## Mejoras Futuras

1. **Días de la semana:** Permitir elegir qué días recibir notificaciones
2. **Múltiples notificaciones:** Más de una notificación por actividad
3. **Sonidos personalizados:** Diferentes tonos para cada actividad
4. **Vibración configurable:** Patrones de vibración personalizados
5. **Navegación desde notificación:** Al tocar, ir directamente a la actividad
6. **Notificaciones de racha:** Alertas cuando estés a punto de perder una racha
7. **Resumen diario:** Notificación de resumen al final del día
8. **Notificaciones inteligentes:** Ajustar horarios según patrones de uso

## Solución de Problemas

### Las notificaciones no aparecen

1. Verifica que las notificaciones estén habilitadas en Configuración de Android
2. Asegúrate de haber concedido el permiso de notificaciones
3. Revisa que la hora configurada no haya pasado ya hoy
4. Verifica que el canal "Recordatorios de Actividades" no esté silenciado

### Las notificaciones llegan tarde

1. Verifica la configuración de batería de tu dispositivo
2. Excluye Streakify de la optimización de batería
3. En algunos dispositivos, permite "Iniciar automáticamente"

### Mensaje personalizado no se muestra

1. Verifica que guardaste los cambios
2. Asegúrate de que el mensaje no esté vacío
3. Espera a la siguiente notificación para ver el cambio

## Código de Referencia

**Ejemplo de uso directo del servicio:**

```dart
final notificationService = NotificationService();
final activity = Activity(
  id: '123',
  name: 'Ejercicio',
  notificationsEnabled: true,
  notificationHour: 8,
  notificationMinute: 30,
  customMessage: '¡Hora de hacer ejercicio! 💪',
);

// Programar notificación
await notificationService.scheduleActivityNotification(activity);

// Cancelar notificación
await notificationService.cancelActivityNotification(activity);

// Actualizar notificación
await notificationService.updateActivityNotification(activity);
```

---

**Documentación generada para Streakify v1.3**
*Fecha: 2024*
