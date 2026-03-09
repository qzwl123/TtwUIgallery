#ifndef GRPCCLIENT_H
#define GRPCCLIENT_H

#include <QObject>
#include <QQmlEngine>


#include "stream.qpb.h"
#include "stream_client.grpc.qpb.h"

class GrpcClient : public QGrpcClientBase
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON
public:
    GrpcClient();

private:
    std::unique_ptr<QAbstractGrpcChannel> m_channel;
    routeguide::RouteGuideClient *m_client; // 命名规则：包名::服务名Client
};

#endif // GRPCCLIENT_H
