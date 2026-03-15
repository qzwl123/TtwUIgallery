#include "grpcclient.h"

#include <QPointer>

GrpcClient::GrpcClient(QObject *parent)
    : QObject(parent)
    , m_grpcClient(this)
{
    const bool initOk = GrpcTool::initChannel("stream_proto", m_endpoint);
    qDebug() << "[GrpcClient] initChannel:" << initOk;

    if (auto channel = GrpcTool::getChannel("stream_proto")) {
        const bool attached = m_grpcClient.attachChannel(channel);
        qDebug() << "[GrpcClient] attachChannel:" << attached;
        setChannelReady(attached);
        setLastStatus(attached ? QStringLiteral("Channel ready.")
                               : QStringLiteral("Failed to attach channel."),
                      attached ? 0 : static_cast<int>(QtGrpc::StatusCode::Unknown));
    } else {
        qWarning() << "[GrpcClient] channel not found.";
        setChannelReady(false);
        setLastStatus(QStringLiteral("Channel was not registered."),
                      static_cast<int>(QtGrpc::StatusCode::Unavailable));
    }
}

void GrpcClient::onsayHello(const int &id, const QString &dat)
{
    if (!m_channelReady) {
        setLastStatus(QStringLiteral("Channel is not ready."),
                      static_cast<int>(QtGrpc::StatusCode::Unavailable));
        return;
    }

    routeguide::Request req;
    req.setId_proto(id);
    req.setData(dat.toUtf8());

    setBusy(true);
    setLastMessage(QString());
    setLastStatus(QStringLiteral("Sending request..."), 0);
    qDebug() << "[GrpcClient::onsayHello]" << id << dat;

    auto reply = m_grpcClient.sayHello(req);
    qDebug() << "[GrpcClient::onsayHello] reply valid:" << (reply != nullptr);

    if (!reply) {
        setBusy(false);
        setLastStatus(QStringLiteral("Failed to create gRPC request."),
                      static_cast<int>(QtGrpc::StatusCode::Unknown));
        return;
    }

    QPointer<GrpcClient> self(this);
    GrpcTool::handleReply<routeguide::Response>(
        std::move(reply),
        [self](const routeguide::Response &resp) {
            if (!self)
                return;

            self->setLastMessage(resp.message());
        },
        [self](const QGrpcStatus &status) {
            if (!self)
                return;

            self->setBusy(false);

            QString statusText = status.message();
            if (statusText.isEmpty())
                statusText = status.isOk() ? QStringLiteral("Request finished successfully.")
                                           : QStringLiteral("Request failed.");

            self->setLastStatus(statusText, static_cast<int>(status.code()));
            qDebug() << "[GrpcClient::onsayHello] finished:" << status.code() << status.message();
        });
}

void GrpcClient::clearState()
{
    setBusy(false);
    setLastMessage(QString());
    setLastStatus(m_channelReady ? QStringLiteral("Ready") : QStringLiteral("Channel is not ready."),
                  m_channelReady ? 0 : static_cast<int>(QtGrpc::StatusCode::Unavailable));
}

bool GrpcClient::channelReady() const
{
    return m_channelReady;
}

bool GrpcClient::busy() const
{
    return m_busy;
}

QString GrpcClient::endpoint() const
{
    return m_endpoint;
}

QString GrpcClient::lastMessage() const
{
    return m_lastMessage;
}

QString GrpcClient::lastStatusText() const
{
    return m_lastStatusText;
}

int GrpcClient::lastStatusCode() const
{
    return m_lastStatusCode;
}

void GrpcClient::setChannelReady(bool ready)
{
    if (m_channelReady == ready)
        return;

    m_channelReady = ready;
    emit channelReadyChanged();
}

void GrpcClient::setBusy(bool busy)
{
    if (m_busy == busy)
        return;

    m_busy = busy;
    emit busyChanged();
}

void GrpcClient::setLastMessage(const QString &message)
{
    if (m_lastMessage == message)
        return;

    m_lastMessage = message;
    emit lastMessageChanged();
}

void GrpcClient::setLastStatus(const QString &text, int code)
{
    const bool textChanged = (m_lastStatusText != text);
    const bool codeChanged = (m_lastStatusCode != code);
    if (!textChanged && !codeChanged)
        return;

    m_lastStatusText = text;
    m_lastStatusCode = code;
    emit lastStatusTextChanged();
}
