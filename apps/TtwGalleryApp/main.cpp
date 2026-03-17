#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include <QGrpcHttp2Channel>

#include "stream_client.grpc.qpb.h"

#include "Logs/logmanager.h"
#include "grpcclient.h"


int main(int argc, char *argv[])
{
    // 允许 QML 的 XMLHttpRequest 读取本地/QRC 文件。
    // 如果后面启用这行，必须放在 QGuiApplication 前面。
    // qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

    GrpcClient clientGuide(&app);
    clientGuide.setObjectName("clientGuide");
    // 将创建好的实例注册为 QML 单例。
    qmlRegisterSingletonInstance("MygRPC", 1, 0, "GrpcClient", &clientGuide);


    // ==========================================
    // 日志管理的 两种使用方法
    // ==========================================

    // 把 LogManager 注册给 QML
    qmlRegisterSingletonInstance("MygLog", 1, 0, "LogManager", &LogManager::instance());



    // 方式一 1.我想屏蔽整个类的打印（比如 GrpcClient
    // LogManager::instance().muteClass("grpcclient.cpp");
     LogManager::instance().muteObject("clientGuide");
  /*
    // 方式二 1. 实例化时，给它们起不同的名字 (Qt 的标准做法)
    GrpcClient* heartBeatClient = new GrpcClient(&app);
    heartBeatClient->setObjectName("HeartBeat_Channel");

    GrpcClient* dataClient = new GrpcClient(&app);
    dataClient->setObjectName("Data_Channel");

    // 方式二 2. 把心跳客户端拉黑
    LogManager::instance().muteObject("HeartBeat_Channel");

*/

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
