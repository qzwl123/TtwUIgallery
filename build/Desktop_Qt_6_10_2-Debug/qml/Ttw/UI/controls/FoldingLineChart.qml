import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts
import QtQuick.Controls
import Ttw.UI

Item {
    id: root

    // ==========================================
    // 1. 公开 API 配置
    // ==========================================
    property string title: "系统折线图"
    property var values: []
    property var xLabels: []

    property color lineColor: Theme.accentColor || "#005FB8"
    property real lineWidth: 2
    property bool showGrid: true
    property bool showPoints: true
    property bool showFill: true
    property bool showLine: true
    property int yAxisTickCount: 5

    // ==========================================
    // 2. 原始极值与当前视口 (Viewport) 状态
    // ==========================================
    property real rawMax: values.length > 0 ? Math.max.apply(null, values) : 100
    property real rawMin: values.length > 0 ? Math.min.apply(null, values) : 0
    property real chartMin: rawMin >= 0 ? 0 : rawMin * 1.1
    property real chartMax: rawMax === 0 ? 100 : rawMax * 1.1

    // 🌟【新增】：当前视口的边界范围
    property real zoomMinX: 0
    property real zoomMaxX: Math.max(1, values.length - 1)
    property real zoomMinY: chartMin
    property real zoomMaxY: chartMax
    property bool isZoomed: false

    // 恢复原始比例的函数
    function resetZoom() {
        zoomMinX = 0
        zoomMaxX = Math.max(1, values.length - 1)
        zoomMinY = chartMin
        zoomMaxY = chartMax
        isZoomed = false
    }

    // 数据变化时，如果没有被缩放，自动更新视口
    onValuesChanged: { if (!isZoomed) resetZoom() }

    // ==========================================
    // 3. 布局划分 (Title / Y-Axis / X-Axis / Chart)
    // ==========================================
    Text {
        id: titleLabel
        text: root.title + (root.isZoomed ? " (右键还原)" : "") // 缩放时给出提示
        font.family: Theme.fontBody ? Theme.fontBody.family : "sans-serif"
        font.pixelSize: 18
        font.bold: true
        color: Theme.textPrimary || "#000000"
        anchors.top: parent.top; anchors.left: parent.left
        height: text === "" ? 0 : 30
    }

    Item {
        id: yAxisArea
        width: 40
        anchors.top: titleLabel.bottom; anchors.bottom: xAxisArea.top; anchors.left: parent.left
        anchors.topMargin: 20

        Repeater {
            model: root.yAxisTickCount
            Text {
                // 🌟【修改】：根据当前的 Zoom 视口动态计算 Y 轴刻度
                property real tickVal: root.zoomMinY + ((root.zoomMaxY - root.zoomMinY) / (root.yAxisTickCount - 1)) * index
                text: Math.round(tickVal)
                font.pixelSize: 12
                color: Theme.textSecondary || "#666666"
                anchors.right: parent.right; anchors.rightMargin: 8
                y: yAxisArea.height - (index * (yAxisArea.height / (root.yAxisTickCount - 1))) - height / 2
            }
        }
    }

    Item {
        id: xAxisArea
        height: 30
        anchors.bottom: parent.bottom; anchors.left: chartArea.left; anchors.right: chartArea.right
        clip: true // 🌟【新增】：放大后 X 轴文字可能会跑出边界，必须裁剪

        Repeater {
            model: root.xLabels.length > 0 ? root.xLabels : root.values.length
            Text {
                text: root.xLabels.length > 0 ? root.xLabels[index] : (index + 1).toString()
                font.pixelSize: 12
                color: Theme.textSecondary || "#666666"
                // 🌟【修改】：根据当前 X 轴视口动态移动文字位置
                x: chartArea.getX(index) - width / 2
                anchors.verticalCenter: parent.verticalCenter
                // 如果文字跑出视口，降低透明度或者隐藏（增强视觉体验）
                opacity: (x + width > 0 && x < xAxisArea.width) ? 1 : 0
            }
        }
    }

    // --- 3.4 核心图表绘制区 ---
    Item {
        id: chartArea
        anchors.top: yAxisArea.top; anchors.bottom: yAxisArea.bottom
        anchors.left: yAxisArea.right; anchors.right: parent.right
        anchors.rightMargin: 10
        clip: true // 🌟【新增】：必须裁剪！否则放大后的折线会画到屏幕外面

        // 🌟【修改核心算法】：利用 Zoom 视口进行坐标映射
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

        // 背景水平网格线
        Repeater {
            model: root.showGrid ? root.yAxisTickCount : 0
            Rectangle {
                width: parent.width; height: 1
                color: Theme.borderRest || "#EAEAEA"
                y: parent.height - (index * (parent.height / (root.yAxisTickCount - 1)))
            }
        }

        // 折线与填充 (利用 Shape)
        Shape {
            id: chartShape
            anchors.fill: parent
            layer.enabled: true
            layer.samples: 4

            property var dynamicPath: {
                let pts = []
                for (let i = 0; i < root.values.length; i++) {
                    pts.push(Qt.point(chartArea.getX(i), chartArea.getY(root.values[i])))
                }
                return pts
            }

            ShapePath {
                strokeWidth: 0
                fillGradient: LinearGradient {
                    y1: 0; y2: chartArea.height
                    GradientStop { position: 0.0; color: Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.4) }
                    GradientStop { position: 1.0; color: "transparent" }
                }
                PathPolyline {
                    path: {
                        if (!root.showFill || !root.showLine || root.values.length < 2) return []
                        let pts = Array.from(chartShape.dynamicPath)
                        pts.push(Qt.point(chartArea.getX(root.values.length - 1), chartArea.height))
                        pts.push(Qt.point(chartArea.getX(0), chartArea.height))
                        pts.push(pts[0])
                        return pts
                    }
                }
            }

            ShapePath {
                strokeWidth: root.lineWidth
                strokeColor: root.lineColor
                fillColor: "transparent"
                joinStyle: ShapePath.RoundJoin
                capStyle: ShapePath.RoundCap
                PathPolyline {
                    path: (root.showLine && root.values.length >= 2) ? chartShape.dynamicPath : []
                }
            }
        }

        // 🌟【新增】：画框放大的交互底层区域
        MouseArea {
            id: zoomMouseArea
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton // 允许左键画框，右键重置

            property real startX: 0
            property real startY: 0

            onPressed: (mouse) => {
                if (mouse.button === Qt.RightButton) {
                    root.resetZoom();
                    return;
                }
                startX = mouse.x;
                startY = mouse.y;
                rubberBand.x = mouse.x;
                rubberBand.y = mouse.y;
                rubberBand.width = 0;
                rubberBand.height = 0;
                rubberBand.visible = true;
            }

            onPositionChanged: (mouse) => {
                if (!rubberBand.visible) return;
                // 支持任意方向的拖拽画框
                rubberBand.x = Math.min(startX, mouse.x);
                rubberBand.y = Math.min(startY, mouse.y);
                rubberBand.width = Math.abs(mouse.x - startX);
                rubberBand.height = Math.abs(mouse.y - startY);
            }

            onReleased: (mouse) => {
                if (mouse.button === Qt.RightButton) return;
                rubberBand.visible = false;

                // 如果仅仅是点了一下（框太小），就不执行放大，防止误触
                if (rubberBand.width < 10 || rubberBand.height < 10) return;

                // 【核心算法】：将选中的像素框坐标，反向推导为实际的视口数据范围
                let rangeX = root.zoomMaxX - root.zoomMinX;
                let rangeY = root.zoomMaxY - root.zoomMinY;

                let newMinX = root.zoomMinX + (rubberBand.x / chartArea.width) * rangeX;
                let newMaxX = root.zoomMinX + ((rubberBand.x + rubberBand.width) / chartArea.width) * rangeX;

                // Y 轴是倒置的
                let newMaxY = root.zoomMinY + ((chartArea.height - rubberBand.y) / chartArea.height) * rangeY;
                let newMinY = root.zoomMinY + ((chartArea.height - (rubberBand.y + rubberBand.height)) / chartArea.height) * rangeY;

                // 更新视口，触发全图重绘！
                root.zoomMinX = newMinX;
                root.zoomMaxX = newMaxX;
                root.zoomMinY = newMinY;
                root.zoomMaxY = newMaxY;
                root.isZoomed = true;
            }
        }

        // 🌟【新增】：半透明蓝色选取框
        Rectangle {
            id: rubberBand
            color: Qt.rgba(root.lineColor.r, root.lineColor.g, root.lineColor.b, 0.2)
            border.color: root.lineColor
            border.width: 1
            visible: false
        }

        // 交互点 (Dots)
        Repeater {
            model: root.showPoints ? root.values : []
            Rectangle {
                id: dotPoint
                property real exactX: chartArea.getX(index)
                property real exactY: chartArea.getY(root.values[index])

                x: exactX - width / 2
                y: exactY - height / 2
                width: 10
                height: 10
                radius: 5
                color: Theme.bgMain || "#FFFFFF"
                border.width: 2
                border.color: root.lineColor

                // 如果圆点跑出当前视口，就把它隐藏
                visible: exactX >= 0 && exactX <= chartArea.width && exactY >= 0 && exactY <= chartArea.height

                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }

                ToolTip.visible: dotMouseArea.containsMouse
                ToolTip.text: root.values[index].toString()
                ToolTip.delay: 100

                MouseArea {
                    id: dotMouseArea
                    anchors.fill: parent
                    anchors.margins: -10
                    hoverEnabled: true

                    // 🌟【关键修正】：设置 accepted = false，让鼠标按下的事件穿透到下层的图表区域，这样即使用户在圆点上按下鼠标也能开始画框！
                    onPressed: (mouse) => mouse.accepted = false

                    onEntered: parent.scale = 1.5
                    onExited: parent.scale = 1.0
                }
            }
        }
    }
}
