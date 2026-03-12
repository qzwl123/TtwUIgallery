import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Ttw.UI
import TtwGalleryApp


Item {
    id: root
    anchors.fill: parent

    // 页面主滚动视图（防止屏幕太小显示不全）
    ScrollView {
        anchors.fill: parent
        anchors.margins: 30
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: parent.width
            spacing: 24

            // ==========================================
            // 1. 页面大标题与介绍
            // ==========================================
            Text {
                text: "折线图 (FoldingLineChart)"
                font.pixelSize: 28
                font.bold: true
                color: Theme.textPrimary || "#000000"
                Layout.fillWidth: true
            }

            Text {
                text: "用于展示多维度数据的趋势变化。支持自动缩放、多数据源、交互式 ToolTip 以及鼠标拖拽画框放大。"
                font.pixelSize: 14
                color: Theme.textSecondary || "#666666"
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
            }

            // ==========================================
            // 2. 实际的控件演示区 (包裹在卡片里)
            // ==========================================
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 450
                color: Theme.bgMain || "#FFFFFF"
                border.color: Theme.borderRest || "#EAEAEA"
                border.width: 1
                radius: Theme.radiusBase || 8

                // 🌟 召唤折线图组件
                FoldingLineChart {
                    anchors.fill: parent
                    anchors.margins: 20 // 留出一点内边距

                    title: "多系统资源占用对比"
                    // xLabels: ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
                    // series: [
                    //     { name: "CPU负载", color: "#005FB8", data: [20, 45, 88, 55, 30, 10, 5] },
                    //     { name: "内存使用率", color: "#107C10", data: [40, 42, 45, 60, 65, 50, 48] },
                    //     { name: "磁盘 I/O", color: "#E81123", data: [5, 10, 15, 8, 12, 5, 2] }
                    // ]

                    // 直接绑定 C++ 后台的动态属性
                    series: ChartDataProvider.dynamicSeries
                    // showFill: true
                    // showLine: true

                    // 🌟 2. 为了直观测试，我们在图表右上角加个刷新按钮
                    Button {
                        text: "🎲 刷新随机数据"
                        anchors.top: parent.top
                        anchors.right: parent.right
                        onClicked: {
                            // 调用 C++ 方法重新生成随机数
                            ChartDataProvider.generateRandomData()
                        }
                    }
                }
            }

            // ==========================================
            // 3. 源代码展示区 (彻底解耦！)
            // ==========================================
            Expander {
                Layout.fillWidth: true
                title: "查看 QML 源代码"
                iconText: "</>"
                isExpanded: false

                // 🌟 直接让 Expander 去读我们写好的独立文件！
                codeSource: Qt.resolvedUrl("snippets/chart/FoldingLineChartSnippet.txt") // qml
            }

            // 底部留白弹簧，防止内容贴底
            Item { Layout.fillHeight: true }
        }
    }
}
