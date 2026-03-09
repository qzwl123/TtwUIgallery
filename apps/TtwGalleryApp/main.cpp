#include <QGuiApplication>
#include <QQmlApplicationEngine>


int main(int argc, char *argv[])
{
    // 🌟【核心修复】：允许 QML 的 XMLHttpRequest 读取本地/QRC文件
    // 这行代码必须放在 QGuiApplication 前面！
    // qputenv("QML_XHR_ALLOW_FILE_READ", "1");

    QGuiApplication app(argc, argv);

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
