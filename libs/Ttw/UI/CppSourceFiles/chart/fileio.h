#ifndef FILEIO_H
#define FILEIO_H

#pragma once
#include <QObject>
#include <QString>
#include <QUrl>
#include <QtQml/qqml.h> // 🌟 Qt 6 注册宏的头文件

class FileIO : public QObject
{
    Q_OBJECT
    QML_ELEMENT     // 🌟 告诉 Qt 6 编译器：把这个类暴露给 QML
    QML_SINGLETON   // 🌟 告诉 Qt 6 编译器：这是一个全局单例

public:
    explicit FileIO(QObject *parent = nullptr);

    Q_INVOKABLE QString readTextFile(const QUrl &fileUrl);
};

#endif // FILEIO_H
