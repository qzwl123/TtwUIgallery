# 解析 .in 模板，生成真实的 .qml 文件到 build 目录中
# 因为外层 CMake 已经设置了 APP_VERSION 和 BUILD_TIME，这里的 @APP_VERSION@ 会被成功替换！
configure_file(
    "${CMAKE_CURRENT_SOURCE_DIR}/SysInfo.qml.in"
    "${CMAKE_CURRENT_BINARY_DIR}/SysInfo.qml"
    @ONLY
)

# =================================================================
# 【核心修复代码】：必须放在 qt_add_qml_module 之前！
# 告诉 Qt 的资源系统 (qrc)：把这个 build 目录下的绝对路径文件，
# 在内存虚拟文件系统中重命名为 "SysInfo.qml"
# =================================================================
set_source_files_properties("${CMAKE_CURRENT_BINARY_DIR}/SysInfo.qml"
    PROPERTIES QT_RESOURCE_ALIAS "SysInfo.qml"
)

# 定义库
qt_add_library(TtwUI STATIC)

# 定义单例文件列表
set(MY_QML_SINGLETONS
    "Theme.qml"
    "Icons.qml"
    "SysInfo.qml"
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
        Theme.qml
        Icons.qml
        # 在 build 目录生成的 SysInfo.qml 加进模块
        "${CMAKE_CURRENT_BINARY_DIR}/SysInfo.qml"
    QML_FILES
        controls/Button.qml
        controls/TextBox.qml
        controls/TtwTitleBar.qml
        controls/TtwWindow.qml
    RESOURCES
        # 将字体打包进库，App 无需关心资源路径
        fonts/FluentIcons.ttf
    RESOURCES
        SysInfo.qml.in
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
