package com.streakify.streakify

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import android.view.View
import android.graphics.Color

class StreakifyStatsWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget_stats)
            
            try {
                val statsJson = widgetData.getString("widget_stats", "{}")
                val stats = JSONObject(statsJson)
                
                val totalStreak = stats.optInt("totalStreak", 0)
                val activeCount = stats.optInt("activeCount", 0)
                val bestStreak = stats.optInt("bestStreak", 0)
                val isDark = stats.optBoolean("isDark", false)
                
                // Actualizar textos
                views.setTextViewText(R.id.total_streak_value, totalStreak.toString())
                views.setTextViewText(R.id.active_habits_value, activeCount.toString())
                views.setTextViewText(R.id.best_streak_value, bestStreak.toString())
                
                // Aplicar tema (básico)
                if (isDark) {
                    views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_dark)
                    views.setTextColor(R.id.total_streak_value, Color.WHITE)
                    views.setTextColor(R.id.active_habits_value, Color.WHITE)
                    views.setTextColor(R.id.total_streak_label, Color.LTGRAY)
                    views.setTextColor(R.id.active_habits_label, Color.LTGRAY)
                    views.setTextColor(R.id.best_streak_label, Color.LTGRAY)
                } else {
                    views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                    views.setTextColor(R.id.total_streak_value, Color.BLACK)
                    views.setTextColor(R.id.active_habits_value, Color.BLACK)
                    views.setTextColor(R.id.total_streak_label, Color.DKGRAY)
                    views.setTextColor(R.id.active_habits_label, Color.DKGRAY)
                    views.setTextColor(R.id.best_streak_label, Color.DKGRAY)
                }
                
            } catch (e: Exception) {
                e.printStackTrace()
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
