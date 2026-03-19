#ifndef FILEIO_H
#define FILEIO_H

#pragma once

#include <QObject>
#include <QString>
#include <QUrl>
#include <QVariantList>
#include <QtQml/qqml.h>

class FileIO : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    explicit FileIO(QObject *parent = nullptr);

    // 通过共享的 TtwCore 文件工具读取文本片段或源码文件。
    Q_INVOKABLE QString readTextFile(const QUrl &fileUrl);

    // 只预览前几行 CSV。
    // 这是一个直接给 QML 使用的 FileTool::readCsvRows 示例。
    Q_INVOKABLE QVariantList previewCsvFile(const QUrl &fileUrl, int maxRows = 20);

private:
    QString resolvePath(const QUrl &fileUrl) const;
};

#endif // FILEIO_H
