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

/**
 * @file filetool.h
 * @brief TtwCore 通用文件工具：统一提供创建、读取、写入及流式解析能力。
 *
 * 说明：
 * 1. 本类是纯静态工具类，不持有状态，不需要实例化。
 * 2. 头文件采用 Doxygen/QDoc 友好的注释风格，便于后续文档生成与接口注册归档。
 * 3. 大文件场景优先使用 readByChunks/readLines/readCsvRows，避免 readAll 造成内存峰值过高。
 */
class FileTool
{
public:
    /**
     * @brief 文件写入模式。
     *
     * - Overwrite：覆盖写（内部使用 QSaveFile，提交成功后原子替换）。
     * - Append：追加写（直接写入现有文件末尾）。
     */
    enum class WriteMode {
        Overwrite,
        Append
    };

    /**
     * @brief 二进制分块读取参数。
     */
    struct ChunkReadOptions {
        /** @brief 起始偏移（字节）。 */
        qint64 startOffset = 0;
        /** @brief 最多读取字节数；-1 表示读取到文件末尾。 */
        qint64 maxBytes = -1;
        /** @brief 单次分块大小（字节）。 */
        qint64 chunkSize = 4 * 1024 * 1024;
    };

    /**
     * @brief 逐行读取参数。
     */
    struct LineReadOptions {
        /** @brief 起始偏移（字节）。 */
        qint64 startOffset = 0;
        /** @brief 最多回调行数；-1 表示不限制。 */
        qint64 maxLines = -1;
        /** @brief 单次分块大小（字节）。 */
        qint64 chunkSize = 4 * 1024 * 1024;
        /** @brief 单行最大字节数保护阈值，超出即报错。 */
        qint64 maxLineBytes = 16 * 1024 * 1024;
    };

    /**
     * @brief CSV 流式解析参数。
     *
     * 支持常见 CSV 规则：
     * - 引号字段；
     * - 引号内分隔符；
     * - 引号内换行。
     */
    struct CsvReadOptions {
        /** @brief 起始偏移（字节）。 */
        qint64 startOffset = 0;
        /** @brief 最多回调行数；-1 表示不限制。 */
        qint64 maxRows = -1;
        /** @brief 单次分块大小（字节）。 */
        qint64 chunkSize = 4 * 1024 * 1024;
        /** @brief 单字段最大字符数保护阈值，超出即报错。 */
        qsizetype maxFieldChars = 16 * 1024 * 1024;
        /** @brief 列分隔符，默认逗号。 */
        QChar separator = QLatin1Char(',');
        /** @brief 文本解码编码，默认 UTF-8。 */
        QStringConverter::Encoding encoding = QStringConverter::Utf8;
    };

    /**
     * @brief 二进制分块回调。
     * @param chunk 当前数据块。
     * @param chunkOffset 当前数据块在文件中的偏移（字节）。
     * @return true 继续读取，false 终止读取（按成功结束处理）。
     */
    using ChunkHandler = std::function<bool(const QByteArray &chunk, qint64 chunkOffset)>;

    /**
     * @brief 逐行回调。
     * @param line 当前行内容（不包含行尾换行符）。
     * @param lineOffset 当前行起始偏移（字节）。
     * @return true 继续读取，false 终止读取（按成功结束处理）。
     */
    using LineHandler = std::function<bool(const QByteArray &line, qint64 lineOffset)>;

    /**
     * @brief CSV 行回调。
     * @param columns 当前行拆分后的列数据。
     * @param rowIndex 当前行索引（从 0 开始）。
     * @return true 继续读取，false 终止读取（按成功结束处理）。
     */
    using CsvRowHandler = std::function<bool(const QStringList &columns, qint64 rowIndex)>;

    FileTool() = delete;

    /**
     * @brief 判断目标路径是否存在。
     * @param filePath 文件路径。
     * @return true 存在，false 不存在。
     */
    static bool exists(const QString &filePath);

    /**
     * @brief 获取文件大小。
     * @param filePath 文件路径。
     * @return 文件大小（字节）；若文件不存在或非普通文件返回 -1。
     */
    static qint64 fileSize(const QString &filePath);

    /**
     * @brief 确保目录存在，不存在则创建。
     * @param dirPath 目录路径。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool ensureDirectory(const QString &dirPath, QString *error = nullptr);

    /**
     * @brief 确保文件的父目录存在，不存在则创建。
     * @param filePath 文件路径。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool ensureParentDirectory(const QString &filePath, QString *error = nullptr);

    /**
     * @brief 创建文件（可选覆盖）。
     * @param filePath 文件路径。
     * @param overwrite true 表示若已存在则清空覆盖；false 表示存在即视为成功。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool createFile(const QString &filePath, bool overwrite = false, QString *error = nullptr);

    /**
     * @brief 按字节读取（适合小到中等体积文件）。
     * @param filePath 文件路径。
     * @param offset 起始偏移（字节）。
     * @param maxBytes 最多读取字节数；-1 表示读到文件末尾。
     * @param error 可选错误输出。
     * @return 读取到的数据；失败时返回空数组并写入 error。
     */
    static QByteArray readBytes(const QString &filePath,
                                qint64 offset = 0,
                                qint64 maxBytes = -1,
                                QString *error = nullptr);

    /**
     * @brief 按文本读取（适合小到中等体积文件）。
     * @param filePath 文件路径。
     * @param error 可选错误输出。
     * @param encoding 文本编码，默认 UTF-8。
     * @return 读取到的文本；失败时返回空字符串并写入 error。
     */
    static QString readText(const QString &filePath,
                            QString *error = nullptr,
                            QStringConverter::Encoding encoding = QStringConverter::Utf8);

    /**
     * @brief 使用默认参数进行二进制分块读取。
     * @param filePath 文件路径。
     * @param handler 分块回调。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readByChunks(const QString &filePath,
                             ChunkHandler handler,
                             QString *error = nullptr);

    /**
     * @brief 二进制分块读取（可指定参数）。
     * @param filePath 文件路径。
     * @param handler 分块回调。
     * @param options 分块读取参数。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readByChunks(const QString &filePath,
                             ChunkHandler handler,
                             const ChunkReadOptions &options,
                             QString *error = nullptr);

    /**
     * @brief 使用默认参数逐行读取。
     * @param filePath 文件路径。
     * @param handler 逐行回调。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readLines(const QString &filePath,
                          LineHandler handler,
                          QString *error = nullptr);

    /**
     * @brief 逐行读取（可指定参数）。
     * @param filePath 文件路径。
     * @param handler 逐行回调。
     * @param options 逐行读取参数。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readLines(const QString &filePath,
                          LineHandler handler,
                          const LineReadOptions &options,
                          QString *error = nullptr);

    /**
     * @brief 使用默认参数流式读取 CSV 行。
     * @param filePath 文件路径。
     * @param handler CSV 行回调。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readCsvRows(const QString &filePath,
                            CsvRowHandler handler,
                            QString *error = nullptr);

    /**
     * @brief 流式读取 CSV 行（可指定参数）。
     * @param filePath 文件路径。
     * @param handler CSV 行回调。
     * @param options CSV 读取参数。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool readCsvRows(const QString &filePath,
                            CsvRowHandler handler,
                            const CsvReadOptions &options,
                            QString *error = nullptr);

    /**
     * @brief 按字节写入文件。
     * @param filePath 文件路径。
     * @param data 写入数据。
     * @param mode 写入模式（覆盖/追加）。
     * @param error 可选错误输出。
     * @return true 成功，false 失败。
     */
    static bool writeBytes(const QString &filePath,
                           const QByteArray &data,
                           WriteMode mode = WriteMode::Overwrite,
                           QString *error = nullptr);

    /**
     * @brief 按文本写入文件。
     * @param filePath 文件路径。
     * @param text 写入文本。
     * @param mode 写入模式（覆盖/追加）。
     * @param error 可选错误输出。
     * @param encoding 文本编码，默认 UTF-8。
     * @return true 成功，false 失败。
     */
    static bool writeText(const QString &filePath,
                          const QString &text,
                          WriteMode mode = WriteMode::Overwrite,
                          QString *error = nullptr,
                          QStringConverter::Encoding encoding = QStringConverter::Utf8);

    /**
     * @brief 写入一行 CSV。
     * @param filePath 文件路径。
     * @param columns 行列数据。
     * @param mode 写入模式，默认追加。
     * @param error 可选错误输出。
     * @param encoding 文本编码，默认 UTF-8。
     * @return true 成功，false 失败。
     */
    static bool writeCsvRow(const QString &filePath,
                            const QStringList &columns,
                            WriteMode mode = WriteMode::Append,
                            QString *error = nullptr,
                            QStringConverter::Encoding encoding = QStringConverter::Utf8);

    /**
     * @brief 写入多行 CSV。
     * @param filePath 文件路径。
     * @param rows 多行列数据。
     * @param mode 写入模式，默认覆盖。
     * @param error 可选错误输出。
     * @param encoding 文本编码，默认 UTF-8。
     * @return true 成功，false 失败。
     */
    static bool writeCsvRows(const QString &filePath,
                             const QList<QStringList> &rows,
                             WriteMode mode = WriteMode::Overwrite,
                             QString *error = nullptr,
                             QStringConverter::Encoding encoding = QStringConverter::Utf8);

private:
    /**
     * @brief 清空错误字符串。
     */
    static void clearError(QString *error);

    /**
     * @brief 设置错误字符串。
     */
    static void setError(QString *error, const QString &message);

    /**
     * @brief 校验读取区间参数合法性。
     */
    static bool validateReadRange(qint64 offset, qint64 maxBytes, QString *error);

    /**
     * @brief 按指定编码将文本转为字节数组。
     */
    static QByteArray encodeText(const QString &text, QStringConverter::Encoding encoding);

    /**
     * @brief 生成一行 CSV 文本（包含必要的转义与换行）。
     */
    static QString buildCsvRow(const QStringList &columns);

    /**
     * @brief 完成当前 CSV 行并触发回调。
     */
    static bool finalizeCsvRow(QStringList *row,
                               QString *field,
                               CsvRowHandler handler,
                               qint64 *rowIndex,
                               bool *shouldStop,
                               QString *error);
};

#endif // FILETOOL_H
