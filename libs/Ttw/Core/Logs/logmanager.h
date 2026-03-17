#ifndef LOGMANAGER_H
#define LOGMANAGER_H

#pragma once
#include <QObject>
#include <QString>
#include <QFileInfo>
#include <QSet>

// ==========================================
// 定义快捷宏 (Macros)
// ==========================================
// 宏会在编译时，自动把当前写代码的 __FILE__ 和 __FUNCTION__ 替换进去
#define LOG_TX(msg)   LogManager::instance().addLog(__FILE__, __FUNCTION__, "TX", msg)
#define LOG_RX(msg)   LogManager::instance().addLog(__FILE__, __FUNCTION__, "RX", msg)
#define LOG_ERR(msg)  LogManager::instance().addLog(__FILE__, __FUNCTION__, "ERR", msg)
#define LOG_INFO(msg) LogManager::instance().addLog(__FILE__, __FUNCTION__, "INFO", msg)

// 进阶宏：传入 QObject*，日志系统会优先使用 objectName，
// 若未设置 objectName，则自动回退到类名（例如 GrpcClient）。
#define LOG_OBJ_TX(obj, msg)   LogManager::instance().addLog(__FILE__, __FUNCTION__, "TX", msg, obj)
#define LOG_OBJ_RX(obj, msg)   LogManager::instance().addLog(__FILE__, __FUNCTION__, "RX", msg, obj)
#define LOG_OBJ_ERR(obj, msg)  LogManager::instance().addLog(__FILE__, __FUNCTION__, "ERR", msg, obj)
#define LOG_OBJ_INFO(obj, msg) LogManager::instance().addLog(__FILE__, __FUNCTION__, "INFO", msg, obj)

class LogManager : public QObject {
    Q_OBJECT
public:
    static LogManager& instance() {
        static LogManager _instance;
        return _instance;
    }

    // ==========================================
    // 黑名单控制接口 (可被 C++ 或 QML 调用)
    // ==========================================
    // 屏蔽某个类的文件 (例如: "grpcclient.cpp")
    Q_INVOKABLE void muteClass(const QString& className) {
        const QString key = normalizeKey(className);
        if (!key.isEmpty())
            m_mutedClasses.insert(key);
    }
    Q_INVOKABLE void unmuteClass(const QString& className) {
        m_mutedClasses.remove(normalizeKey(className));
    }

    // 屏蔽某个具体的对象实例 (例如: "clientGuide")
    // 如果实例未设置 objectName，则也支持按类名屏蔽 (例如: "GrpcClient")。
    Q_INVOKABLE void muteObject(const QString& objName) {
        const QString key = normalizeKey(objName);
        if (!key.isEmpty())
            m_mutedObjects.insert(key);
    }
    Q_INVOKABLE void unmuteObject(const QString& objName) {
        m_mutedObjects.remove(normalizeKey(objName));
    }

    // ==========================================
    // 核心发送引擎
    // ==========================================
    // 新增了一个可选参数 objName，用于区分不同的对象实例
    void addLog(const char* file, const char* func, const QString& type, const QString& msg, const QString& objName = "") {
        const QString cleanFileName = QFileInfo(QString(file)).fileName();
        const QString normalizedObjectName = normalizeKey(objName);

        // 【拦截魔法 1】：如果这个类被屏蔽了，直接丢弃！
        if (m_mutedClasses.contains(cleanFileName)) {
            return;
        }

        // 【拦截魔法 2】：如果传了对象名，且这个具体对象被屏蔽了，直接丢弃！
        if (!normalizedObjectName.isEmpty() && m_mutedObjects.contains(normalizedObjectName)) {
            return;
        }

        // 如果没有被拦截，才真正发往前端
        emit newLog(cleanFileName, QString(func), type, msg, normalizedObjectName);
    }

    void addLog(const char* file, const char* func, const QString& type, const QString& msg, const QObject* obj) {
        const QString cleanFileName = QFileInfo(QString(file)).fileName();
        const QString objectName = objectLogName(obj);
        const QString className = objectClassName(obj);

        if (m_mutedClasses.contains(cleanFileName)) {
            return;
        }

        if ((!objectName.isEmpty() && m_mutedObjects.contains(objectName))
            || (!className.isEmpty() && m_mutedObjects.contains(className))) {
            return;
        }

        emit newLog(cleanFileName, QString(func), type, msg, !objectName.isEmpty() ? objectName : className);
    }

signals:
    void newLog(QString className, QString funcName, QString type, QString message, QString objName);

private:
    LogManager(QObject* parent = nullptr) : QObject(parent) {}

    QString normalizeKey(const QString& value) const {
        return value.trimmed();
    }

    QString objectLogName(const QObject* obj) const {
        if (!obj) {
            return {};
        }

        return normalizeKey(obj->objectName());
    }

    QString objectClassName(const QObject* obj) const {
        if (!obj || !obj->metaObject()) {
            return {};
        }

        return normalizeKey(QString::fromLatin1(obj->metaObject()->className()));
    }

    QSet<QString> m_mutedClasses; // 类的黑名单
    QSet<QString> m_mutedObjects; // 对象的黑名单
};


#endif // LOGMANAGER_H
