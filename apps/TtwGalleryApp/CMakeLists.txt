# 定义可执行文件
qt_add_executable(TtwGalleryApp
    src/main.cpp
)


# --- 链接即配置 ---
# 只需要链接 TtwCore 和 TtwUI。
# CMake 会自动处理：
# 1. 包含路径 (include path)
# 2. 库文件链接 (lib path)
# 3. 插件导入 (import path)
target_link_libraries(TtwGalleryApp PRIVATE
    Qt6::Quick
    # TtwCore    # 链接核心库
    TtwUI      # 链接 UI 库
    TtwUIplugin
)

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
