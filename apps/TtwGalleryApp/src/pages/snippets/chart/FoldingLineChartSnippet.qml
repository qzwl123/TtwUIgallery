FoldingLineChart {
    Layout.fillWidth: true
    Layout.preferredHeight: 350

    title: "多系统资源占用对比"
    xLabels: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]

    // 注入多条数据源
    series: [
        { name: "CPU负载", color: "#005FB8", data: [20, 45, 88, 55, 30, 10, 5] },
        { name: "内存使用率", color: "#107C10", data: [40, 42, 45, 60, 65, 50, 48] },
        { name: "磁盘 I/O", color: "#E81123", data: [5, 10, 15, 8, 12, 5, 2] }
    ]

    showFill: true
    showLine: true
}
