#include "ChartDataProvider.h"
#include <QRandomGenerator>
#include <QVariant>

ChartDataProvider::ChartDataProvider(QObject *parent) : QObject(parent)
{
    // 1. 初始化满屏的“零”数据（或者初始随机数据），防止图表刚启动时是空的
    // for (int i = 0; i < MAX_POINTS; ++i) {
    //     m_cpuData.append(0);
    //     m_memData.append(0);
    //     m_ioData.append(0);
    // }

    // 2. 第一次立刻组装并下发数据
    appendRealtimeData();

    // 3. 🌟 开启高频定时器，每 1000 毫秒（1秒）刷新一次
    m_timer = new QTimer(this);
    connect(m_timer, &QTimer::timeout, this, &ChartDataProvider::appendRealtimeData);
    m_timer->start(1000);
}

QVariantList ChartDataProvider::dynamicSeries() const
{
    return m_dynamicSeries;
}

void ChartDataProvider::appendRealtimeData()
{
    // --- 核心算法：滑动窗口 ---
    // 1. 踢掉最老的数据 (队首)
    if (m_cpuData.size() >= MAX_POINTS) {
        m_cpuData.removeFirst();
        m_memData.removeFirst();
        m_ioData.removeFirst();
    }

    // 2. 追加最新的实时数据 (队尾)
    m_cpuData.append(QRandomGenerator::global()->bounded(10, 95));
    m_memData.append(QRandomGenerator::global()->bounded(30, 85));
    m_ioData.append(QRandomGenerator::global()->bounded(0, 30));

    // --- 组装丢给 QML 的 QVariantList ---
    QVariantList newSeries;

    // CPU 线
    QVariantMap cpuMap;
    cpuMap["name"] = "CPU负载";
    cpuMap["color"] = "#005FB8";
    // QVariant::fromValue 可以完美地把 C++ 的 QList<double> 转换成 QML 认识的 JS 数组
    cpuMap["data"] = QVariant::fromValue(m_cpuData);
    newSeries.append(cpuMap);

    // 内存线
    QVariantMap memMap;
    memMap["name"] = "内存使用率";
    memMap["color"] = "#107C10";
    memMap["data"] = QVariant::fromValue(m_memData);
    newSeries.append(memMap);

    // 磁盘 IO 线
    QVariantMap ioMap;
    ioMap["name"] = "磁盘 I/O";
    ioMap["color"] = "#E81123";
    ioMap["data"] = QVariant::fromValue(m_ioData);
    newSeries.append(ioMap);

    // --- 🌟 最关键的一步：更新属性并发射信号 ---
    m_dynamicSeries = newSeries;
    emit dynamicSeriesChanged();
    // QML 一旦收到这个信号，会立刻触发 Canvas 的 requestPaint() 进行毫秒级重绘！
}
