#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QGrpcHttp2Channel>
#include "stream_client.grpc.qpb.h"
#include "grpcclient.h"

int main(int argc, char *argv[])
{
    // 允许 QML 的 XMLHttpRequest 读取本地/QRC 文件。
    // 如果后面启用这行，必须放在 QGuiApplication 前面。
    // qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

    GrpcClient clientGuide(&app);
    // 将创建好的实例注册为 QML 单例。
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
