# 定义静态库 (推荐 Static，避免 DLL 地狱，且编译更快)
qt_add_library(TtwCore STATIC)

# --- gRPC/Protobuf 自动生成 ---
qt_add_protobuf(TtwCore
    PROTO_FILES "${CMAKE_SOURCE_DIR}/protos/stream.proto"
)

qt_add_grpc(TtwCore CLIENT
    PROTO_FILES "${CMAKE_SOURCE_DIR}/protos/stream.proto"
)

# --- 源码管理 ---
target_sources(TtwCore PRIVATE
    # src/network/TcpClient.cpp
    # src/network/UdpClient.cpp
    # src/serial/SerialManager.cpp
    # src/utils/Logger.cpp
)

# --- 依赖传递 ---
# 使用 PRIVATE：因为这些库的实现细节不需要暴露给 App (App 不需要知道你用了 SerialPort)
# 使用 PUBLIC (对于 Grpc)：因为生成的 gRPC 头文件可能会被 App 引用
target_link_libraries(TtwCore
    PRIVATE
        Qt6::Network
        Qt6::SerialPort
    PUBLIC
        Qt6::Grpc
        Qt6::Protobuf
)

# --- 头文件暴露 ---
# PUBLIC 意味着：任何链接了 TtwCore 的项目(如 GalleryApp)，
# 都会自动把 "${CMAKE_CURRENT_SOURCE_DIR}/include" 加入到它们的 Include Path。
# 这样 App 引用时只需写 #include <TtwCore/network/TcpClient.h>，非常干净。
target_include_directories(TtwCore PUBLIC
    "${CMAKE_CURRENT_SOURCE_DIR}"
    # "${CMAKE_CURRENT_SOURCE_DIR}/include"
)

