# Casos de Prueba para Streakify

## 1. Gestión de Actividades

### 1.1 Crear Actividad

#### TC-ACT-001: Crear actividad básica
- **Precondiciones**: Usuario en pantalla principal
- **Pasos**:
  1. Presionar botón "+"
  2. Ingresar nombre "Ejercicio"
  3. Seleccionar icono
  4. Seleccionar color
  5. Guardar
- **Resultado esperado**: Actividad creada y visible en lista
- **Prioridad**: Alta

#### TC-ACT-002: Crear actividad con recurrencia diaria
- **Precondiciones**: Usuario en formulario de nueva actividad
- **Pasos**:
  1. Ingresar nombre
  2. Seleccionar recurrencia "Diaria"
  3. Guardar
- **Resultado esperado**: Actividad con recurrencia diaria configurada
- **Prioridad**: Alta

#### TC-ACT-003: Crear actividad con días específicos
- **Precondiciones**: Usuario en formulario de nueva actividad
- **Pasos**:
  1. Ingresar nombre
  2. Seleccionar recurrencia "Días específicos"
  3. Seleccionar Lunes, Miércoles, Viernes
  4. Guardar
- **Resultado esperado**: Actividad solo aparece en días seleccionados
- **Prioridad**: Alta

#### TC-ACT-004: Validación de nombre vacío
- **Precondiciones**: Usuario en formulario de nueva actividad
- **Pasos**:
  1. Dejar nombre vacío
  2. Intentar guardar
- **Resultado esperado**: Mensaje de error, no se crea actividad
- **Prioridad**: Media

#### TC-ACT-005: Crear actividad con categoría
- **Precondiciones**: Existe al menos una categoría
- **Pasos**:
  1. Crear nueva actividad
  2. Asignar categoría "Salud"
  3. Guardar
- **Resultado esperado**: Actividad asociada a categoría correcta
- **Prioridad**: Media

### 1.2 Editar Actividad

#### TC-ACT-006: Editar nombre de actividad
- **Precondiciones**: Existe actividad "Ejercicio"
- **Pasos**:
  1. Abrir actividad
  2. Editar nombre a "Gimnasio"
  3. Guardar
- **Resultado esperado**: Nombre actualizado en lista
- **Prioridad**: Alta

#### TC-ACT-007: Cambiar recurrencia de actividad
- **Precondiciones**: Actividad con recurrencia diaria
- **Pasos**:
  1. Editar actividad
  2. Cambiar a "Cada 2 días"
  3. Guardar
- **Resultado esperado**: Recurrencia actualizada, racha se mantiene
- **Prioridad**: Alta

#### TC-ACT-008: Editar color e icono
- **Precondiciones**: Actividad existente
- **Pasos**:
  1. Editar actividad
  2. Cambiar color a azul
  3. Cambiar icono
  4. Guardar
- **Resultado esperado**: Cambios visuales reflejados
- **Prioridad**: Baja

### 1.3 Eliminar Actividad

#### TC-ACT-009: Eliminar actividad sin confirmación
- **Precondiciones**: Actividad existente
- **Pasos**:
  1. Deslizar actividad
  2. Presionar eliminar
  3. Cancelar en diálogo
- **Resultado esperado**: Actividad no eliminada
- **Prioridad**: Media

#### TC-ACT-010: Eliminar actividad con confirmación
- **Precondiciones**: Actividad existente
- **Pasos**:
  1. Deslizar actividad
  2. Presionar eliminar
  3. Confirmar
- **Resultado esperado**: Actividad eliminada de lista y base de datos
- **Prioridad**: Alta

### 1.4 Completar Actividad

#### TC-ACT-011: Completar actividad por primera vez
- **Precondiciones**: Actividad nueva sin completar
- **Pasos**:
  1. Marcar actividad como completada
- **Resultado esperado**: Racha = 1, lastCompleted = hoy
- **Prioridad**: Crítica

#### TC-ACT-012: Completar actividad día consecutivo
- **Precondiciones**: Actividad con racha = 5
- **Pasos**:
  1. Completar actividad hoy
- **Resultado esperado**: Racha = 6
- **Prioridad**: Crítica

#### TC-ACT-013: Completar actividad después de saltar un día
- **Precondiciones**: Actividad completada hace 2 días
- **Pasos**:
  1. Completar actividad hoy
- **Resultado esperado**: Racha = 1 (reiniciada)
- **Prioridad**: Crítica

#### TC-ACT-014: Completar actividad dos veces mismo día
- **Precondiciones**: Actividad sin permitir múltiples completaciones
- **Pasos**:
  1. Completar actividad
  2. Intentar completar nuevamente
- **Resultado esperado**: No permite segunda completación
- **Prioridad**: Alta

#### TC-ACT-015: Múltiples completaciones diarias
- **Precondiciones**: Actividad con dailyGoal = 3
- **Pasos**:
  1. Completar 3 veces en el día
- **Resultado esperado**: todayCompletions = 3, meta alcanzada
- **Prioridad**: Alta

### 1.5 Búsqueda y Filtrado

#### TC-ACT-016: Buscar actividad por nombre
- **Precondiciones**: Múltiples actividades creadas
- **Pasos**:
  1. Ingresar "Ejercicio" en búsqueda
- **Resultado esperado**: Solo actividades con "Ejercicio" en nombre
- **Prioridad**: Media

#### TC-ACT-017: Filtrar por categoría
- **Precondiciones**: Actividades en diferentes categorías
- **Pasos**:
  1. Seleccionar filtro "Salud"
- **Resultado esperado**: Solo actividades de categoría Salud
- **Prioridad**: Media

#### TC-ACT-018: Filtrar por tag
- **Precondiciones**: Actividades con tags
- **Pasos**:
  1. Seleccionar tag "mañana"
- **Resultado esperado**: Actividades con tag "mañana"
- **Prioridad**: Media

## 2. Gamificación

### 2.1 Sistema de Medallas

#### TC-GAM-001: Otorgar medalla de bronce
- **Precondiciones**: Usuario sin medallas
- **Pasos**:
  1. Alcanzar racha de 7 días
- **Resultado esperado**: Medalla de bronce otorgada
- **Prioridad**: Alta

#### TC-GAM-002: Otorgar medalla de plata
- **Precondiciones**: Medalla de bronce obtenida
- **Pasos**:
  1. Alcanzar racha de 30 días
- **Resultado esperado**: Medalla de plata otorgada
- **Prioridad**: Alta

#### TC-GAM-003: Ver galería de medallas
- **Precondiciones**: Varias medallas obtenidas
- **Pasos**:
  1. Abrir pantalla de gamificación
  2. Ver sección de medallas
- **Resultado esperado**: Todas las medallas mostradas correctamente
- **Prioridad**: Media

#### TC-GAM-004: Medalla duplicada no se otorga
- **Precondiciones**: Medalla ya obtenida
- **Pasos**:
  1. Cumplir condición de medalla nuevamente
- **Resultado esperado**: No se duplica medalla
- **Prioridad**: Media

### 2.2 Sistema de Puntos

#### TC-GAM-005: Ganar puntos por completar actividad
- **Precondiciones**: Puntos totales = 100
- **Pasos**:
  1. Completar actividad (10 puntos)
- **Resultado esperado**: Puntos totales = 110
- **Prioridad**: Alta

#### TC-GAM-006: Gastar puntos en recuperación
- **Precondiciones**: Puntos = 500
- **Pasos**:
  1. Recuperar racha (costo 200 puntos)
- **Resultado esperado**: Puntos = 300
- **Prioridad**: Alta

#### TC-GAM-007: Intentar gastar más puntos de los disponibles
- **Precondiciones**: Puntos = 50
- **Pasos**:
  1. Intentar recuperar racha (costo 200)
- **Resultado esperado**: Operación rechazada, mensaje de error
- **Prioridad**: Alta

### 2.3 Niveles

#### TC-GAM-008: Subir de nivel
- **Precondiciones**: Nivel 1 con 990 puntos (límite 1000)
- **Pasos**:
  1. Ganar 20 puntos
- **Resultado esperado**: Nivel 2, notificación de nivel
- **Prioridad**: Media

#### TC-GAM-009: Ver progreso a siguiente nivel
- **Precondiciones**: Nivel 2 con 1200 puntos
- **Pasos**:
  1. Ver pantalla de gamificación
- **Resultado esperado**: Barra de progreso correcta
- **Prioridad**: Baja

### 2.4 Desafíos Semanales

#### TC-GAM-010: Generar desafío semanal
- **Precondiciones**: Inicio de semana
- **Pasos**:
  1. Abrir app el lunes
- **Resultado esperado**: Nuevo desafío semanal generado
- **Prioridad**: Media

#### TC-GAM-011: Completar desafío semanal
- **Precondiciones**: Desafío "Completar 20 actividades"
- **Pasos**:
  1. Completar 20 actividades en la semana
- **Resultado esperado**: Desafío marcado como completado, puntos bonus
- **Prioridad**: Media

#### TC-GAM-012: Progreso de desafío
- **Precondiciones**: Desafío activo
- **Pasos**:
  1. Completar 5 de 20 actividades
- **Resultado esperado**: Progreso 25% mostrado
- **Prioridad**: Baja

## 3. Notificaciones

### 3.1 Notificaciones Básicas

#### TC-NOT-001: Programar recordatorio diario
- **Precondiciones**: Permisos de notificación otorgados
- **Pasos**:
  1. Configurar recordatorio a las 9:00 AM
  2. Esperar a las 9:00 AM
- **Resultado esperado**: Notificación recibida a las 9:00 AM
- **Prioridad**: Alta

#### TC-NOT-002: Cancelar notificación
- **Precondiciones**: Notificación programada
- **Pasos**:
  1. Desactivar notificaciones
- **Resultado esperado**: Notificación cancelada
- **Prioridad**: Media

#### TC-NOT-003: Notificación por actividad
- **Precondiciones**: Actividad con notificación a las 18:00
- **Pasos**:
  1. Esperar a las 18:00
- **Resultado esperado**: Notificación específica de actividad
- **Prioridad**: Alta

### 3.2 Notificaciones Inteligentes

#### TC-NOT-004: Alerta de riesgo de racha
- **Precondiciones**: Actividad sin completar, 22:00 hrs
- **Pasos**:
  1. Esperar notificación de riesgo
- **Resultado esperado**: Notificación de advertencia
- **Prioridad**: Media

#### TC-NOT-005: Notificación de logro
- **Precondiciones**: A punto de desbloquear logro
- **Pasos**:
  1. Completar condición de logro
- **Resultado esperado**: Notificación inmediata de logro
- **Prioridad**: Media

#### TC-NOT-006: Mensaje motivacional
- **Precondiciones**: Configurado para recibir mensajes motivacionales
- **Pasos**:
  1. Esperar horario configurado
- **Resultado esperado**: Notificación con frase motivacional
- **Prioridad**: Baja

### 3.3 Resúmenes

#### TC-NOT-007: Resumen matutino
- **Precondiciones**: Configurado resumen a las 8:00 AM
- **Pasos**:
  1. Esperar a las 8:00 AM
- **Resultado esperado**: Notificación con actividades del día
- **Prioridad**: Media

#### TC-NOT-008: Resumen nocturno
- **Precondiciones**: Configurado resumen a las 21:00
- **Pasos**:
  1. Esperar a las 21:00
- **Resultado esperado**: Notificación con progreso del día
- **Prioridad**: Media

### 3.4 Horarios Óptimos

#### TC-NOT-009: Análisis de patrón de completación
- **Precondiciones**: Historial de 30 días
- **Pasos**:
  1. Solicitar análisis de horario óptimo
- **Resultado esperado**: Recomendación de mejor horario
- **Prioridad**: Baja

#### TC-NOT-010: Auto-ajuste de horario
- **Precondiciones**: Auto-ajuste activado
- **Pasos**:
  1. Completar actividad consistentemente a las 10:00
  2. Esperar análisis semanal
- **Resultado esperado**: Notificación ajustada a las 10:00
- **Prioridad**: Baja

## 4. Estadísticas

### 4.1 Estadísticas Básicas

#### TC-STA-001: Calcular tasa de éxito
- **Precondiciones**: 30 días desde creación, 24 completados
- **Pasos**:
  1. Ver estadísticas
- **Resultado esperado**: Tasa de éxito = 80%
- **Prioridad**: Media

#### TC-STA-002: Contador de días totales
- **Precondiciones**: Múltiples actividades
- **Pasos**:
  1. Ver estadísticas generales
- **Resultado esperado**: Suma correcta de todos los días
- **Prioridad**: Media

#### TC-STA-003: Actividades completadas hoy
- **Precondiciones**: 3 actividades completadas hoy
- **Pasos**:
  1. Ver pantalla principal
- **Resultado esperado**: Contador muestra 3
- **Prioridad**: Alta

### 4.2 Estadísticas Avanzadas

#### TC-STA-004: Mejor racha histórica
- **Precondiciones**: Actividad con rachas 10, 25, 15
- **Pasos**:
  1. Ver estadísticas de actividad
- **Resultado esperado**: Mejor racha = 25
- **Prioridad**: Media

#### TC-STA-005: Promedio de racha
- **Precondiciones**: Historial de rachas
- **Pasos**:
  1. Ver estadísticas avanzadas
- **Resultado esperado**: Promedio calculado correctamente
- **Prioridad**: Baja

#### TC-STA-006: Días perfectos
- **Precondiciones**: Días con todas las actividades completadas
- **Pasos**:
  1. Ver estadísticas
- **Resultado esperado**: Contador de días perfectos correcto
- **Prioridad**: Media

#### TC-STA-007: Heatmap de actividad
- **Precondiciones**: Historial de 1 año
- **Pasos**:
  1. Ver calendario de actividad
- **Resultado esperado**: Heatmap estilo GitHub con intensidades
- **Prioridad**: Baja

### 4.3 Tendencias

#### TC-STA-008: Tendencias semanales
- **Precondiciones**: 12 semanas de datos
- **Pasos**:
  1. Ver gráfico de tendencias semanales
- **Resultado esperado**: Gráfico con 12 puntos de datos
- **Prioridad**: Baja

#### TC-STA-009: Comparación mensual
- **Precondiciones**: Datos de 2 meses
- **Pasos**:
  1. Comparar mes actual vs anterior
- **Resultado esperado**: Porcentaje de mejora/declive
- **Prioridad**: Baja

#### TC-STA-010: Predicción de rachas
- **Precondiciones**: Historial suficiente
- **Pasos**:
  1. Solicitar predicción
- **Resultado esperado**: Estimación basada en promedio
- **Prioridad**: Baja

## 5. Backup y Exportación

### 5.1 Backup Local

#### TC-BAK-001: Crear backup manual
- **Precondiciones**: Datos en la app
- **Pasos**:
  1. Ir a configuración
  2. Crear backup
- **Resultado esperado**: Archivo JSON creado
- **Prioridad**: Alta

#### TC-BAK-002: Restaurar backup
- **Precondiciones**: Archivo de backup existente
- **Pasos**:
  1. Seleccionar archivo
  2. Confirmar restauración
- **Resultado esperado**: Datos restaurados correctamente
- **Prioridad**: Alta

#### TC-BAK-003: Backup automático
- **Precondiciones**: Configurado backup automático semanal
- **Pasos**:
  1. Esperar 7 días
- **Resultado esperado**: Backup creado automáticamente
- **Prioridad**: Media

#### TC-BAK-004: Listar backups
- **Precondiciones**: Múltiples backups creados
- **Pasos**:
  1. Ver lista de backups
- **Resultado esperado**: Todos los backups con fecha y tamaño
- **Prioridad**: Media

#### TC-BAK-005: Eliminar backup antiguo
- **Precondiciones**: Backup existente
- **Pasos**:
  1. Seleccionar backup
  2. Eliminar
- **Resultado esperado**: Backup eliminado del sistema
- **Prioridad**: Media

#### TC-BAK-006: Limpieza automática
- **Precondiciones**: Más de 5 backups automáticos
- **Pasos**:
  1. Crear nuevo backup automático
- **Resultado esperado**: Backup más antiguo eliminado
- **Prioridad**: Baja

### 5.2 Backup Cifrado

#### TC-BAK-007: Crear backup cifrado
- **Precondiciones**: Usuario en pantalla de backup
- **Pasos**:
  1. Seleccionar backup cifrado
  2. Ingresar contraseña "Test123!"
  3. Confirmar contraseña
  4. Crear
- **Resultado esperado**: Archivo cifrado creado
- **Prioridad**: Alta

#### TC-BAK-008: Restaurar backup cifrado con contraseña correcta
- **Precondiciones**: Backup cifrado existente
- **Pasos**:
  1. Seleccionar backup cifrado
  2. Ingresar contraseña correcta
  3. Restaurar
- **Resultado esperado**: Datos descifrados y restaurados
- **Prioridad**: Alta

#### TC-BAK-009: Restaurar backup cifrado con contraseña incorrecta
- **Precondiciones**: Backup cifrado existente
- **Pasos**:
  1. Seleccionar backup cifrado
  2. Ingresar contraseña incorrecta
  3. Intentar restaurar
- **Resultado esperado**: Error de descifrado, datos no restaurados
- **Prioridad**: Alta

### 5.3 Exportación

#### TC-BAK-010: Exportar a CSV
- **Precondiciones**: Actividades con historial
- **Pasos**:
  1. Exportar a CSV
- **Resultado esperado**: Archivo CSV con actividades y completaciones
- **Prioridad**: Media

#### TC-BAK-011: Exportar a Excel
- **Precondiciones**: Datos completos
- **Pasos**:
  1. Exportar a Excel
- **Resultado esperado**: Archivo Excel con múltiples hojas
- **Prioridad**: Media

#### TC-BAK-012: Compartir backup
- **Precondiciones**: Backup creado
- **Pasos**:
  1. Seleccionar backup
  2. Compartir
- **Resultado esperado**: Share sheet del sistema abierto
- **Prioridad**: Media

## 6. Seguridad

### 6.1 Autenticación Biométrica

#### TC-SEC-001: Activar huella digital
- **Precondiciones**: Dispositivo con sensor de huella
- **Pasos**:
  1. Activar seguridad biométrica
  2. Verificar huella
- **Resultado esperado**: Seguridad activada
- **Prioridad**: Alta

#### TC-SEC-002: Desbloquear con huella correcta
- **Precondiciones**: Seguridad biométrica activada
- **Pasos**:
  1. Cerrar app
  2. Abrir app
  3. Usar huella correcta
- **Resultado esperado**: App desbloqueada
- **Prioridad**: Alta

#### TC-SEC-003: Intentar desbloquear con huella incorrecta
- **Precondiciones**: Seguridad biométrica activada
- **Pasos**:
  1. Cerrar app
  2. Abrir app
  3. Usar huella incorrecta
- **Resultado esperado**: Acceso denegado
- **Prioridad**: Alta

#### TC-SEC-004: Fallback a PIN
- **Precondiciones**: Biometría falla 3 veces
- **Pasos**:
  1. Fallar biometría 3 veces
  2. Usar PIN alternativo
- **Resultado esperado**: App desbloqueada con PIN
- **Prioridad**: Media

### 6.2 Timeout de Sesión

#### TC-SEC-005: Bloqueo por inactividad
- **Precondiciones**: Timeout configurado a 5 minutos
- **Pasos**:
  1. Dejar app en background 5 minutos
  2. Volver a app
- **Resultado esperado**: Pantalla de bloqueo mostrada
- **Prioridad**: Media

## 7. Personalización

### 7.1 Temas

#### TC-PER-001: Cambiar a tema oscuro
- **Precondiciones**: Tema claro activo
- **Pasos**:
  1. Ir a configuración
  2. Seleccionar tema oscuro
- **Resultado esperado**: UI cambia a colores oscuros
- **Prioridad**: Media

#### TC-PER-002: Tema automático según hora
- **Precondiciones**: Tema automático activado
- **Pasos**:
  1. Esperar a las 20:00
- **Resultado esperado**: Tema cambia a oscuro automáticamente
- **Prioridad**: Baja

#### TC-PER-003: Crear tema personalizado
- **Precondiciones**: Usuario premium
- **Pasos**:
  1. Abrir creador de temas
  2. Seleccionar colores personalizados
  3. Guardar tema
- **Resultado esperado**: Tema personalizado aplicado
- **Prioridad**: Baja

### 7.2 Fuentes

#### TC-PER-004: Cambiar familia de fuente
- **Precondiciones**: Fuente actual "Roboto"
- **Pasos**:
  1. Seleccionar fuente "Inter"
- **Resultado esperado**: Toda la UI usa fuente Inter
- **Prioridad**: Baja

#### TC-PER-005: Ajustar tamaño de texto
- **Precondiciones**: Multiplicador = 1.0
- **Pasos**:
  1. Cambiar multiplicador a 1.3
- **Resultado esperado**: Texto 30% más grande
- **Prioridad**: Media

### 7.3 Densidad

#### TC-PER-006: Cambiar a densidad compacta
- **Precondiciones**: Densidad normal
- **Pasos**:
  1. Seleccionar densidad compacta
- **Resultado esperado**: Menos espaciado, más información visible
- **Prioridad**: Baja

#### TC-PER-007: Cambiar a densidad espaciosa
- **Precondiciones**: Densidad normal
- **Pasos**:
  1. Seleccionar densidad espaciosa
- **Resultado esperado**: Más espaciado entre elementos
- **Prioridad**: Baja

### 7.4 Localización

#### TC-PER-008: Cambiar formato de fecha
- **Precondiciones**: Formato DD/MM/YYYY
- **Pasos**:
  1. Cambiar a MM/DD/YYYY
- **Resultado esperado**: Fechas mostradas en nuevo formato
- **Prioridad**: Baja

#### TC-PER-009: Configurar inicio de día
- **Precondiciones**: Día inicia a medianoche
- **Pasos**:
  1. Cambiar inicio de día a 4:00 AM
- **Resultado esperado**: Actividades a las 3:00 AM cuentan para día anterior
- **Prioridad**: Media

## 8. Premium

### 8.1 Límites Freemium

#### TC-PRE-001: Crear actividad en límite gratuito
- **Precondiciones**: Usuario free con 4 actividades
- **Pasos**:
  1. Crear quinta actividad
- **Resultado esperado**: Actividad creada exitosamente
- **Prioridad**: Alta

#### TC-PRE-002: Intentar crear actividad sobre límite
- **Precondiciones**: Usuario free con 5 actividades
- **Pasos**:
  1. Intentar crear sexta actividad
- **Resultado esperado**: Mensaje de upgrade a premium
- **Prioridad**: Alta

#### TC-PRE-003: Acceder a función premium sin suscripción
- **Precondiciones**: Usuario free
- **Pasos**:
  1. Intentar crear tema personalizado
- **Resultado esperado**: Pantalla de upgrade mostrada
- **Prioridad**: Media

### 8.2 Suscripción

#### TC-PRE-004: Actualizar a premium mensual
- **Precondiciones**: Usuario free
- **Pasos**:
  1. Seleccionar plan mensual
  2. Completar compra (sandbox)
- **Resultado esperado**: Usuario premium, límites removidos
- **Prioridad**: Alta

#### TC-PRE-005: Restaurar compras
- **Precondiciones**: Compra previa en otra instalación
- **Pasos**:
  1. Presionar "Restaurar compras"
- **Resultado esperado**: Estado premium restaurado
- **Prioridad**: Alta

#### TC-PRE-006: Verificar expiración de suscripción
- **Precondiciones**: Suscripción expira mañana
- **Pasos**:
  1. Ver pantalla de premium
- **Resultado esperado**: Mensaje de renovación próxima
- **Prioridad**: Media

#### TC-PRE-007: Downgrade automático al expirar
- **Precondiciones**: Suscripción expira hoy
- **Pasos**:
  1. Abrir app después de expiración
- **Resultado esperado**: Usuario downgrade a free
- **Prioridad**: Alta

## 9. Social

### 9.1 Compartir

#### TC-SOC-001: Compartir logro
- **Precondiciones**: Logro desbloqueado
- **Pasos**:
  1. Abrir logro
  2. Presionar compartir
  3. Seleccionar app
- **Resultado esperado**: Texto e imagen compartidos
- **Prioridad**: Media

#### TC-SOC-002: Compartir racha
- **Precondiciones**: Racha de 30 días
- **Pasos**:
  1. Presionar compartir en actividad
- **Resultado esperado**: Mensaje con racha compartido
- **Prioridad**: Media

### 9.2 Perfil

#### TC-SOC-003: Crear perfil de usuario
- **Precondiciones**: Primera vez usando app
- **Pasos**:
  1. Ingresar nombre de usuario
  2. Seleccionar avatar
  3. Guardar
- **Resultado esperado**: Perfil creado
- **Prioridad**: Baja

#### TC-SOC-004: Editar perfil
- **Precondiciones**: Perfil existente
- **Pasos**:
  1. Cambiar nombre
  2. Guardar
- **Resultado esperado**: Perfil actualizado
- **Prioridad**: Baja

### 9.3 Buddies

#### TC-SOC-005: Agregar buddy
- **Precondiciones**: Sistema de buddies habilitado
- **Pasos**:
  1. Agregar buddy "Juan"
- **Resultado esperado**: Buddy en lista
- **Prioridad**: Baja

#### TC-SOC-006: Ver progreso de buddy
- **Precondiciones**: Buddy agregado
- **Pasos**:
  1. Abrir perfil de buddy
- **Resultado esperado**: Estadísticas de buddy visibles
- **Prioridad**: Baja

### 9.4 Grupos

#### TC-SOC-007: Crear grupo de accountability
- **Precondiciones**: Usuario en pantalla social
- **Pasos**:
  1. Crear grupo "Ejercicio Matutino"
  2. Agregar descripción
  3. Guardar
- **Resultado esperado**: Grupo creado
- **Prioridad**: Baja

#### TC-SOC-008: Ver racha grupal
- **Precondiciones**: Grupo con miembros activos
- **Pasos**:
  1. Abrir grupo
- **Resultado esperado**: Racha colectiva mostrada
- **Prioridad**: Baja

## 10. Accesibilidad

### 10.1 Lector de Pantalla

#### TC-ACC-001: Navegación con TalkBack
- **Precondiciones**: TalkBack activado
- **Pasos**:
  1. Navegar por pantalla principal
- **Resultado esperado**: Todos los elementos anunciados correctamente
- **Prioridad**: Alta

#### TC-ACC-002: Etiquetas semánticas
- **Precondiciones**: Lector de pantalla activo
- **Pasos**:
  1. Enfocar botón de completar
- **Resultado esperado**: "Marcar como completada" anunciado
- **Prioridad**: Alta

### 10.2 Alto Contraste

#### TC-ACC-003: Activar tema de alto contraste
- **Precondiciones**: Tema normal activo
- **Pasos**:
  1. Activar alto contraste
- **Resultado esperado**: Colores con mayor contraste
- **Prioridad**: Media

#### TC-ACC-004: Verificar ratio de contraste
- **Precondiciones**: Alto contraste activado
- **Pasos**:
  1. Medir contraste de texto principal
- **Resultado esperado**: Ratio ≥ 7:1 (AAA)
- **Prioridad**: Media

### 10.3 Reducción de Movimiento

#### TC-ACC-005: Desactivar animaciones
- **Precondiciones**: Animaciones activas
- **Pasos**:
  1. Activar reducción de movimiento
- **Resultado esperado**: Animaciones desactivadas
- **Prioridad**: Media

#### TC-ACC-006: Transiciones simples
- **Precondiciones**: Reducción de movimiento activa
- **Pasos**:
  1. Navegar entre pantallas
- **Resultado esperado**: Cambios instantáneos sin animación
- **Prioridad**: Media

### 10.4 Tamaños de Toque

#### TC-ACC-007: Verificar tamaño mínimo de botones
- **Precondiciones**: Configuración estándar
- **Pasos**:
  1. Medir botones interactivos
- **Resultado esperado**: Todos ≥ 44x44 px
- **Prioridad**: Alta

#### TC-ACC-008: Activar targets aumentados
- **Precondiciones**: Targets estándar
- **Pasos**:
  1. Activar targets aumentados
- **Resultado esperado**: Botones de 56x56 px
- **Prioridad**: Media

## 11. Widgets

### 11.1 Widget de Actividades

#### TC-WID-001: Agregar widget a home screen
- **Precondiciones**: App instalada
- **Pasos**:
  1. Agregar widget desde launcher
- **Resultado esperado**: Widget muestra actividades del día
- **Prioridad**: Media

#### TC-WID-002: Completar desde widget
- **Precondiciones**: Widget en home screen
- **Pasos**:
  1. Tap en checkbox de actividad
- **Resultado esperado**: Actividad marcada como completada
- **Prioridad**: Alta

#### TC-WID-003: Actualización de widget
- **Precondiciones**: Widget visible
- **Pasos**:
  1. Completar actividad desde app
- **Resultado esperado**: Widget se actualiza automáticamente
- **Prioridad**: Media

### 11.2 Widget de Estadísticas

#### TC-WID-004: Mostrar rachas en widget
- **Precondiciones**: Widget de stats agregado
- **Pasos**:
  1. Ver widget
- **Resultado esperado**: Rachas actuales mostradas
- **Prioridad**: Baja

### 11.3 Configuración de Widgets

#### TC-WID-005: Configurar widget
- **Precondiciones**: Widget agregado
- **Pasos**:
  1. Abrir configuración de widget
  2. Seleccionar solo actividades incompletas
  3. Guardar
- **Resultado esperado**: Widget muestra solo incompletas
- **Prioridad**: Media

## 12. Protectores de Racha

### 12.1 Congelamiento

#### TC-PRO-001: Congelar racha
- **Precondiciones**: Actividad con racha activa
- **Pasos**:
  1. Activar congelamiento por 3 días
- **Resultado esperado**: Racha congelada, no se pierde
- **Prioridad**: Alta

#### TC-PRO-002: Descongelar automáticamente
- **Precondiciones**: Racha congelada por 3 días
- **Pasos**:
  1. Esperar 3 días
- **Resultado esperado**: Racha descongelada automáticamente
- **Prioridad**: Media

#### TC-PRO-003: Límite de congelamiento
- **Precondiciones**: Ya usó 3 congelamientos este mes
- **Pasos**:
  1. Intentar congelar nuevamente
- **Resultado esperado**: Mensaje de límite alcanzado
- **Prioridad**: Media

### 12.2 Recuperación

#### TC-PRO-004: Recuperar racha con puntos
- **Precondiciones**: Racha perdida de 50 días, 500 puntos disponibles
- **Pasos**:
  1. Solicitar recuperación
  2. Confirmar gasto de puntos
- **Resultado esperado**: Racha recuperada con penalización (40 días)
- **Prioridad**: Alta

#### TC-PRO-005: Vista previa de recuperación
- **Precondiciones**: Racha perdida
- **Pasos**:
  1. Ver preview de recuperación
- **Resultado esperado**: Muestra racha recuperada y costo
- **Prioridad**: Media

#### TC-PRO-006: Recuperación sin puntos suficientes
- **Precondiciones**: 100 puntos, recuperación cuesta 200
- **Pasos**:
  1. Intentar recuperar
- **Resultado esperado**: Mensaje de puntos insuficientes
- **Prioridad**: Alta

## 13. Integración de Sistema

### 13.1 Permisos

#### TC-SYS-001: Solicitar permiso de notificaciones
- **Precondiciones**: Primera instalación
- **Pasos**:
  1. Abrir app
  2. Configurar primera notificación
- **Resultado esperado**: Diálogo de permiso mostrado
- **Prioridad**: Alta

#### TC-SYS-002: Manejar permiso denegado
- **Precondiciones**: Permiso de notificaciones denegado
- **Pasos**:
  1. Intentar programar notificación
- **Resultado esperado**: Mensaje explicativo, link a configuración
- **Prioridad**: Media

### 13.2 Compartir del Sistema

#### TC-SYS-003: Share sheet nativo
- **Precondiciones**: Contenido para compartir
- **Pasos**:
  1. Presionar compartir
- **Resultado esperado**: Share sheet del sistema abierto
- **Prioridad**: Media

## 14. Performance

### 14.1 Carga de Datos

#### TC-PRF-001: Lazy loading de actividades
- **Precondiciones**: 100+ actividades
- **Pasos**:
  1. Abrir lista de actividades
- **Resultado esperado**: Carga inicial < 1 segundo
- **Prioridad**: Media

#### TC-PRF-002: Paginación
- **Precondiciones**: Lista larga de actividades
- **Pasos**:
  1. Scroll hasta el final
- **Resultado esperado**: Siguiente página carga automáticamente
- **Prioridad**: Media

### 14.2 Caché

#### TC-PRF-003: Caché de imágenes
- **Precondiciones**: Iconos personalizados
- **Pasos**:
  1. Abrir actividad con icono
  2. Cerrar y reabrir
- **Resultado esperado**: Icono carga instantáneamente
- **Prioridad**: Baja

## 15. Casos de Borde

### 15.1 Datos Extremos

#### TC-EDG-001: Racha de 1000+ días
- **Precondiciones**: Actividad con racha muy larga
- **Pasos**:
  1. Ver actividad
- **Resultado esperado**: Número mostrado correctamente
- **Prioridad**: Baja

#### TC-EDG-002: Nombre de actividad muy largo
- **Precondiciones**: Crear actividad
- **Pasos**:
  1. Ingresar nombre de 200 caracteres
- **Resultado esperado**: Texto truncado con ellipsis
- **Prioridad**: Baja

#### TC-EDG-003: Sin conexión a internet
- **Precondiciones**: Modo avión activado
- **Pasos**:
  1. Usar app normalmente
- **Resultado esperado**: Funciones offline operan correctamente
- **Prioridad**: Alta

#### TC-EDG-004: Cambio de zona horaria
- **Precondiciones**: Viajar a otra zona horaria
- **Pasos**:
  1. Completar actividad
- **Resultado esperado**: Fecha correcta según zona horaria actual
- **Prioridad**: Media

#### TC-EDG-005: Cambio de fecha del sistema
- **Precondiciones**: Actividad con racha activa
- **Pasos**:
  1. Cambiar fecha del sistema a futuro
  2. Abrir app
- **Resultado esperado**: App detecta cambio, no permite trampa
- **Prioridad**: Alta

## Resumen de Prioridades

- **Crítica**: 3 casos
- **Alta**: 52 casos
- **Media**: 68 casos
- **Baja**: 32 casos

**Total**: 155 casos de prueba
