# 定义库
qt_add_library(TtwUI STATIC)

# 定义单例文件列表
set(MY_QML_SINGLETONS
    "Theme.qml"
    "Icons.qml"
)

# 统一设置属性
set_source_files_properties(${MY_QML_SINGLETONS}
    PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)


# --- 现代 QML 模块定义 ---
# qt_add_qml_module 是 Qt6 的核心。
# 它自动处理 qmldir 生成、资源编译(qrc)和类型注册。
qt_add_qml_module(TtwUI
    URI "Ttw.UI"             # [重要] 决定了 QML 中的 import 语句: import Ttw.UI
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"

    QML_FILES
        controls/Button.qml
        controls/TextBox.qml
        Theme.qml
        Icons.qml

    RESOURCES
        fonts/FluentIcons.ttf
        QML_FILES controls/TtwWindow.qml
        QML_FILES controls/TtwTitleBar.qml # 将字体打包进库，App 无需关心资源路径
)

# 如果 UI 库包含 C++ 自定义绘制 (impl 目录)
target_sources(TtwUI PRIVATE
    # impl/CustomItem.cpp
)

set_target_properties(TtwUI PROPERTIES
    QT_QML_MODULE_TARGET_PATH Ttw/UI
)


# 链接 Qt Quick
target_link_libraries(TtwUI
    PUBLIC
        Qt6::Quick
        Qt6::Qml
)
