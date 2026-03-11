#include "grpcclient.h"

GrpcClient::GrpcClient(QObject *parent) : QObject(parent) {}


void GrpcClient::setGrpcClient(routeguide::RouteGuide::Client *client) {
    m_grpcClient = client;
    return ;
}

template<typename Reply>
void GrpcClient::handleReply(std::unique_ptr<QGrpcCallReply> reply,
                             std::function<void(const Reply &)> onSuccess) {

    QObject::connect(reply.get(), &QGrpcCallReply::finished,
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

    });
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
    if(!m_grpcClient) return ;

    m_isLoading = true;
    emit isLoadingChanged();

    // 构造请求
    routeguide::Request req;
    req.setId_proto(1001);
    req.setData(name.toUtf8());

    handleReply<routeguide::Response>(m_grpcClient->sayHello(req), [](const routeguide::Response &resp){
        qDebug() << resp.message();
    });




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

    return ;
}
