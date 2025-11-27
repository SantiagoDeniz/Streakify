package com.streakify.streakify

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONObject
import org.json.JSONArray
import android.graphics.Color
import java.util.Calendar
import java.text.SimpleDateFormat
import java.util.Locale

class StreakifyCalendarWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.home_widget_calendar)
            
            try {
                val calendarJson = widgetData.getString("widget_calendar", "{}")
                val calendarData = JSONObject(calendarJson)
                
                val completedDays = calendarData.optJSONArray("completedDays") ?: JSONArray()
                val isDark = calendarData.optBoolean("isDark", false)
                val monthYear = calendarData.optString("monthYear", "")
                val completionCount = calendarData.optInt("completionCount", 0)
                
                // Set month/year
                if (monthYear.isNotEmpty()) {
                    views.setTextViewText(R.id.month_year, monthYear)
                }
                
                // Set completion summary
                views.setTextViewText(R.id.completion_summary, "$completionCount días completados")
                
                // Get current month calendar data
                val calendar = Calendar.getInstance()
                val year = calendar.get(Calendar.YEAR)
                val month = calendar.get(Calendar.MONTH)
                val today = calendar.get(Calendar.DAY_OF_MONTH)
                
                // Get first day of month and total days
                calendar.set(year, month, 1)
                val firstDayOfWeek = calendar.get(Calendar.DAY_OF_WEEK) - 1 // 0 = Sunday
                val daysInMonth = calendar.getActualMaximum(Calendar.DAY_OF_MONTH)
                
                // Convert completedDays JSONArray to Set
                val completedSet = mutableSetOf<Int>()
                for (i in 0 until completedDays.length()) {
                    completedSet.add(completedDays.getInt(i))
                }
                
                // Apply theme
                if (isDark) {
                    views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background_dark)
                    views.setTextColor(R.id.widget_title, Color.parseColor("#FF6B35"))
                    views.setTextColor(R.id.month_year, Color.LTGRAY)
                    views.setTextColor(R.id.completion_summary, Color.LTGRAY)
                } else {
                    views.setInt(R.id.widget_container, "setBackgroundResource", R.drawable.widget_background)
                    views.setTextColor(R.id.widget_title, Color.parseColor("#FF6B35"))
                    views.setTextColor(R.id.month_year, Color.DKGRAY)
                    views.setTextColor(R.id.completion_summary, Color.DKGRAY)
                }
                
                // Fill calendar grid (35 cells = 5 weeks)
                for (cellIndex in 1..35) {
                    val dayId = context.resources.getIdentifier("day_$cellIndex", "id", context.packageName)
                    
                    val dayNumber = cellIndex - firstDayOfWeek
                    
                    if (dayNumber in 1..daysInMonth) {
                        // Valid day in current month
                        views.setTextViewText(dayId, dayNumber.toString())
                        
                        // Check if this day is completed
                        if (completedSet.contains(dayNumber)) {
                            // Completed day - highlight with orange background
                            views.setInt(dayId, "setBackgroundColor", Color.parseColor("#FF6B35"))
                            views.setTextColor(dayId, Color.WHITE)
                        } else if (dayNumber == today) {
                            // Today - subtle highlight
                            views.setInt(dayId, "setBackgroundColor", if (isDark) Color.parseColor("#3A3A3A") else Color.parseColor("#E0E0E0"))
                            views.setTextColor(dayId, if (isDark) Color.WHITE else Color.BLACK)
                        } else {
                            // Regular day
                            views.setInt(dayId, "setBackgroundColor", Color.TRANSPARENT)
                            views.setTextColor(dayId, if (isDark) Color.LTGRAY else Color.DKGRAY)
                        }
                    } else {
                        // Empty cell (before month starts or after it ends)
                        views.setTextViewText(dayId, "")
                        views.setInt(dayId, "setBackgroundColor", Color.TRANSPARENT)
                    }
                }
                
            } catch (e: Exception) {
                e.printStackTrace()
                // Set default error state
                views.setTextViewText(R.id.month_year, "Error")
                views.setTextViewText(R.id.completion_summary, "No hay datos")
            }
            
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
