#ifndef FILETOOL_H
#define FILETOOL_H

#pragma once

#include <QByteArray>
#include <QChar>
#include <QList>
#include <QString>
#include <QStringConverter>
#include <QStringList>

#include <functional>

class FileTool
{
public:
    // Overwrite：
    //   使用 QSaveFile 安全覆盖，适合结果文件、配置文件这类“整文件替换”的场景。
    // Append：
    //   直接追加到文件尾部，适合日志文件、CSV 采样文件等持续写入场景。
    enum class WriteMode {
        Overwrite,
        Append
    };

    // 通用二进制分块读取参数。
    // 适合大体积 .dat/.bin 文件，调用方可以边读边处理，避免一次性占满内存。
    struct ChunkReadOptions {
        qint64 startOffset = 0;
        qint64 maxBytes = -1;
        qint64 chunkSize = 4 * 1024 * 1024;
    };

    // 通用逐行读取参数。
    // 适合大日志、普通文本这类“一行就是一条记录”的文件。
    struct LineReadOptions {
        qint64 startOffset = 0;
        qint64 maxLines = -1;
        qint64 chunkSize = 4 * 1024 * 1024;
        qint64 maxLineBytes = 16 * 1024 * 1024;
    };

    // CSV 流式解析参数。
    // 支持带引号字段、引号内分隔符，以及引号包裹下的换行。
    struct CsvReadOptions {
        qint64 startOffset = 0;
        qint64 maxRows = -1;
        qint64 chunkSize = 4 * 1024 * 1024;
        qsizetype maxFieldChars = 16 * 1024 * 1024;
        QChar separator = QLatin1Char(',');
        QStringConverter::Encoding encoding = QStringConverter::Utf8;
    };

    using ChunkHandler = std::function<bool(const QByteArray &chunk, qint64 chunkOffset)>;
    using LineHandler = std::function<bool(const QByteArray &line, qint64 lineOffset)>;
    using CsvRowHandler = std::function<bool(const QStringList &columns, qint64 rowIndex)>;

    FileTool() = delete;

    // 基础文件信息查询。
    static bool exists(const QString &filePath);
    static qint64 fileSize(const QString &filePath);

    // 目录与文件创建辅助接口。
    static bool ensureDirectory(const QString &dirPath, QString *error = nullptr);
    static bool ensureParentDirectory(const QString &filePath, QString *error = nullptr);
    static bool createFile(const QString &filePath, bool overwrite = false, QString *error = nullptr);

    // 小到中等体积文件的直接读取接口。
    static QByteArray readBytes(const QString &filePath,
                                qint64 offset = 0,
                                qint64 maxBytes = -1,
                                QString *error = nullptr);

    static QString readText(const QString &filePath,
                            QString *error = nullptr,
                            QStringConverter::Encoding encoding = QStringConverter::Utf8);

    // 大文件流式读取接口。
    static bool readByChunks(const QString &filePath,
                             ChunkHandler handler,
                             QString *error = nullptr);

    static bool readByChunks(const QString &filePath,
                             ChunkHandler handler,
                             const ChunkReadOptions &options,
                             QString *error = nullptr);

    static bool readLines(const QString &filePath,
                          LineHandler handler,
                          QString *error = nullptr);

    static bool readLines(const QString &filePath,
                          LineHandler handler,
                          const LineReadOptions &options,
                          QString *error = nullptr);

    static bool readCsvRows(const QString &filePath,
                            CsvRowHandler handler,
                            QString *error = nullptr);

    static bool readCsvRows(const QString &filePath,
                            CsvRowHandler handler,
                            const CsvReadOptions &options,
                            QString *error = nullptr);

    // 写入接口。
    static bool writeBytes(const QString &filePath,
                           const QByteArray &data,
                           WriteMode mode = WriteMode::Overwrite,
                           QString *error = nullptr);

    static bool writeText(const QString &filePath,
                          const QString &text,
                          WriteMode mode = WriteMode::Overwrite,
                          QString *error = nullptr,
                          QStringConverter::Encoding encoding = QStringConverter::Utf8);

    static bool writeCsvRow(const QString &filePath,
                            const QStringList &columns,
                            WriteMode mode = WriteMode::Append,
                            QString *error = nullptr,
                            QStringConverter::Encoding encoding = QStringConverter::Utf8);

    static bool writeCsvRows(const QString &filePath,
                             const QList<QStringList> &rows,
                             WriteMode mode = WriteMode::Overwrite,
                             QString *error = nullptr,
                             QStringConverter::Encoding encoding = QStringConverter::Utf8);

private:
    static void clearError(QString *error);
    static void setError(QString *error, const QString &message);
    static bool validateReadRange(qint64 offset, qint64 maxBytes, QString *error);
    static QByteArray encodeText(const QString &text, QStringConverter::Encoding encoding);
    static QString buildCsvRow(const QStringList &columns);
    static bool finalizeCsvRow(QStringList *row,
                               QString *field,
                               CsvRowHandler handler,
                               qint64 *rowIndex,
                               bool *shouldStop,
                               QString *error);
};

#endif // FILETOOL_H
