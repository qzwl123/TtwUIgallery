# TtwProject

## 项目简介

TtwProject 是一个基于 Qt 6、QML 和 CMake 的桌面示例工程，采用 `Core -> UI -> App` 的分层组织方式。当前仓库包含一个示例应用 `TtwGalleryApp`，用于演示以下能力：

- 自定义无边框窗口与导航容器
- 主题、图标、系统信息等 QML 单例
- 可复用的基础控件与日志面板
- 实时折线图组件与动态数据源
- Qt Protobuf / Qt gRPC 客户端接入方式

项目适合作为 Qt Quick 桌面应用脚手架、组件库雏形或 gRPC/QML 集成示例使用。

## 技术栈

- C++17
- CMake 3.21+
- Qt 6.5+
- Qt Quick / QML
- Qt Network / SerialPort
- Qt Protobuf / Qt gRPC
- Proto3

顶层 `CMakeLists.txt` 会在构建时自动读取 Git 信息，生成版本号和构建时间，并注入到 `SysInfo.qml` 中供界面层使用。

## 主要功能

### 1. Ttw.UI 组件模块

`libs/Ttw/UI` 提供了一组可复用的 QML 组件与单例，包括：

- `Theme.qml`：主题、颜色、字体、暗色模式切换
- `Icons.qml`：图标映射
- `SysInfo.qml.in`：构建信息模板
- `TtwWindow.qml`：自定义窗口壳
- `TtwNavigationView.qml`：侧边导航容器
- `Button.qml`、`TextField.qml`、`GroupBox.qml` 等基础控件
- `DebugConsole.qml`：日志面板
- `FoldingLineChart.qml`：折线图控件

### 2. Ttw.Core 核心模块

`libs/Ttw/Core` 提供底层通用能力：

- `Logs/logmanager.h`：统一日志分发与静音控制
- `gRPCTools/grpctool.h`：gRPC Channel 注册与 Reply/Stream 处理辅助
- `json.hpp`：JSON 相关基础支持

### 3. TtwGalleryApp 示例应用

`apps/TtwGalleryApp` 是当前主应用，包含 4 个演示页面：

- `Home`：基础控件、日志联动、主题切换
- `Charts`：动态图表展示
- `gRPC`：gRPC 页面布局与调用示例
- `Icons`：图标浏览与复制

## 目录结构

```text
TtwProject/
├─ apps/
│  └─ TtwGalleryApp/              # 示例应用
├─ libs/
│  └─ Ttw/
│     ├─ Core/                    # 核心能力：日志、gRPC 工具等
│     └─ UI/                      # QML 组件与主题系统
├─ protos/
│  └─ stream.proto                # gRPC / Protobuf 协议定义
├─ cmake/
│  └─ StandardProjectSettings.cmake
├─ build/                         # 本地构建目录（已忽略）
└─ CMakeLists.txt                 # 顶层工程入口
```

## 环境要求

建议在 Windows 环境下使用 Qt Creator 或 CMake 命令行构建。

必需依赖：

- Qt 6.5 或更高版本
- Qt 组件：`Core`、`Quick`、`Qml`、`Network`、`SerialPort`、`Protobuf`、`Grpc`
- CMake 3.21 或更高版本
- 支持 C++17 的编译器

可选依赖：

- Git：用于生成更友好的版本号信息
- Ninja：推荐的构建后端

本地示例环境：

- Qt `6.8.3`
- MinGW `64-bit`
- CMake + Ninja

## 快速开始

### 方式一：使用 Qt Creator

1. 用 Qt Creator 打开仓库根目录下的 `CMakeLists.txt`
2. 选择一个包含 Qt gRPC / Protobuf 组件的 Qt 6 Kit
3. 完成 Configure
4. 直接运行目标 `TtwGalleryApp`

### 方式二：使用命令行

如果系统中 `cmake` 未加入 `PATH`，请替换为 Qt 安装目录中的完整路径。

```powershell
cmake -S . -B build/desktop-mingw-debug -G Ninja -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=E:/Qt/6.8.3/mingw_64
cmake --build build/desktop-mingw-debug --target TtwGalleryApp
.\build\desktop-mingw-debug\TtwGalleryApp.exe
```

说明：

- `CMAKE_PREFIX_PATH` 需要指向你本机 Qt 安装目录
- 如果使用 MSVC Kit，请切换到对应的 Qt 安装路径
- Release 构建可将 `Debug` 改为 `Release`

## gRPC / Protobuf 说明

仓库中已经包含：

- 协议文件：`protos/stream.proto`
- Qt 生成代码接入：`qt_add_protobuf(...)`、`qt_add_grpc(...)`
- 客户端封装：`apps/TtwGalleryApp/CppSourceFiles/PageGrpcHpp/grpcclient.*`
- 通道工具：`libs/Ttw/Core/gRPCTools/grpctool.*`

当前默认的客户端目标地址为：

```text
http://127.0.0.1:5200
```

注意事项：

- 本仓库提供的是客户端示例与协议定义
- gRPC 服务端不在当前仓库中，需要自行准备并启动
- `stream.proto` 中定义了 Unary、服务端流、客户端流和双向流 4 类 RPC

## 版本与构建信息

项目在配置阶段会执行以下逻辑：

- 使用 `git describe --tags --always --dirty` 生成版本字符串
- 使用 `string(TIMESTAMP ...)` 生成构建时间
- 通过 `configure_file(...)` 输出 `SysInfo.qml`

当 Git 信息不可用时，会回退到：

```text
0.1.0-unknown
```

## 二次开发建议

### 新增页面

1. 在 `apps/TtwGalleryApp/src/pages/` 下新增页面 QML 文件
2. 在 `apps/TtwGalleryApp/CMakeLists.txt` 的 `qt_add_qml_module(...)` 中注册
3. 在 `apps/TtwGalleryApp/Main.qml` 的导航模型中加入入口

### 新增 UI 组件

1. 在 `libs/Ttw/UI/controls/` 下创建组件
2. 在 `libs/Ttw/UI/CMakeLists.txt` 中加入到 `qt_add_qml_module(...)`
3. 在应用层通过 `import Ttw.UI` 使用

### 新增 gRPC 协议

1. 修改 `protos/stream.proto`
2. 重新执行 CMake Configure / Build
3. 在 App 或 Core 中接入新生成的 `.qpb.h` / `.grpc.qpb.h`

## 当前状态

- 已具备基础桌面壳、导航与主题体系
- 已具备 QML 组件化组织方式
- 已接入 Qt Protobuf / Qt gRPC 的客户端生成流程
- 当前仓库未包含自动化测试与独立服务端实现

## 许可证

当前仓库未附带 `LICENSE` 文件。如需开源或对外分发，建议补充明确的许可证声明。
