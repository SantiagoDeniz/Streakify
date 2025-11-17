package com.streakify.streakify

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray
import org.json.JSONObject

class StreakifyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            
            try {
                // Leer los datos de las actividades
                val activitiesJson = widgetData.getString("widget_activities", "[]")
                val activities = JSONArray(activitiesJson)
                
                // Obtener las primeras 3 actividades con las rachas más altas
                val topActivities = mutableListOf<JSONObject>()
                for (i in 0 until minOf(activities.length(), 3)) {
                    topActivities.add(activities.getJSONObject(i))
                }
                
                // Ordenar por racha (streak) descendente
                topActivities.sortByDescending { it.getInt("streak") }
                
                // Actualizar el widget con los datos
                when (topActivities.size) {
                    0 -> {
                        // Sin actividades
                        views.setTextViewText(R.id.widget_title, "🔥 Streakify")
                        views.setTextViewText(R.id.widget_subtitle, "Sin actividades activas")
                        views.setViewVisibility(R.id.activity_1_container, View.GONE)
                        views.setViewVisibility(R.id.activity_2_container, View.GONE)
                        views.setViewVisibility(R.id.activity_3_container, View.GONE)
                    }
                    else -> {
                        views.setTextViewText(R.id.widget_title, "🔥 Streakify")
                        views.setTextViewText(R.id.widget_subtitle, "Tus mejores rachas")
                        
                        // Mostrar cada actividad
                        for (i in 0 until minOf(topActivities.size, 3)) {
                            val activity = topActivities[i]
                            val name = activity.getString("name")
                            val streak = activity.getInt("streak")
                            
                            when (i) {
                                0 -> {
                                    views.setViewVisibility(R.id.activity_1_container, View.VISIBLE)
                                    views.setTextViewText(R.id.activity_name_1, name)
                                    views.setTextViewText(R.id.activity_streak_1, "🔥 $streak días")
                                }
                                1 -> {
                                    views.setViewVisibility(R.id.activity_2_container, View.VISIBLE)
                                    views.setTextViewText(R.id.activity_name_2, name)
                                    views.setTextViewText(R.id.activity_streak_2, "🔥 $streak días")
                                }
                                2 -> {
                                    views.setViewVisibility(R.id.activity_3_container, View.VISIBLE)
                                    views.setTextViewText(R.id.activity_name_3, name)
                                    views.setTextViewText(R.id.activity_streak_3, "🔥 $streak días")
                                }
                            }
                        }
                        
                        // Ocultar actividades no usadas
                        if (topActivities.size < 3) {
                            views.setViewVisibility(R.id.activity_3_container, View.GONE)
                        }
                        if (topActivities.size < 2) {
                            views.setViewVisibility(R.id.activity_2_container, View.GONE)
                        }
                    }
                }
                
            } catch (e: Exception) {
                // Error al parsear datos
                views.setTextViewText(R.id.widget_title, "🔥 Streakify")
                views.setTextViewText(R.id.widget_subtitle, "Abre la app para ver tus rachas")
                views.setViewVisibility(R.id.activity_1_container, View.GONE)
                views.setViewVisibility(R.id.activity_2_container, View.GONE)
                views.setViewVisibility(R.id.activity_3_container, View.GONE)
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
