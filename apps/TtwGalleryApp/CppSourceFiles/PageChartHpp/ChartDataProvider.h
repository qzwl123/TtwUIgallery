#ifndef CHARTDATAPROVIDER_H
#define CHARTDATAPROVIDER_H

#include <QObject>
#include <QQmlEngine>
#include <QVariantList>
#include <QVariantMap>
#include <QTimer>
#include <QList>
#include <QtQml/qqml.h>

class ChartDataProvider : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QVariantList dynamicSeries READ dynamicSeries NOTIFY dynamicSeriesChanged)

public:
    explicit ChartDataProvider(QObject *parent = nullptr);
    QVariantList dynamicSeries() const;

signals:
    void dynamicSeriesChanged();

private slots:
    // 🌟 定时器触发的槽函数：负责“踢掉老数据，追加新数据”
    void appendRealtimeData();

private:
    QVariantList m_dynamicSeries;

    QTimer *m_timer; // 定时器指针

    // 🌟 存放三条折线历史数据的独立容器
    QList<double> m_cpuData;
    QList<double> m_memData;
    QList<double> m_ioData;

    // 控制图表屏幕上最多显示多少个点（比如保持 15 个点）
    const int MAX_POINTS = 15;
};

#endif // CHARTDATAPROVIDER_H
