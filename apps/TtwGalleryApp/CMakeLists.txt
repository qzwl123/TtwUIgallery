# 定义可执行文件
qt_add_executable(TtwGalleryApp
    src/main.cpp
)

# --- App 也是一个模块 ---
# 将 App 自身也定义为 QML 模块，这样 main.cpp 加载 Main.qml 时，
# 可以直接用 module 路径，而不需要复杂的相对路径或 qrc:/...
qt_add_qml_module(TtwGalleryApp
    URI "TtwGalleryApp"
    VERSION 1.0
    RESOURCE_PREFIX "/qt/qml"
    QML_FILES
        src/Main.qml
        # 如果有页面文件夹，全部列在这里
        src/pages/PageHome.qml
        src/pages/PageIcons.qml

)

# --- 链接即配置 ---
# 只需要链接 TtwCore 和 TtwUI。
# CMake 会自动处理：
# 1. 包含路径 (include path)
# 2. 库文件链接 (lib path)
# 3. 插件导入 (import path)


# # --- 部署配置 ---
# # 设置 Windows 这是一个 GUI 程序而不是控制台程序
# set_target_properties(TtwGalleryApp PROPERTIES
#     WIN32_EXECUTABLE TRUE
#     MACOSX_BUNDLE TRUE
# )

# # 安装规则 (用于 make install)
# install(TARGETS TtwGalleryApp
#     BUNDLE DESTINATION .
#     RUNTIME DESTINATION bin
# )
