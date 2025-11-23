package com.streakify.streakify

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProviderInfo
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import android.graphics.Color
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
            // Determinar el tamaño del widget para elegir el layout
            val options = appWidgetManager.getAppWidgetOptions(widgetId)
            val minWidth = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH)
            val minHeight = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT)
            
            // Lógica simple para determinar layout basado en tamaño
            // Small: ~110x110
            // Medium: ~250x110
            // Large: ~250x250 (default)
            
            val layoutId = when {
                minWidth < 150 && minHeight < 150 -> R.layout.home_widget_small
                minHeight < 150 -> R.layout.home_widget_medium
                else -> R.layout.home_widget
            }
            
            val views = RemoteViews(context.packageName, layoutId)
            
            try {
                // Leer los datos
                val activitiesJson = widgetData.getString("widget_activities", "{}")
                val data = JSONObject(activitiesJson)
                val activities = data.optJSONArray("activities") ?: JSONArray()
                val isDark = data.optBoolean("isDark", false)
                
                // Aplicar tema
                applyTheme(views, isDark, layoutId)
                
                // Actualizar contenido según el layout
                when (layoutId) {
                    R.layout.home_widget_small -> updateSmallWidget(views, activities)
                    R.layout.home_widget_medium -> updateMediumWidget(views, activities)
                    else -> updateLargeWidget(views, activities)
                }
                
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
    
    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        // Forzar actualización cuando cambia el tamaño
        val widgetData = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), widgetData)
    }
    
    private fun applyTheme(views: RemoteViews, isDark: Boolean, layoutId: Int) {
        if (isDark) {
            views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_dark)
            views.setTextColor(R.id.widget_title, Color.parseColor("#FF6B35"))
            
            // Ajustar colores de textos según layout
            if (layoutId == R.layout.home_widget_small) {
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setTextColor(R.id.activity_name_1, Color.WHITE)
            } else if (layoutId == R.layout.home_widget_medium) {
                views.setTextColor(R.id.widget_subtitle, Color.LTGRAY)
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setInt(R.id.activity_2_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setTextColor(R.id.activity_name_1, Color.WHITE)
                views.setTextColor(R.id.activity_name_2, Color.WHITE)
            } else {
                views.setTextColor(R.id.widget_subtitle, Color.LTGRAY)
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setInt(R.id.activity_2_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setInt(R.id.activity_3_container, "setBackgroundResource", R.drawable.card_background_dark)
                views.setTextColor(R.id.activity_name_1, Color.WHITE)
                views.setTextColor(R.id.activity_name_2, Color.WHITE)
                views.setTextColor(R.id.activity_name_3, Color.WHITE)
            }
        } else {
            views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
            views.setTextColor(R.id.widget_title, Color.parseColor("#FF6B35"))
            
            if (layoutId == R.layout.home_widget_small) {
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background)
                views.setTextColor(R.id.activity_name_1, Color.BLACK)
            } else if (layoutId == R.layout.home_widget_medium) {
                views.setTextColor(R.id.widget_subtitle, Color.parseColor("#666666"))
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background)
                views.setInt(R.id.activity_2_container, "setBackgroundResource", R.drawable.card_background)
                views.setTextColor(R.id.activity_name_1, Color.BLACK)
                views.setTextColor(R.id.activity_name_2, Color.BLACK)
            } else {
                views.setTextColor(R.id.widget_subtitle, Color.parseColor("#666666"))
                views.setInt(R.id.activity_1_container, "setBackgroundResource", R.drawable.card_background)
                views.setInt(R.id.activity_2_container, "setBackgroundResource", R.drawable.card_background)
                views.setInt(R.id.activity_3_container, "setBackgroundResource", R.drawable.card_background)
                views.setTextColor(R.id.activity_name_1, Color.BLACK)
                views.setTextColor(R.id.activity_name_2, Color.BLACK)
                views.setTextColor(R.id.activity_name_3, Color.BLACK)
            }
        }
    }

    private fun updateSmallWidget(views: RemoteViews, activities: JSONArray) {
        if (activities.length() > 0) {
            val activity = activities.getJSONObject(0)
            views.setTextViewText(R.id.activity_name_1, activity.getString("name"))
            views.setTextViewText(R.id.activity_streak_1, "🔥 ${activity.getInt("streak")}")
        } else {
            views.setTextViewText(R.id.activity_name_1, "Sin datos")
            views.setTextViewText(R.id.activity_streak_1, "-")
        }
    }

    private fun updateMediumWidget(views: RemoteViews, activities: JSONArray) {
        // Activity 1
        if (activities.length() > 0) {
            val a1 = activities.getJSONObject(0)
            views.setViewVisibility(R.id.activity_1_container, View.VISIBLE)
            views.setTextViewText(R.id.activity_name_1, a1.getString("name"))
            views.setTextViewText(R.id.activity_streak_1, "🔥 ${a1.getInt("streak")}")
        } else {
            views.setViewVisibility(R.id.activity_1_container, View.GONE)
        }

        // Activity 2
        if (activities.length() > 1) {
            val a2 = activities.getJSONObject(1)
            views.setViewVisibility(R.id.activity_2_container, View.VISIBLE)
            views.setTextViewText(R.id.activity_name_2, a2.getString("name"))
            views.setTextViewText(R.id.activity_streak_2, "🔥 ${a2.getInt("streak")}")
        } else {
            views.setViewVisibility(R.id.activity_2_container, View.GONE)
        }
    }

    private fun updateLargeWidget(views: RemoteViews, activities: JSONArray) {
        // Activity 1
        if (activities.length() > 0) {
            val a1 = activities.getJSONObject(0)
            views.setViewVisibility(R.id.activity_1_container, View.VISIBLE)
            views.setTextViewText(R.id.activity_name_1, a1.getString("name"))
            views.setTextViewText(R.id.activity_streak_1, "🔥 ${a1.getInt("streak")} días")
        } else {
            views.setViewVisibility(R.id.activity_1_container, View.GONE)
        }

        // Activity 2
        if (activities.length() > 1) {
            val a2 = activities.getJSONObject(1)
            views.setViewVisibility(R.id.activity_2_container, View.VISIBLE)
            views.setTextViewText(R.id.activity_name_2, a2.getString("name"))
            views.setTextViewText(R.id.activity_streak_2, "🔥 ${a2.getInt("streak")} días")
        } else {
            views.setViewVisibility(R.id.activity_2_container, View.GONE)
        }

        // Activity 3
        if (activities.length() > 2) {
            val a3 = activities.getJSONObject(2)
            views.setViewVisibility(R.id.activity_3_container, View.VISIBLE)
            views.setTextViewText(R.id.activity_name_3, a3.getString("name"))
            views.setTextViewText(R.id.activity_streak_3, "🔥 ${a3.getInt("streak")} días")
        } else {
            views.setViewVisibility(R.id.activity_3_container, View.GONE)
        }
    }
}
