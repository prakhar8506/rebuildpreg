package com.pregapp.pregapp

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class PregCareWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.preg_care_widget)
            views.setTextViewText(
                R.id.widget_greeting,
                widgetData.getString("greeting", "Mira"),
            )
            views.setTextViewText(
                R.id.widget_week,
                widgetData.getString("weekLabel", "Week —"),
            )
            views.setTextViewText(
                R.id.widget_water,
                widgetData.getString("water", "0 ml"),
            )
            views.setTextViewText(
                R.id.widget_visit,
                widgetData.getString("nextVisit", "No visit"),
            )
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
