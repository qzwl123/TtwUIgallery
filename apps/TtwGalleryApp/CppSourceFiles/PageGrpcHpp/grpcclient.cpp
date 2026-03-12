#include "grpcclient.h"

GrpcClient::GrpcClient(std::shared_ptr<QAbstractGrpcChannel> channel) {
    m_grpcClient.attachChannel(std::move(channel));
}

// 必须在 .cpp 文件中实现这个静态方法
// GrpcClient* GrpcClient::instance() {
//     // 推荐使用 C++11 线程安全的局部静态变量 (Meyers Singleton)
//     static GrpcClient _instance;
//     return &_instance;
// }

template<typename Reply>
void GrpcClient::handleReply(std::unique_ptr<QGrpcCallReply> reply,
                             std::function<void(const Reply &)> onSuccess) {

    const auto *replyPtr = reply.get();
    QObject::connect(replyPtr, &QGrpcCallReply::finished, replyPtr,
                     [reply = std::move(reply), onSuccess](const QGrpcStatus &status)mutable{
        if(!status.isOk()) {
            qDebug() << "[ gRPC::handleReply ] error :" << status.message();
            return ;
        }

        auto respOpt = reply->read<Reply>();
        if(respOpt) {
            onSuccess(*respOpt);
        } else {
            qDebug() << "[ gRPC::handleReply ]returned : empty reply";
        }

    },
    // 6. 核心魔法：执行一次后自动销毁 Lambda 和内部的 unique_ptr！
    Qt::SingleShotConnection
    );
}

template<typename Reply>
void GrpcClient::handleStreamReply(std::unique_ptr<QGrpcServerStream> reply,
                       std::function<void(const Reply&)> onMessage,
                       std::function<void(const QGrpcStatus &)> onFinished) {

    QObject::connect(reply.get(), &QGrpcServerStream::messageReceived,
                     [s_reply = reply.get(), onMessage]() mutable{

        while(auto msg = s_reply->read<Reply>()) {
            onMessage(*msg);
        }

    });

    QObject::connect(reply.get(), &QGrpcServerStream::finished,
                     [reply = std::move(reply), onFinished](const QGrpcStatus &status){
        onFinished(status);
    });

}



void GrpcClient::fetchGreeting(const QString &name) {

    // if(!m_grpcClient) {
    //     qDebug() << "[ gRPC::fetchGreeting ] : m_grpcClient empty";
    //     return ;
    // }

    // m_isLoading = true;
    // emit isLoadingChanged();

    // 构造请求
    routeguide::Request req;
    req.setId_proto(1001);
    req.setData(name.toUtf8());
    // m_currentReply = m_grpcClient.sayHello(req);

    handleReply<routeguide::Response>(m_grpcClient.sayHello(req), [](const routeguide::Response &resp){
        qDebug() << "[gRPC::fetchGreeting] recv masg : " << resp.message();
    });



/*
    auto s_reply = m_grpcClient->ListFeatures(req);

    handleStreamReply<routeguide::Response>(
        std::move(s_reply),
        [](const routeguide::Response &resp){
            qDebug() << "Feature:" << resp.message();
        },
        [](const QGrpcStatus &status){
            if (!status.isOk())
                qDebug() << "Stream error:" << status.message();
            else
                qDebug() << "Stream finished successfully";
    });
*/
    return ;
}
