#include "grpcclient.h"

GrpcClient::GrpcClient(std::shared_ptr<QAbstractGrpcChannel> channel) {
    m_grpcClient.attachChannel(std::move(channel));
}

template<typename Reply>
void GrpcClient::handleReply(std::unique_ptr<QGrpcCallReply> reply,
                             std::function<void(const Reply &)> onMessage,
                             std::function<void(const QGrpcStatus &)> onFinished) {

    const auto *replyPtr = reply.get();
    QObject::connect(replyPtr, &QGrpcCallReply::finished, replyPtr,
                    [reply = std::move(reply), onMessage, onFinished](const QGrpcStatus &status) {

        if(onFinished) {
            onFinished(status);
        } else {
            if (status.isOk())
                qDebug("Client (handleReply) finished");
            else
                qDebug() << "[ gRPC::handleReply ] error :" << status.message();
                // qDebug() << "Client (ServerStreaming) failed:" << status;
        }

        if( auto response = reply->read<Reply>()) {
            onMessage(*response);
        } else {
            qDebug() << "[ gRPC::handleReply ]returned : empty reply";
        }

    },
    // 执行一次后自动销毁 Lambda 和内部的 unique_ptr！
    Qt::SingleShotConnection);
}

template<typename Reply>
void GrpcClient::handleStreamReply(std::unique_ptr<QGrpcServerStream> stream,
                       std::function<void(const Reply&)> onMessage,
                       std::function<void(const QGrpcStatus &)> onFinished) {


    const auto *streamPtr = stream.get();

    QObject::connect(streamPtr, &QGrpcServerStream::finished, streamPtr,
                    [stream = std::move(stream), onFinished](const QGrpcStatus &status){

        if(onFinished) {
            onFinished(status);
        } else {
            if (status.isOk())
                qDebug("Client (ServerStreaming) finished");
            else
                qDebug() << "Client (ServerStreaming) failed:" << status;
        }
    },
    Qt::SingleShotConnection);


    QObject::connect(streamPtr, &QGrpcServerStream::messageReceived,
                     streamPtr, [streamPtr, onMessage]() {

        if (const auto response = streamPtr->read<Reply>()) {
            onMessage(*response); // Client (ServerStream) received
        }
        else {
            qDebug("Client (ServerStream) deserialization failed");
        }
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
    handleStreamReply<routeguide::Response>(
        m_grpcClient.ListFeatures(req),

        [](const routeguide::Response &resp){
            qDebug() << "Stream : " << resp.message();
        }

        // ,[](const QGrpcStatus &status){
        //     if (!status.isOk())
        //         qDebug() << "Stream error:" << status.message();
        //     else
        //         qDebug() << "Stream finished successfully";
        // }
      );
*/
    return ;
}
