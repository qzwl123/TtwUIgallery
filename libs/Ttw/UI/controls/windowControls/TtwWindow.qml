// libs/Ttw/UI/controls/TtwWindow.qml
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import QtQuick.Effects
import Ttw.UI

Window {
    id: window

    // ==========================================
    // 1. 公开 API 与核心配置
    // ==========================================
    // 【核心魔法】将外部写入的内容，精准重定向到 layout_content 容器中
    default property alias contentData: layout_content.data

    property string titleText: "Ttw (" + SysInfo.buildTime + " / " + SysInfo.appVersion + ")"

    property color backgroundColor: Theme.bgMain

    // 窗口控制
    property bool fixSize: false
    property bool useSystemAppBar: false

    // 动态挂载标题栏，允许业务层覆盖或隐藏
    property Item appBar: TtwTitleBar {
        title: window.titleText
        targetWindow: window
    }

    // ==========================================
    // 2. 窗口基础状态与跨平台透明处理
    // ==========================================
    width: 1024
    height: 768
    color: "transparent" // 必须全透明，为阴影和圆角让路
    flags: Qt.Window | Qt.FramelessWindowHint

    property int shadowMargin: visibility === Window.Maximized ? 0 : 100
    property int windowRadius: visibility === Window.Maximized ? 0 : Theme.radiusBase * 2


    Component.onCompleted: {
        // 固定尺寸逻辑
        if (fixSize) {
            window.minimumWidth = window.width
            window.maximumWidth = window.width
            window.minimumHeight = window.height
            window.maximumHeight = window.height
        }
    }

    // ==========================================
    // 3. 布局与渲染层 (Z-Order 从下往上)
    // ==========================================
    Item {
        id: layout_container
        anchors.fill: parent
        // anchors.margins: window.shadowMargin

        // -----------------------
        // Layer 0: 阴影底层
        // -----------------------
        Rectangle {
            id: bgRect
            anchors.fill: parent
            radius: window.windowRadius
            color: window.backgroundColor

            // 【核心修复魔法】
            // 启用 layer 并将 MultiEffect 挂载为图层特效。
            // 引擎会自动向外扩充边界来容纳阴影，绝对不会被裁剪！
            // 并且完美捕捉当前 Rectangle 的圆角 (radius) 和背景透明度。
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: window.visibility !== Window.Maximized
                shadowColor: Theme.mode === Theme.Mode.Light ? "#15000000" : "#33000000"
                shadowBlur: 1.0
                shadowVerticalOffset: 3
                shadowHorizontalOffset: 0
            }
        }

        // -----------------------
        // Layer 1: 真实背景层
        // -----------------------
        Rectangle {
            id: real_bg
            anchors.fill: parent
            radius: window.windowRadius
            color: "transparent"
            clip: true // 裁剪溢出的内容

            // -----------------------
            // Layer 2: 标题栏 (AppBar)
            // -----------------------
            Item {
                id: loader_app_bar
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                // 读取 implicitHeight 防止初始化高度塌陷
                height: window.useSystemAppBar ? 0 : (window.appBar ? window.appBar.implicitHeight : 32)

                // 挂载组件
                children: window.useSystemAppBar || !window.appBar ? [] : [window.appBar]

                // 【核心终极修复】：使用声明式的 Binding 对象！
                // 它的优先级极高，只要窗口在存活，它就会死死把 appBar 的宽度和容器宽度锁在一起，绝不断裂。
                Binding {
                    target: window.appBar
                    property: "width"
                    value: loader_app_bar.width
                    when: window.appBar !== null
                }
            }

            // -----------------------
            // Layer 3: 业务内容区 (Content)
            // -----------------------
            Item {
                id: layout_content
                anchors {
                    top: loader_app_bar.bottom
                    left: parent.left
                    right: parent.right
                    bottom: parent.bottom
                }
                // 留出 1px 防止内容遮盖边缘的 1px Border
                anchors.margins: window.visibility === Window.Maximized ? 0 : 1
                anchors.topMargin: 0
                clip: true
            }
        } // end of real_bg

        // -----------------------
        // Layer 4: 全局 Loading 遮罩预留区 (仿照你的参考代码)
        // -----------------------
        Rectangle {
            id: global_loading_overlay
            anchors.fill: parent
            color: "#44000000"
            radius: window.windowRadius
            visible: false // 预留接口，外部可通过函数控制显示
            z: 98

            // 拦截底下所有的鼠标事件
            MouseArea { anchors.fill: parent }
        }

        // -----------------------
        // Layer 5: 顶层边框 Overlay
        // -----------------------
        Rectangle {
            id: border_overlay
            anchors.fill: parent
            radius: window.windowRadius
            color: "transparent"
            border.width: window.visibility === Window.Maximized ? 0 : 1
            // 窗口失焦时，边框颜色变淡，还原 WinUI 3 交互
            border.color: window.active ? Theme.borderHover : Theme.borderRest
            z: 99
        }
    }

    // ==========================================
    // 4. 边缘拖拽控制 (跨平台 8 向 Resizing)
    // ==========================================
    MouseArea { height: 6; anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
        cursorShape: Qt.SizeVerCursor; onPressed: window.startSystemResize(Qt.TopEdge) }
    MouseArea { height: 6; anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: 6 }
        cursorShape: Qt.SizeVerCursor; onPressed: window.startSystemResize(Qt.BottomEdge) }
    MouseArea { width: 6; anchors { left: parent.left; top: parent.top; bottom: parent.bottom; margins: 6 }
        cursorShape: Qt.SizeHorCursor; onPressed: window.startSystemResize(Qt.LeftEdge) }
    MouseArea { width: 6; anchors { right: parent.right; top: parent.top; bottom: parent.bottom; margins: 6 }
        cursorShape: Qt.SizeHorCursor; onPressed: window.startSystemResize(Qt.RightEdge) }

    MouseArea { width: 12; height: 12; anchors { left: parent.left; top: parent.top }
        cursorShape: Qt.SizeFDiagCursor; onPressed: window.startSystemResize(Qt.TopEdge | Qt.LeftEdge) }
    MouseArea { width: 12; height: 12; anchors { right: parent.right; top: parent.top }
        cursorShape: Qt.SizeBDiagCursor; onPressed: window.startSystemResize(Qt.TopEdge | Qt.RightEdge) }
    MouseArea { width: 12; height: 12; anchors { left: parent.left; bottom: parent.bottom }
        cursorShape: Qt.SizeBDiagCursor; onPressed: window.startSystemResize(Qt.BottomEdge | Qt.LeftEdge) }
    MouseArea { width: 12; height: 12; anchors { right: parent.right; bottom: parent.bottom }
        cursorShape: Qt.SizeFDiagCursor; onPressed: window.startSystemResize(Qt.BottomEdge | Qt.RightEdge) }

    // ==========================================
    // 5. 辅助函数 (API)
    // ==========================================
    function showLoading() { global_loading_overlay.visible = true }
    function hideLoading() { global_loading_overlay.visible = false }
}
