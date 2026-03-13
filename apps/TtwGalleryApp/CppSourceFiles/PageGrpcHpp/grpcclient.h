#ifndef GRPCCLIENT_H
#define GRPCCLIENT_H

#include <QObject>
#include <QQmlEngine>
#include <QGrpcCallReply>
#include <QDebug>
#include <QJSEngine>


#include "stream.qpb.h"
#include "stream_client.grpc.qpb.h"

class GrpcClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    // Q_PROPERTY(QString responseText READ responseText NOTIFY responseTextChanged)
    // Q_PROPERTY(bool isLoading READ isLoading NOTIFY isLoadingChanged)

signals:
    // void responseTextChanged();
    // void isLoadingChanged();

public:
    explicit GrpcClient(std::shared_ptr<QAbstractGrpcChannel> channel);

    ///
    /// \brief handleReply 一元 RPC 调用返回
    /// \param reply 包含 gRPC 回复数据的智能指针。函数会接管该指针的所有权，在内部使用完毕后自动销毁。
    /// \param onSuccess 可选的完成回调函数。当回复成功且数据有效时调用，无参数无返回值。
    /// \param onFinished 流结束或出错时的可选回调函数（缺省为空）
    ///
    template<typename Reply>
    void handleReply(std::unique_ptr<QGrpcCallReply> reply,
                     std::function<void(const Reply&)> onSuccess,
                     std::function<void(const QGrpcStatus &)> onFinished = nullptr);

    ///
    /// \brief handleStreamReply 服务器流 RPC 调用返回
    /// \param stream 服务端流的智能指针，函数接管所有权
    /// \param onMessage 每次收到流数据时的回调函数
    /// \param onFinished 流结束或出错时的可选回调函数（缺省为空）
    ///
    template<typename Reply>
    void handleStreamReply(std::unique_ptr< QGrpcServerStream > stream,
                           std::function< void (const Reply &) > onMessage,
                           std::function< void (const QGrpcStatus &) > onFinished = nullptr);


    Q_INVOKABLE void fetchGreeting(const QString &name);
    // QString responseText() const { return m_responseText; }
    // bool isLoading() const { return m_isLoading; }
private:
/*    QString m_responseText;
    bool m_isLoading = false*/;

    // 必须管理 Reply 对象的生命周期，否则请求会被意外取消
    std::unique_ptr<QGrpcCallReply> m_currentReply;
    // 保存底层的 gRPC 客户端指针
    routeguide::RouteGuide::Client m_grpcClient; // 命名规则：包名::服务名::Client


public :
    // 提供一个全局访问点，方便我们在 main.cpp 中注入 gRPC client
    // static GrpcClient *instance();
};

#endif // GRPCCLIENT_H
