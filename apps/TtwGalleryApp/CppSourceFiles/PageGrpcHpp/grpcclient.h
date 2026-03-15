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

class GrpcClient : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(bool channelReady READ channelReady NOTIFY channelReadyChanged)
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString endpoint READ endpoint CONSTANT)
    Q_PROPERTY(QString lastMessage READ lastMessage NOTIFY lastMessageChanged)
    Q_PROPERTY(QString lastStatusText READ lastStatusText NOTIFY lastStatusTextChanged)
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
