package com.streakify.streakify

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class StreakifyWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget)
            
            // Aquí puedes leer datos de Flutter usando widgetData
            // Por ejemplo: val title = widgetData.getString("title", "Default")
            // views.setTextViewText(R.id.widget_title, title)
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
