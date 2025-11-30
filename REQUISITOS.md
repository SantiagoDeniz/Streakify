# Documento de Requisitos de Software (SRS) - Streakify

**Versión:** 1.0
**Fecha:** 30 de Noviembre de 2025

---

## 1. Introducción

### 1.1 Propósito
El propósito de este documento es definir los requisitos funcionales y no funcionales para "Streakify", una aplicación móvil de seguimiento de hábitos y rachas gamificada. Este documento servirá como guía para el desarrollo, pruebas y validación del software.

### 1.2 Alcance
Streakify es una aplicación desarrollada en Flutter para dispositivos móviles (Android/iOS) que permite a los usuarios crear, seguir y mantener hábitos diarios. El sistema incluye gestión de actividades, gamificación (medallas, niveles), estadísticas avanzadas, notificaciones inteligentes y opciones de personalización.

### 1.3 Definiciones y Acrónimos
- **Racha (Streak):** Contador de días consecutivos cumpliendo una actividad.
- **Actividad:** Hábito o tarea que el usuario desea rastrear.
- **Freeze/Congelamiento:** Mecanismo para pausar una racha sin perderla.
- **MVP:** Producto Mínimo Viable.
- **SRS:** Software Requirements Specification.

---

## 2. Descripción General

### 2.1 Perspectiva del Producto
Streakify es una aplicación autónoma que almacena datos localmente (SQLite) con capacidades de respaldo en la nube y exportación. Se enfoca en la retención de usuarios mediante técnicas de gamificación y una experiencia de usuario (UX) pulida.

### 2.2 Características de los Usuarios
- **Usuario Básico:** Busca rastrear 1-3 hábitos simples.
- **Usuario Avanzado (Power User):** Utiliza categorías, tags, estadísticas detalladas y personalización profunda.
- **Usuario Premium:** Accede a funciones ilimitadas y cosméticos exclusivos.

---

## 3. Requisitos Funcionales

### 3.1 Módulo de Gestión de Actividades
**RF-001: CRUD de Actividades**
- El sistema debe permitir crear, leer, actualizar y eliminar actividades.
- Datos requeridos: Nombre, Descripción (opcional), Icono (opcional), Color (opcional), Frecuencia (opcional, diaria por defecto).

**RF-002: Configuración de Frecuencia**
- Debe soportar: Diaria, Intervalos (cada N días), Días específicos de la semana.

**RF-003: Organización**
- Permitir asignar una Categoría y múltiples Tags a una actividad.
- Funcionalidad de archivado para actividades inactivas sin perder historial.

**RF-004: Registro de Progreso**
- Marcar actividad como completada/incompleta.
- Soporte para múltiples completaciones por día (contador).
- Registro de notas diarias (journaling) al completar.

### 3.2 Módulo de Gamificación
**RF-005: Sistema de Rachas**
- Calcular racha actual y mejor racha histórica.
- Implementar lógica de "Días Libres" (no rompen racha).
- Implementar "Racha Parcial" (ej. 5/7 días).

**RF-006: Medallas y Logros**
- Otorgar medallas (Bronce, Plata, Oro, Platino) basadas en hitos.
- Sistema de Logros desbloqueables (ej. "7 días seguidos", "Madrugador").

**RF-007: Niveles y Puntos**
- Calcular nivel de usuario basado en experiencia (XP) por actividades completadas.
- Sistema de "Puntos de Racha" canjeables.

**RF-008: Protectores de Racha**
- Ítems consumibles para recuperar o congelar rachas perdidas.
- Gestión de inventario de protectores.

### 3.3 Módulo de Notificaciones
**RF-009: Recordatorios Básicos**
- Notificaciones programables por actividad.
- Opción de múltiples recordatorios por actividad.

**RF-010: Notificaciones Inteligentes**
- Alertas de "Riesgo de Racha" antes de finalizar el día.
- Resúmenes diarios (Matutino/Nocturno).
- Ajuste automático de horarios basado en patrones de uso (ML básico).

### 3.4 Módulo de Estadísticas
**RF-011: Dashboard Principal**
- Vista resumen con rachas activas y completaciones del día.
- Gráficos de progreso semanal (sparklines).

**RF-012: Análisis Detallado**
- Calendario de calor (Heatmap) anual.
- Gráficos de barras y líneas para tendencias mensuales/semanales.
- Comparativas de rendimiento mes a mes.
- Tasa de éxito (%) y promedios.

### 3.5 Módulo de Datos y Seguridad
**RF-013: Persistencia Local**
- Almacenamiento seguro en base de datos relacional (SQLite).
- Migraciones automáticas de esquema.

**RF-014: Backup y Exportación**
- Generar backup completo en formato JSON/Cifrado.
- Exportación de datos legibles a CSV y Excel.
- Restauración de datos desde archivo de backup.

**RF-015: Seguridad**
- Bloqueo de aplicación mediante Biometría (Huella/FaceID) o PIN.
- Cifrado de backups exportados.

### 3.6 Módulo de Personalización
**RF-016: Temas y Apariencia**
- Soporte para Tema Claro y Oscuro.
- Cambio automático de tema según horario.
- Personalización de fuentes y densidad de interfaz.

**RF-017: Internacionalización**
- Soporte multi-idioma (Español, Inglés).
- Formatos de fecha y hora configurables.

### 3.7 Módulo Social
**RF-018: Compartir**
- Generar imágenes de estadísticas y logros para redes sociales.
- Perfil de usuario básico con estadísticas públicas.

**RF-019: Comunidad**
- Grupos de Accountability.
- Tablas de clasificación (Leaderboards).

### 3.8 Accesibilidad
**RF-020: Soporte Universal**
- Compatibilidad con lectores de pantalla (TalkBack/VoiceOver).
- Modos de alto contraste y soporte para daltonismo.
- Tamaños de toque mínimos de 44x44pt.

### 3.9 Widgets
**RF-021: Widgets de Pantalla de Inicio**
- Widget de lista de actividades (interactivo).
- Widget de estadísticas rápidas.
- Widget de calendario/heatmap.

---

## 4. Requisitos No Funcionales

### 4.1 Rendimiento
- **RNF-001:** Tiempo de inicio de la app < 2 segundos.
- **RNF-002:** Animaciones fluidas a 60fps constantes.
- **RNF-003:** Uso eficiente de batería y recursos en segundo plano.

### 4.2 Fiabilidad
- **RNF-004:** Cero pérdida de datos ante cierres inesperados.
- **RNF-005:** Sincronización correcta del estado de notificaciones.

### 4.3 Mantenibilidad
- **RNF-006:** Arquitectura limpia (Clean Architecture) con separación de capas.
- **RNF-007:** Cobertura de pruebas unitarias > 70%.
- **RNF-008:** Código documentado y siguiendo estándares de Flutter/Dart.

### 4.4 Usabilidad
- **RNF-009:** Diseño intuitivo que no requiera manual de usuario para funciones básicas.
- **RNF-010:** Feedback visual inmediato ante cualquier acción del usuario.

---

## 5. Modelo de Datos (Entidades Principales)

### 5.1 Activity
- ID, Nombre, Descripción, Icono, Color, Frecuencia, CategoríaID, Tags, Estado (Archivada/Activa).

### 5.2 Completion
- ID, ActivityID, Fecha, Timestamp, Nota.

### 5.3 UserStats
- RachaActual, MejorRacha, TotalCompletadas, Nivel, XP.

### 5.4 Achievement
- ID, Tipo, FechaDesbloqueo, Nivel.

---

## 6. Interfaz de Usuario (UI)

### 6.1 Pantallas Principales
- **Home:** Lista de actividades del día, barra de resumen.
- **Estadísticas:** Dashboard con gráficos y métricas.
- **Logros:** Galería de medallas y niveles.
- **Ajustes:** Configuración general, perfil, backups.

### 6.2 Componentes Clave
- **ActivityCard:** Tarjeta interactiva con gesto de completado y mini-gráfico.
- **Confetti:** Animación de celebración.
- **ThemeSelector:** Selector visual de temas.

---

## 7. Plan de Pruebas

### 7.1 Pruebas Unitarias
- Lógica de cálculo de rachas.
- Servicios de persistencia y backup.
- Modelos de datos y transformaciones.

### 7.2 Pruebas de Integración
- Flujo completo de creación -> completación -> visualización en estadísticas.
- Ciclo de vida de notificaciones.

### 7.3 Pruebas de UI
- Verificación de temas y traducciones.
- Accesibilidad y navegación por teclado.
