#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QGrpcHttp2Channel>
#include "stream_client.grpc.qpb.h"
#include "grpcclient.h"

int main(int argc, char *argv[])
{
    // 🌟【核心修复】：允许 QML 的 XMLHttpRequest 读取本地/QRC文件
    // 这行代码必须放在 QGuiApplication 前面！
    // qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

    auto channel = std::make_shared<QGrpcHttp2Channel>(
        QUrl("http://127.0.0.1:5200")
        );

    GrpcClient clientGuide(channel);
    clientGuide.fetchGreeting("tsstw");


    // 2. 将你创建的实例注册为 QML 单例 (URI, 主版本号, 次版本号, QML中的名字, 实例指针)
    qmlRegisterSingletonInstance("MygRPC", 1, 0, "GrpcClient", &clientGuide);

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("TtwGalleryApp", "Main");

    return app.exec();
}
