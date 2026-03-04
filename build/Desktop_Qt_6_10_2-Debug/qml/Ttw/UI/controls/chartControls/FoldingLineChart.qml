import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import Ttw.UI

Item {
    id: root

    // ==========================================
    // 1. 公开 API 配置 (多数据源升维)
    // ==========================================
    property string title: "系统折线图"

    // 🌟【核心改变】：使用 series 数组代替单线的 values
    // 格式要求：[{ name: "CPU", color: "#005FB8", data: [10, 20...] }, ...]
    property var series: []

    property var xLabels: []

    // 全局样式默认配置
    property color lineColor: Theme.accentColor || "#005FB8"
    property real lineWidth: 2
    property bool showGrid: true
    property bool showPoints: true
    property bool showFill: true
    property bool showLine: true
    property int yAxisTickCount: 5

    // ==========================================
    // 2. 智能多维数据分析 (计算全局极值)
    // ==========================================
    // 找出所有线中最长的数据长度，用于分配 X 轴
    property int maxDataLength: {
        let len = 0;
        for (let i = 0; i < series.length; i++) {
            let sData = series[i].data || [];
            if (sData.length > len) len = sData.length;
        }
        return len === 0 ? 1 : len;
    }

    // 找出所有线中的全局最高点
    property real rawMax: {
        let maxVal = -Infinity;
        for (let i = 0; i < series.length; i++) {
            let sData = series[i].data || [];
            if (sData.length > 0) {
                let m = Math.max.apply(null, sData);
                if (m > maxVal) maxVal = m;
            }
        }
        return maxVal === -Infinity ? 100 : maxVal;
    }

    // 找出所有线中的全局最低点
    property real rawMin: {
        let minVal = Infinity;
        for (let i = 0; i < series.length; i++) {
            let sData = series[i].data || [];
            if (sData.length > 0) {
                let m = Math.min.apply(null, sData);
                if (m < minVal) minVal = m;
            }
        }
        return minVal === Infinity ? 0 : minVal;
    }

    property real chartMin: rawMin >= 0 ? 0 : rawMin * 1.1
    property real chartMax: rawMax === 0 ? 100 : rawMax * 1.1

    // ==========================================
    // 3. 当前视口 (Viewport) 状态
    // ==========================================
    property real zoomMinX: 0
    property real zoomMaxX: Math.max(1, maxDataLength - 1)
    property real zoomMinY: chartMin
    property real zoomMaxY: chartMax
    property bool isZoomed: false

    function resetZoom() {
        zoomMinX = 0
        zoomMaxX = Math.max(1, maxDataLength - 1)
        zoomMinY = chartMin
        zoomMaxY = chartMax
        isZoomed = false
    }

    onSeriesChanged: { if (!isZoomed) resetZoom() }

    // ==========================================
    // 4. 布局划分 (Title / Y-Axis / X-Axis / Chart)
    // ==========================================
    // --- 4.1 顶部标题 ---
        Text {
            id: titleLabel
            text: root.title + (root.isZoomed ? " (右键还原)" : "")
            font.family: Theme.fontBody ? Theme.fontBody.family : "sans-serif"
            font.pixelSize: 18
            font.bold: true
            color: Theme.textPrimary || "#000000"

            anchors.top: parent.top
            // 🌟【修改】：改为水平居中对齐整个组件
            anchors.horizontalCenter: parent.horizontalCenter

            height: text === "" ? 0 : 30
        }

        // --- 4.2 动态图例区 (Legend) ---
        Row {
            id: legendRow
            anchors.top: titleLabel.bottom
            anchors.topMargin: 4

            // 🌟【修改】：改为水平居中对齐整个组件
            anchors.horizontalCenter: parent.horizontalCenter

            spacing: 20
            height: root.series.length > 0 ? 20 : 0
            visible: root.series.length > 0

            Repeater {
                model: root.series
                Row {
                    spacing: 6
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 10; height: 10; radius: 5
                        color: modelData.color || root.lineColor
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: modelData.name || "数据 " + (index + 1)
                        font.pixelSize: 12
                        color: Theme.textSecondary || "#666666"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
        // --- 4.3 左侧 Y 轴刻度区 ---
        Item {
            id: yAxisArea
            width: 40
            // 🌟【关键修改】：Y轴的顶部现在锚定在图例(legendRow)的下方，给图例让出空间
            anchors.top: legendRow.bottom
            anchors.bottom: xAxisArea.top
            anchors.left: parent.left
            anchors.topMargin: 16 // 距离图例稍微留点空隙

            Repeater {
                model: root.yAxisTickCount
                Text {
                    property real tickVal: root.zoomMinY + ((root.zoomMaxY - root.zoomMinY) / (root.yAxisTickCount - 1)) * index
                    text: Math.round(tickVal)
                    font.pixelSize: 12
                    color: Theme.textSecondary || "#666666"
                    anchors.right: parent.right
                    anchors.rightMargin: 8
                    y: yAxisArea.height - (index * (yAxisArea.height / (root.yAxisTickCount - 1))) - height / 2
                }
            }
        }



    Item {
        id: xAxisArea
        height: 30
        anchors.bottom: parent.bottom; anchors.left: chartArea.left; anchors.right: chartArea.right
        clip: true

        Repeater {
            model: root.xLabels.length > 0 ? root.xLabels : root.maxDataLength
            Text {
                text: root.xLabels.length > 0 ? root.xLabels[index] : (index + 1).toString()
                font.pixelSize: 12
                color: Theme.textSecondary || "#666666"
                x: chartArea.getX(index) - width / 2
                anchors.verticalCenter: parent.verticalCenter
                opacity: (x + width > 0 && x < xAxisArea.width) ? 1 : 0
            }
        }
    }

    // --- 4.4 核心图表绘制区 ---
    Item {
            id: chartArea
            anchors.top: yAxisArea.top; anchors.bottom: yAxisArea.bottom
            anchors.left: yAxisArea.right; anchors.right: parent.right
            anchors.rightMargin: 10
            clip: true

            function getX(index) {
                let rangeX = root.zoomMaxX - root.zoomMinX;
                if (rangeX === 0) return 0;
                return ((index - root.zoomMinX) / rangeX) * width;
            }
            function getY(value) {
                let rangeY = root.zoomMaxY - root.zoomMinY;
                if (rangeY === 0) return height;
                return height - ((value - root.zoomMinY) / rangeY) * height;
            }

            // 🌟【新增】：给折线图圈起一个外框
            Rectangle {
                anchors.fill: parent
                color: "transparent" // 背景透明，只留边框
                border.color: Theme.borderRest || "#CCCCCC" // 边框颜色，可以跟随你的主题
                border.width: 1
                z: 99 // 让边框显示在最上层，防止被里面的渐变填充遮挡边缘

                // 【可选】：如果你想阻止用户的鼠标点到外框上导致交互失效，加上这句
                MouseArea { anchors.fill: parent; acceptedButtons: Qt.NoButton }
            }

        // --- 1. 背景水平网格线 ---
        Repeater {
            model: root.showGrid ? root.yAxisTickCount : 0
            Rectangle {
                width: parent.width; height: 1
                color: Theme.borderRest || "#EAEAEA"
                y: parent.height - (index * (parent.height / (root.yAxisTickCount - 1)))
            }
        }

        // 🌟【核心改造 1】：循环画每一条折线与背景
        Repeater {
            model: root.series

            Shape {
                id: lineShape
                anchors.fill: parent
                layer.enabled: true
                layer.samples: 4

                // 提取单条线的数据和颜色
                property var sData: modelData.data || []
                property color sColor: modelData.color || root.lineColor

                property var dynamicPath: {
                    let pts = []
                    for (let i = 0; i < sData.length; i++) {
                        pts.push(Qt.point(chartArea.getX(i), chartArea.getY(sData[i])))
                    }
                    return pts
                }

                ShapePath {
                    strokeWidth: 0
                    fillGradient: LinearGradient {
                        y1: 0; y2: chartArea.height
                        GradientStop { position: 0.0; color: Qt.rgba(lineShape.sColor.r, lineShape.sColor.g, lineShape.sColor.b, 0.4) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                    PathPolyline {
                        path: {
                            if (!root.showFill || !root.showLine || lineShape.sData.length < 2) return []
                            let pts = Array.from(lineShape.dynamicPath)
                            pts.push(Qt.point(chartArea.getX(lineShape.sData.length - 1), chartArea.height))
                            pts.push(Qt.point(chartArea.getX(0), chartArea.height))
                            pts.push(pts[0])
                            return pts
                        }
                    }
                }

                ShapePath {
                    strokeWidth: root.lineWidth
                    strokeColor: lineShape.sColor
                    fillColor: "transparent"
                    joinStyle: ShapePath.RoundJoin
                    capStyle: ShapePath.RoundCap
                    PathPolyline {
                        path: (root.showLine && lineShape.sData.length >= 2) ? lineShape.dynamicPath : []
                    }
                }
            }
        }

        // --- 2. 交互画框底层 ---
        MouseArea {
            id: zoomMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            property real startX: 0
            property real startY: 0

            onPressed: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.resetZoom();
                    return;
                }
                startX = mouse.x; startY = mouse.y;
                rubberBand.x = mouse.x; rubberBand.y = mouse.y;
                rubberBand.width = 0; rubberBand.height = 0;
                rubberBand.visible = true;
            }

            onPositionChanged: (mouse) => {
                if (!rubberBand.visible) return;
                rubberBand.x = Math.min(startX, mouse.x);
                rubberBand.y = Math.min(startY, mouse.y);
                rubberBand.width = Math.abs(mouse.x - startX);
                rubberBand.height = Math.abs(mouse.y - startY);
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.RightButton) return;
                rubberBand.visible = false;
                if (rubberBand.width < 10 || rubberBand.height < 10) return;

                let rangeX = root.zoomMaxX - root.zoomMinX;
                let rangeY = root.zoomMaxY - root.zoomMinY;

                let newMinX = root.zoomMinX + (rubberBand.x / chartArea.width) * rangeX;
                let newMaxX = root.zoomMinX + ((rubberBand.x + rubberBand.width) / chartArea.width) * rangeX;

                let newMaxY = root.zoomMinY + ((chartArea.height - rubberBand.y) / chartArea.height) * rangeY;
                let newMinY = root.zoomMinY + ((chartArea.height - (rubberBand.y + rubberBand.height)) / chartArea.height) * rangeY;

                root.zoomMinX = newMinX; root.zoomMaxX = newMaxX;
                root.zoomMinY = newMinY; root.zoomMaxY = newMaxY;
                root.isZoomed = true;
            }
        }

        Rectangle {
            id: rubberBand
            color: Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.2)
            border.color: root.lineColor
            border.width: 1
            visible: false
        }

        // 🌟【核心改造 2】：嵌套循环画每条线上的点
        Repeater {
            model: root.series

            Item {
                anchors.fill: parent
                property var currentSeries: modelData
                property var sData: currentSeries.data || []
                property color sColor: currentSeries.color || root.lineColor

                Repeater {
                    model: root.showPoints ? sData : []

                    Rectangle {
                        property real exactX: chartArea.getX(index)
                        property real exactY: chartArea.getY(sData[index])

                        x: exactX - width / 2
                        y: exactY - height / 2
                        width: 10
                        height: 10
                        radius: 5
                        color: Theme.bgMain || "#FFFFFF"
                        border.width: 2
                        border.color: sColor

                        visible: exactX >= 0 && exactX <= chartArea.width && exactY >= 0 && exactY <= chartArea.height

                        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                        ToolTip.visible: dotMouseArea.containsMouse
                        // 🌟 显示名字和数值，例如： CPU: 45
                        ToolTip.text: (currentSeries.name ? currentSeries.name + ": " : "") + sData[index].toString()
                        ToolTip.delay: 100

                        MouseArea {
                            id: dotMouseArea
                            anchors.fill: parent
                            anchors.margins: -10
                            hoverEnabled: true
                            onPressed: (mouse) => mouse.accepted = false
                            onEntered: parent.scale = 1.5
                            onExited: parent.scale = 1.0
                        }
                    }
                }
            }
        }
    }
}
