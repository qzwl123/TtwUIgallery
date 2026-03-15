#include "grpctool.h"

#include <QGrpcHttp2Channel>
#include <QReadLocker>
#include <QUrl>
#include <QWriteLocker>

// ==========================================
// 多通道管理器 (Channel Pool / Registry)
// ==========================================

bool GrpcTool::initChannel(const QString &channelName, const QString &address)
{
    if (!isValidChannelName(channelName)) {
        qWarning() << "[GrpcTool::initChannel] Channel name must not be empty.";
        return false;
    }

    const QUrl url = QUrl::fromUserInput(address.trimmed());
    if (!url.isValid() || url.scheme().isEmpty()) {
        qWarning() << "[GrpcTool::initChannel] Invalid server address:" << address;
        return false;
    }

    return registerChannel(channelName, std::make_shared<QGrpcHttp2Channel>(url));
}

// 注册时允许覆盖旧通道，便于开发阶段切换地址或重连。
bool GrpcTool::registerChannel(const QString &channelName,
                               std::shared_ptr<QAbstractGrpcChannel> channel)
{
    if (!isValidChannelName(channelName)) {
        qWarning() << "[GrpcTool::registerChannel] Channel name must not be empty.";
        return false;
    }

    if (!channel) {
        qWarning() << "[GrpcTool::registerChannel] Channel instance is null for" << channelName;
        return false;
    }

    QWriteLocker locker(&channelRegistryLock);
    const bool replacingChannel = channelRegistry.contains(channelName);
    channelRegistry.insert(channelName, std::move(channel));

    if (replacingChannel) {
        qInfo() << "[GrpcTool::registerChannel] Replaced existing channel:" << channelName;
    } else {
        qInfo() << "[GrpcTool::registerChannel] Registered channel:" << channelName;
    }

    return true;
}

std::shared_ptr<QAbstractGrpcChannel> GrpcTool::getChannel(const QString &channelName)
{
    if (!isValidChannelName(channelName)) {
        qWarning() << "[GrpcTool::getChannel] Channel name must not be empty.";
        return nullptr;
    }

    QReadLocker locker(&channelRegistryLock);
    const auto channelIt = channelRegistry.constFind(channelName);
    if (channelIt != channelRegistry.cend())
        return *channelIt;

    qWarning() << "[GrpcTool::getChannel] Channel not found:" << channelName;
    return nullptr;
}

bool GrpcTool::containsChannel(const QString &channelName)
{
    if (!isValidChannelName(channelName))
        return false;

    QReadLocker locker(&channelRegistryLock);
    return channelRegistry.contains(channelName);
}

bool GrpcTool::removeChannel(const QString &channelName)
{
    if (!isValidChannelName(channelName)) {
        qWarning() << "[GrpcTool::removeChannel] Channel name must not be empty.";
        return false;
    }

    QWriteLocker locker(&channelRegistryLock);
    const int removedCount = channelRegistry.remove(channelName);
    if (removedCount == 0) {
        qWarning() << "[GrpcTool::removeChannel] Channel not found:" << channelName;
        return false;
    }

    qInfo() << "[GrpcTool::removeChannel] Removed channel:" << channelName;
    return true;
}

bool GrpcTool::isValidChannelName(const QString &channelName)
{
    return !channelName.trimmed().isEmpty();
}
