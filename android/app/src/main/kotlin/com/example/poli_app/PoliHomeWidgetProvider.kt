package com.example.poli_app

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin

class PoliHomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)
        val text = widgetData.getString("home_widget_text", "Abra o app ❤️")

        appWidgetIds.forEach { appWidgetId ->
            val views = RemoteViews(context.packageName, R.layout.poli_home_widget).apply {
                setTextViewText(R.id.widget_text, text)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
