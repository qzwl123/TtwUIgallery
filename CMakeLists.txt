cmake_minimum_required(VERSION 3.21)

# ---------- 关联 Git 自动生成版本号 Begin ----------

# 尝试从 Git 获取标签名
execute_process(
    COMMAND git describe --tags --always --dirty
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE GIT_VERSION  # 获取结果存入 GIT_VERSION
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)

# 定义项目 (VERSION 建议保留一个基本格式)
project(TtwProject
    VERSION 0.1.0
    LANGUAGES CXX
)

# 逻辑判断：如果 Git 执行成功，则使用 Git 版本，否则用保底版本
if(GIT_VERSION)
    set(APP_VERSION ${GIT_VERSION})
else()
    set(APP_VERSION "0.1.0-unknown")
endif()

# 同步给 CMake 内置变量（可选，用于 install 等指令）
set(PROJECT_VERSION ${APP_VERSION})

# 获取当前 CMake 编译配置的时间 (格式: YYYY-MM-DD HH:MM:SS)
string(TIMESTAMP BUILD_TIME "%Y-%m-%d %H:%M:%S")

message(STATUS ">>> 当前编译时间: ${BUILD_TIME}")
message(STATUS ">>> 当前构建版本: ${APP_VERSION}")

# 传递给 C++ 代码使用 (注意：为了让 C++ 识别为字符串，必须加转义的双引号 \")
# add_definitions(-DAPP_VERSION="${APP_VERSION}")
# add_definitions(-DAPP_VERSION="${APP_VERSION}")
# add_definitions(-DBUILD_TIME="${BUILD_TIME}")

# (可选) 设置为缓存变量，以防子模块作用域读不到
set(APP_VERSION ${APP_VERSION} CACHE INTERNAL "Application Git Version")
set(BUILD_TIME ${BUILD_TIME} CACHE INTERNAL "Application Build Time")

# git tag -a v0.1.1 -m "第一个版本"

# ---------- 关联 Git 自动生成版本号 End ----------

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 开启 Qt 自动化 (MOC/RCC)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# 查找所有子模块共用的 Qt 组件
find_package(Qt6 6.5 REQUIRED COMPONENTS Core Quick Network SerialPort Protobuf Grpc Qml)




# 自动加载，定义好 bin、lib 等路径。 必须在 find_package 下面
qt_standard_project_setup()

# 不产生输出文件的“虚拟”任务 告诉 IDE（如 Qt Creator 或 VSCode）把这些文件列在项目树里。
add_custom_target(ToolFiles
    SOURCES
        protos/stream.proto
        cmake/StandardProjectSettings.cmake
)

set(QT_QML_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/qml" CACHE PATH "QML output dir" FORCE)
set(QML_IMPORT_PATH "${QT_QML_OUTPUT_DIRECTORY}" CACHE STRING "QML Import Paths for IDEs" FORCE)

# 按依赖顺序添加子目录
add_subdirectory(libs/Ttw/Core)      # 底层核心
add_subdirectory(libs/Ttw/UI)        # UI 组件库
add_subdirectory(apps/TtwGalleryApp)# 上层应用
