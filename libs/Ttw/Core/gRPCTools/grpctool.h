#ifndef GRPCTOOL_H
#define GRPCTOOL_H

#include <QAbstractGrpcChannel>
#include <QDebug>
#include <QGrpcCallReply>
#include <QGrpcServerStream>
#include <QGrpcStatus>
#include <QHash>
#include <QObject>
#include <QReadWriteLock>
#include <QString>

#include <functional>
#include <memory>
#include <utility>

class GrpcTool
{
public:
    GrpcTool() = delete;

    // ==========================================
    // 多通道管理器 (Channel Pool / Registry)
    // ==========================================

    /// 初始化并注册一个命名通道。
    /// channelName 例如 "testServer"
    /// address 例如 "http://127.0.0.1:5200"
    static bool initChannel(const QString &channelName, const QString &address);

    /// 注册外部创建好的通道实例；若名称已存在则覆盖旧通道。
    static bool registerChannel(const QString &channelName,
                                std::shared_ptr<QAbstractGrpcChannel> channel);

    /// 按名称获取通道；若不存在则返回 nullptr。
    static std::shared_ptr<QAbstractGrpcChannel> getChannel(const QString &channelName);

    /// 查询指定名称的通道是否已注册。
    static bool containsChannel(const QString &channelName);

    /// 移除指定通道；若不存在则返回 false。
    static bool removeChannel(const QString &channelName);

    // ==========================================
    // 处理一元调用 (Unary Call)
    // ==========================================

    /// 统一处理一元 RPC 返回。
    /// reply 的生命周期由工具函数托管，完成后自动释放。
    template<typename Reply>
    static void handleReply(std::unique_ptr<QGrpcCallReply> reply,
                            std::function<void(const Reply &)> onMessage,
                            std::function<void(const QGrpcStatus &)> onFinished = nullptr)
    {
        if (!reply) {
            const QGrpcStatus status(QtGrpc::StatusCode::Unknown,
                                     QStringLiteral("Reply handle is null."));
            qWarning() << "[GrpcTool::handleReply]" << status.message();
            if (onFinished)
                onFinished(status);
            return;
        }

        auto *replyPtr = reply.get();
        QObject::connect(replyPtr, &QGrpcCallReply::finished, replyPtr,
                         [reply = std::move(reply), onMessage = std::move(onMessage),
                          onFinished = std::move(onFinished)](const QGrpcStatus &status) mutable {

            if (!status.isOk()) {               
                qWarning() << "[GrpcTool::handleReply] RPC failed:"
                           << status.code() << status.message();
            } else if (onMessage) {     
                if (const auto response = reply->read<Reply>()) {
                    onMessage(*response);
                } else {
                    qWarning() << "[GrpcTool::handleReply] Reply deserialization failed.";
                }
            }

            if (onFinished) {
                onFinished(status);
            }
        }, Qt::SingleShotConnection);
    }

    // ==========================================
    // 处理服务端流调用 (Server Streaming)
    // ==========================================

    /// 统一处理服务端流 RPC。
    /// 每次收到消息时触发 onMessage，结束或出错时触发 onFinished。
    template<typename Reply>
    static void handleStreamReply(std::unique_ptr<QGrpcServerStream> stream,
                                  std::function<void(const Reply &)> onMessage,
                                  std::function<void(const QGrpcStatus &)> onFinished = nullptr)
    {
        if (!stream) {
            const QGrpcStatus status(QtGrpc::StatusCode::Unknown,
                                     QStringLiteral("Server stream handle is null."));
            qWarning() << "[GrpcTool::handleStreamReply]" << status.message();
            if (onFinished)
                onFinished(status);
            return;
        }

        auto *streamPtr = stream.get();

        QObject::connect(streamPtr, &QGrpcServerStream::messageReceived, streamPtr,
                         [streamPtr, onMessage = std::move(onMessage)]() mutable {
            if (!onMessage)
                return;

            if (const auto response = streamPtr->read<Reply>()) {
                onMessage(*response);
            } else {
                qWarning() << "[GrpcTool::handleStreamReply] Stream deserialization failed.";
            }
        });

        QObject::connect(streamPtr, &QGrpcServerStream::finished, streamPtr,
                         [stream = std::move(stream),
                          onFinished = std::move(onFinished)](const QGrpcStatus &status) mutable {
            if (!status.isOk()) {
                qWarning() << "[GrpcTool::handleStreamReply] Stream finished with error:"
                           << status.code() << status.message();
            }

            if (onFinished)
                onFinished(status);
        }, Qt::SingleShotConnection);
    }

private:
    static bool isValidChannelName(const QString &channelName);

    // 使用读写锁保护全局通道注册表，便于在不同业务模块共享连接。
    inline static QHash<QString, std::shared_ptr<QAbstractGrpcChannel>> channelRegistry;
    inline static QReadWriteLock channelRegistryLock{QReadWriteLock::NonRecursive};
};

#endif // GRPCTOOL_H
