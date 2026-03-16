#ifndef GRPCCLIENT_H
#define GRPCCLIENT_H

#include <QObject>
#include <QQmlEngine>
#include <QGrpcCallReply>
#include <QDebug>
#include <QJSEngine>
#include <QString>

#include "gRPCTools/grpctool.h"

#include "stream.qpb.h"
#include "stream_client.grpc.qpb.h"

/*

Q_PROPERTY(
    type name                  // [必填] 属性的数据类型和名称 (例如: QString title, int speed)

    // ================== 核心读写控制 (以下两种方式二选一) ==================
    // 方式 1: 传统 READ/WRITE
    (READ getFunction          // [通常必填] 指定用于读取该属性的 C++ 成员函数 (通常声明为 const)
     [WRITE setFunction]       // [可选] 指定用于设置该属性的 C++ 成员函数。如果不写，则该属性在 QML 中是只读的
    |
    // 方式 2: MEMBER 简写语法 (极力推荐用于简单属性)
     MEMBER memberName         // [简写神器] 直接绑定 C++ 的成员变量 (例如: m_title)，Qt 会在底层自动帮你搞定读写
     [(READ getFunction | WRITE setFunction)]) // [可选] 即使使用了 MEMBER，也可按需覆盖特定的 READ 或 WRITE 逻辑

    // ================== 信号与重置 (QML 交互核心) ==================
    [NOTIFY notifySignal]      // [极度重要] 当属性值改变时发出的信号。没有它，C++ 数据的变化就无法触发 QML 界面的自动刷新！
    [RESET resetFunction]      // [可选] 提供一个函数，将属性恢复到默认/初始状态 (在 QML 中给属性赋 undefined 时会触发)

    // ================== 状态约束与性能优化 ==================
    [CONSTANT]                 // [可选] 声明此属性在对象初始化后【永远不会改变】。加上它可以让 QML 引擎进行极致优化。(注意：不能与 WRITE 和 NOTIFY 同时使用)
    [REQUIRED]                 // [可选] (Qt 5.15+引入) 强制要求在创建该对象时【必须赋值】，否则在运行时报错。适合用于必须传入的初始化参数。
    [FINAL]                    // [可选] 声明该属性不能被子类重写 (类似于 C++ 的 final 关键字)。

    // ================== 环境与可见性控制 (一般不需要改) ==================
    [REVISION int]             // [可选] 版本控制。配合 qmlRegisterRevision 使用，让该属性只在 QML 导入特定版本时 (如 import MyModule 1.1) 才可见。
    [DESIGNABLE bool]          // [可选] 默认 true。决定该属性是否在 Qt Designer 等 UI 设计器的属性面板中显示。
    [SCRIPTABLE bool]          // [可选] 默认 true。决定该属性是否能被脚本引擎 (如 QML) 访问。设为 false 则 QML 完全看不见它。
    [STORED bool]              // [可选] 默认 true。决定在使用 QDataStream 序列化或保存对象状态时，是否保存该属性。
    [USER bool]                // [可选] 默认 false。标明该属性是否为该类的“默认面向用户属性” (一个类通常只设一个，比如 CheckBox 的 checked 属性)。
)

*/


class GrpcClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // ==========================================
    // gRPC 客户端视图模型属性 (ViewModel Properties)
    // 用于将底层的网络状态与 QML 前端 UI 进行数据绑定
    // ==========================================

    /**
     * @brief 通道就绪状态
     * 标识底层的 gRPC Channel 是否已经成功初始化并挂载。
     * QML 绑定建议：可用于控制 StatusBadge 显示 "ready" 或 "offline" tone。
     */
    Q_PROPERTY(bool channelReady READ channelReady NOTIFY channelReadyChanged)

    /**
     * @brief 忙碌/加载状态
     * 标识当前是否正在进行 gRPC 网络请求（请求已发出但尚未收到响应）。
     * QML 绑定建议：可用于控制界面的 Loading 动画、禁用发送按钮，或将 StatusBadge 设为 "busy"。
     */
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)

    /**
     * @brief 目标服务器地址
     * 记录当前客户端连接的 gRPC 服务端点 (例如: "http://127.0.0.1:5200")。
     */
    Q_PROPERTY(QString endpoint READ endpoint CONSTANT)

    /**
     * @brief 最新接收到的业务消息
     * 用于存储上一次成功 RPC 调用后，从 Protobuf 响应体中提取的核心业务数据。
     * QML 绑定建议：直接绑定到界面上的 Text 控件用于展示服务端返回的结果。
     */
    Q_PROPERTY(QString lastMessage READ lastMessage NOTIFY lastMessageChanged)

    /**
     * @brief 最新网络状态描述
     * 用于存储 gRPC 调用的状态信息 (例如 "OK", "Permission Denied", "Unavailable" 等)。
     * QML 绑定建议：常用于错误提示弹窗 (Toast) 或状态栏文本显示。
     */
    Q_PROPERTY(QString lastStatusText READ lastStatusText NOTIFY lastStatusTextChanged)

    /**
     * @brief 最新网络状态码
     * 记录底层的 gRPC 状态码 (通常 0 代表 OK，非 0 代表各种具体错误)。
     * 架构亮点：它与 lastStatusText 共享了同一个信号 `lastStatusTextChanged`。
     * 这是非常高级且推荐的 Qt 做法：当状态码和状态文本总是同时更新时，
     * 共用一个信号可以减少事件循环中的信号泛滥 (Signal Flooding)，提升性能。
     */
    Q_PROPERTY(int lastStatusCode READ lastStatusCode NOTIFY lastStatusTextChanged)

public:
    explicit GrpcClient(QObject *parent = nullptr);

    Q_INVOKABLE void onsayHello(const int &id, const QString &dat);
    Q_INVOKABLE void clearState();

    bool channelReady() const;
    bool busy() const;
    QString endpoint() const;
    QString lastMessage() const;
    QString lastStatusText() const;
    int lastStatusCode() const;

signals:
    void channelReadyChanged();
    void busyChanged();
    void lastMessageChanged();
    void lastStatusTextChanged();

private:
    void setChannelReady(bool ready);
    void setBusy(bool busy);
    void setLastMessage(const QString &message);
    void setLastStatus(const QString &text, int code);

    routeguide::RouteGuide::Client m_grpcClient;
    QString m_endpoint = QStringLiteral("http://127.0.0.1:5200");
    bool m_channelReady = false;
    bool m_busy = false;
    QString m_lastMessage;
    QString m_lastStatusText = QStringLiteral("Ready");
    int m_lastStatusCode = 0;
};

#endif // GRPCCLIENT_H
