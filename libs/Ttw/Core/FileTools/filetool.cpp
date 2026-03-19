#include "filetool.h"

#include <QDir>
#include <QFile>
#include <QFileInfo>
#include <QSaveFile>
#include <QStringDecoder>
#include <QTextStream>

#include <algorithm>

bool FileTool::exists(const QString &filePath)
{
    return QFileInfo::exists(filePath);
}

qint64 FileTool::fileSize(const QString &filePath)
{
    const QFileInfo fileInfo(filePath);
    if (!fileInfo.exists() || !fileInfo.isFile())
        return -1;

    return fileInfo.size();
}

bool FileTool::ensureDirectory(const QString &dirPath, QString *error)
{
    clearError(error);

    const QString normalizedPath = dirPath.trimmed();
    if (normalizedPath.isEmpty()) {
        setError(error, QStringLiteral("Directory path is empty."));
        return false;
    }

    QDir dir;
    if (dir.mkpath(normalizedPath))
        return true;

    setError(error, QStringLiteral("Failed to create directory: %1").arg(normalizedPath));
    return false;
}

bool FileTool::ensureParentDirectory(const QString &filePath, QString *error)
{
    clearError(error);

    const QString normalizedPath = filePath.trimmed();
    if (normalizedPath.isEmpty()) {
        setError(error, QStringLiteral("File path is empty."));
        return false;
    }

    const QFileInfo fileInfo(normalizedPath);
    return ensureDirectory(fileInfo.dir().absolutePath(), error);
}

bool FileTool::createFile(const QString &filePath, bool overwrite, QString *error)
{
    clearError(error);

    // 先统一兜底创建父目录，这样业务层只需要关心目标文件路径本身。
    if (!ensureParentDirectory(filePath, error))
        return false;

    if (!overwrite && QFileInfo::exists(filePath))
        return true;

    QFile file(filePath);
    if (!file.open(QIODevice::WriteOnly | QIODevice::Truncate)) {
        setError(error,
                 QStringLiteral("Failed to create file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    file.close();
    return true;
}

QByteArray FileTool::readBytes(const QString &filePath, qint64 offset, qint64 maxBytes, QString *error)
{
    clearError(error);

    if (!validateReadRange(offset, maxBytes, error))
        return {};

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1: %2")
                     .arg(filePath, file.errorString()));
        return {};
    }

    if (offset > file.size()) {
        setError(error,
                 QStringLiteral("Read offset %1 is beyond file size %2 for %3.")
                     .arg(offset)
                     .arg(file.size())
                     .arg(filePath));
        return {};
    }

    if (!file.seek(offset)) {
        setError(error,
                 QStringLiteral("Failed to seek file %1 to %2: %3")
                     .arg(filePath)
                     .arg(offset)
                     .arg(file.errorString()));
        return {};
    }

    if (maxBytes == 0)
        return {};

    // 这个接口仍然适合“小文件直读”。
    // 如果是几 GB 的输入文件，请优先使用下面的流式读取接口。
    const QByteArray data = maxBytes < 0 ? file.readAll() : file.read(maxBytes);
    if (file.error() != QFile::NoError) {
        setError(error,
                 QStringLiteral("Failed to read file %1: %2")
                     .arg(filePath, file.errorString()));
        return {};
    }

    return data;
}

QString FileTool::readText(const QString &filePath, QString *error, QStringConverter::Encoding encoding)
{
    clearError(error);

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1: %2")
                     .arg(filePath, file.errorString()));
        return {};
    }

    QTextStream stream(&file);
    stream.setEncoding(encoding);
    const QString text = stream.readAll();
    if (stream.status() != QTextStream::Ok) {
        setError(error,
                 QStringLiteral("Failed to read text file %1.")
                     .arg(filePath));
        return {};
    }

    return text;
}

bool FileTool::readByChunks(const QString &filePath, ChunkHandler handler, QString *error)
{
    return readByChunks(filePath, std::move(handler), ChunkReadOptions{}, error);
}

bool FileTool::readByChunks(const QString &filePath,
                            ChunkHandler handler,
                            const ChunkReadOptions &options,
                            QString *error)
{
    clearError(error);

    if (!handler) {
        setError(error, QStringLiteral("Chunk handler is empty."));
        return false;
    }

    if (!validateReadRange(options.startOffset, options.maxBytes, error))
        return false;

    if (options.chunkSize <= 0) {
        setError(error, QStringLiteral("Chunk size must be greater than 0."));
        return false;
    }

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    if (options.startOffset > file.size()) {
        setError(error,
                 QStringLiteral("Read offset %1 is beyond file size %2 for %3.")
                     .arg(options.startOffset)
                     .arg(file.size())
                     .arg(filePath));
        return false;
    }

    if (!file.seek(options.startOffset)) {
        setError(error,
                 QStringLiteral("Failed to seek file %1 to %2: %3")
                     .arg(filePath)
                     .arg(options.startOffset)
                     .arg(file.errorString()));
        return false;
    }

    qint64 currentOffset = options.startOffset;
    qint64 remainingBytes = options.maxBytes;

    // 按 chunk 流式回调，内存占用主要由 chunkSize 决定，而不是由文件总大小决定。
    while (remainingBytes != 0) {
        const qint64 requestedBytes = remainingBytes < 0
            ? options.chunkSize
            : std::min(options.chunkSize, remainingBytes);

        const QByteArray chunk = file.read(requestedBytes);
        if (chunk.isEmpty()) {
            if (file.error() != QFile::NoError) {
                setError(error,
                         QStringLiteral("Failed to read file %1: %2")
                             .arg(filePath, file.errorString()));
                return false;
            }
            break;
        }

        if (!handler(chunk, currentOffset))
            return true;

        currentOffset += chunk.size();
        if (remainingBytes > 0)
            remainingBytes -= chunk.size();

        if (chunk.size() < requestedBytes)
            break;
    }

    return true;
}

bool FileTool::readLines(const QString &filePath, LineHandler handler, QString *error)
{
    return readLines(filePath, std::move(handler), LineReadOptions{}, error);
}

bool FileTool::readLines(const QString &filePath,
                         LineHandler handler,
                         const LineReadOptions &options,
                         QString *error)
{
    clearError(error);

    if (!handler) {
        setError(error, QStringLiteral("Line handler is empty."));
        return false;
    }

    if (options.startOffset < 0) {
        setError(error, QStringLiteral("Read offset must not be negative."));
        return false;
    }

    if (options.maxLines < -1) {
        setError(error, QStringLiteral("Max lines must be -1 or greater."));
        return false;
    }

    if (options.chunkSize <= 0) {
        setError(error, QStringLiteral("Chunk size must be greater than 0."));
        return false;
    }

    if (options.maxLineBytes <= 0) {
        setError(error, QStringLiteral("Max line bytes must be greater than 0."));
        return false;
    }

    if (options.maxLines == 0)
        return true;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    if (options.startOffset > file.size()) {
        setError(error,
                 QStringLiteral("Read offset %1 is beyond file size %2 for %3.")
                     .arg(options.startOffset)
                     .arg(file.size())
                     .arg(filePath));
        return false;
    }

    if (!file.seek(options.startOffset)) {
        setError(error,
                 QStringLiteral("Failed to seek file %1 to %2: %3")
                     .arg(filePath)
                     .arg(options.startOffset)
                     .arg(file.errorString()));
        return false;
    }

    QByteArray pendingLine;
    qint64 lineOffset = options.startOffset;
    qint64 emittedLines = 0;

    // 不直接依赖 QFile::readLine()，而是自己拼完整行，
    // 这样在超长行场景下更容易控制内存和行为。
    while (true) {
        const QByteArray chunk = file.read(options.chunkSize);
        if (chunk.isEmpty()) {
            if (file.error() != QFile::NoError) {
                setError(error,
                         QStringLiteral("Failed to read file %1: %2")
                             .arg(filePath, file.errorString()));
                return false;
            }
            break;
        }

        pendingLine.append(chunk);
        if (pendingLine.size() > options.maxLineBytes) {
            setError(error,
                     QStringLiteral("Line exceeds maxLineBytes (%1) while reading %2.")
                         .arg(options.maxLineBytes)
                         .arg(filePath));
            return false;
        }

        qsizetype newLineIndex = -1;
        while ((newLineIndex = pendingLine.indexOf('\n')) != -1) {
            QByteArray line = pendingLine.left(newLineIndex);
            if (!line.isEmpty() && line.endsWith('\r'))
                line.chop(1);

            if (!handler(line, lineOffset))
                return true;

            ++emittedLines;
            const qint64 consumedBytes = static_cast<qint64>(newLineIndex) + 1;
            pendingLine.remove(0, newLineIndex + 1);
            lineOffset += consumedBytes;

            if (options.maxLines >= 0 && emittedLines >= options.maxLines)
                return true;
        }
    }

    if (!pendingLine.isEmpty()) {
        if (pendingLine.endsWith('\r'))
            pendingLine.chop(1);

        if (!handler(pendingLine, lineOffset))
            return true;
    }

    return true;
}

bool FileTool::readCsvRows(const QString &filePath, CsvRowHandler handler, QString *error)
{
    return readCsvRows(filePath, std::move(handler), CsvReadOptions{}, error);
}

bool FileTool::readCsvRows(const QString &filePath,
                           CsvRowHandler handler,
                           const CsvReadOptions &options,
                           QString *error)
{
    clearError(error);

    if (!handler) {
        setError(error, QStringLiteral("CSV row handler is empty."));
        return false;
    }

    if (options.startOffset < 0) {
        setError(error, QStringLiteral("Read offset must not be negative."));
        return false;
    }

    if (options.maxRows < -1) {
        setError(error, QStringLiteral("Max rows must be -1 or greater."));
        return false;
    }

    if (options.chunkSize <= 0) {
        setError(error, QStringLiteral("Chunk size must be greater than 0."));
        return false;
    }

    if (options.maxFieldChars <= 0) {
        setError(error, QStringLiteral("Max field chars must be greater than 0."));
        return false;
    }

    if (options.maxRows == 0)
        return true;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    if (options.startOffset > file.size()) {
        setError(error,
                 QStringLiteral("Read offset %1 is beyond file size %2 for %3.")
                     .arg(options.startOffset)
                     .arg(file.size())
                     .arg(filePath));
        return false;
    }

    if (!file.seek(options.startOffset)) {
        setError(error,
                 QStringLiteral("Failed to seek file %1 to %2: %3")
                     .arg(filePath)
                     .arg(options.startOffset)
                     .arg(file.errorString()));
        return false;
    }

    QStringDecoder decoder(options.encoding);
    QStringList currentRow;
    QString currentField;
    qint64 rowIndex = 0;
    bool inQuotes = false;
    bool pendingQuote = false;
    bool skipLeadingLf = false;

    auto checkFieldLength = [&]() -> bool {
        if (currentField.size() <= options.maxFieldChars)
            return true;

        setError(error,
                 QStringLiteral("CSV field exceeds maxFieldChars (%1) while reading %2.")
                     .arg(options.maxFieldChars)
                     .arg(filePath));
        return false;
    };

    auto parseText = [&](const QString &text, bool isFinalChunk) -> bool {
        for (qsizetype i = 0; i < text.size(); ++i) {
            QChar ch = text.at(i);

            if (skipLeadingLf) {
                skipLeadingLf = false;
                if (ch == QLatin1Char('\n'))
                    continue;
            }

            if (inQuotes) {
                // 进入引号字段后，只把双引号当作特殊字符处理。
                // 下一字符决定当前双引号是转义引号（""）还是结束引号。
                if (pendingQuote) {
                    if (ch == QLatin1Char('"')) {
                        currentField += QLatin1Char('"');
                        pendingQuote = false;
                        if (!checkFieldLength())
                            return false;
                        continue;
                    }

                    inQuotes = false;
                    pendingQuote = false;
                    --i;
                    continue;
                }

                if (ch == QLatin1Char('"')) {
                    pendingQuote = true;
                } else {
                    currentField += ch;
                    if (!checkFieldLength())
                        return false;
                }
                continue;
            }

            if (ch == QLatin1Char('"') && currentField.isEmpty()) {
                inQuotes = true;
                continue;
            }

            if (ch == options.separator) {
                currentRow.push_back(currentField);
                currentField.clear();
                continue;
            }

            if (ch == QLatin1Char('\r') || ch == QLatin1Char('\n')) {
                bool shouldStop = false;
                if (!finalizeCsvRow(&currentRow, &currentField, handler, &rowIndex, &shouldStop, error))
                    return false;

                if (ch == QLatin1Char('\r'))
                    skipLeadingLf = true;

                if (shouldStop || (options.maxRows >= 0 && rowIndex >= options.maxRows))
                    return true;

                continue;
            }

            currentField += ch;
            if (!checkFieldLength())
                return false;
        }

        if (!isFinalChunk)
            return true;

        if (pendingQuote) {
            inQuotes = false;
            pendingQuote = false;
        }

        if (inQuotes) {
            setError(error,
                     QStringLiteral("CSV quoted field is not closed in file %1.")
                         .arg(filePath));
            return false;
        }

        return true;
    };

    while (true) {
        const QByteArray chunk = file.read(options.chunkSize);
        if (chunk.isEmpty()) {
            if (file.error() != QFile::NoError) {
                setError(error,
                         QStringLiteral("Failed to read file %1: %2")
                             .arg(filePath, file.errorString()));
                return false;
            }
            break;
        }

        const QString decodedText = decoder(chunk);
        if (!parseText(decodedText, false))
            return false;

        if (options.maxRows >= 0 && rowIndex >= options.maxRows)
            return true;
    }

    const QString tailText = decoder(QByteArray());
    if (!parseText(tailText, true))
        return false;

    if (!currentRow.isEmpty() || !currentField.isEmpty()) {
        bool shouldStop = false;
        if (!finalizeCsvRow(&currentRow, &currentField, handler, &rowIndex, &shouldStop, error))
            return false;
    }

    return true;
}

bool FileTool::writeBytes(const QString &filePath,
                          const QByteArray &data,
                          WriteMode mode,
                          QString *error)
{
    clearError(error);

    if (!ensureParentDirectory(filePath, error))
        return false;

    if (mode == WriteMode::Append) {
        // 追加模式会保留已有内容，只把新数据写到文件尾部。
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append)) {
            setError(error,
                     QStringLiteral("Failed to open file %1 for append: %2")
                         .arg(filePath, file.errorString()));
            return false;
        }

        const qint64 writtenBytes = file.write(data);
        if (writtenBytes != data.size()) {
            setError(error,
                     QStringLiteral("Failed to append file %1: %2")
                         .arg(filePath, file.errorString()));
            return false;
        }

        return true;
    }

    // 覆盖模式使用 QSaveFile，写成功后再原子替换目标文件，安全性更高。
    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1 for write: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    const qint64 writtenBytes = file.write(data);
    if (writtenBytes != data.size()) {
        setError(error,
                 QStringLiteral("Failed to write file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    if (!file.commit()) {
        setError(error,
                 QStringLiteral("Failed to commit file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    return true;
}

bool FileTool::writeText(const QString &filePath,
                         const QString &text,
                         WriteMode mode,
                         QString *error,
                         QStringConverter::Encoding encoding)
{
    return writeBytes(filePath, encodeText(text, encoding), mode, error);
}

bool FileTool::writeCsvRow(const QString &filePath,
                           const QStringList &columns,
                           WriteMode mode,
                           QString *error,
                           QStringConverter::Encoding encoding)
{
    return writeText(filePath, buildCsvRow(columns), mode, error, encoding);
}

bool FileTool::writeCsvRows(const QString &filePath,
                            const QList<QStringList> &rows,
                            WriteMode mode,
                            QString *error,
                            QStringConverter::Encoding encoding)
{
    clearError(error);

    if (!ensureParentDirectory(filePath, error))
        return false;

    QStringEncoder encoder(encoding);

    if (mode == WriteMode::Append) {
        QFile file(filePath);
        if (!file.open(QIODevice::WriteOnly | QIODevice::Append)) {
            setError(error,
                     QStringLiteral("Failed to open file %1 for append: %2")
                         .arg(filePath, file.errorString()));
            return false;
        }

        for (const QStringList &row : rows) {
            const QByteArray encodedRow = encoder(buildCsvRow(row));
            if (file.write(encodedRow) != encodedRow.size()) {
                setError(error,
                         QStringLiteral("Failed to append CSV file %1: %2")
                             .arg(filePath, file.errorString()));
                return false;
            }
        }

        return true;
    }

    QSaveFile file(filePath);
    if (!file.open(QIODevice::WriteOnly)) {
        setError(error,
                 QStringLiteral("Failed to open file %1 for write: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    for (const QStringList &row : rows) {
        const QByteArray encodedRow = encoder(buildCsvRow(row));
        if (file.write(encodedRow) != encodedRow.size()) {
            setError(error,
                     QStringLiteral("Failed to write CSV file %1: %2")
                         .arg(filePath, file.errorString()));
            return false;
        }
    }

    if (!file.commit()) {
        setError(error,
                 QStringLiteral("Failed to commit CSV file %1: %2")
                     .arg(filePath, file.errorString()));
        return false;
    }

    return true;
}

void FileTool::clearError(QString *error)
{
    if (error)
        error->clear();
}

void FileTool::setError(QString *error, const QString &message)
{
    if (error)
        *error = message;
}

bool FileTool::validateReadRange(qint64 offset, qint64 maxBytes, QString *error)
{
    if (offset < 0) {
        setError(error, QStringLiteral("Read offset must not be negative."));
        return false;
    }

    if (maxBytes < -1) {
        setError(error, QStringLiteral("Max bytes must be -1 or greater."));
        return false;
    }

    return true;
}

QByteArray FileTool::encodeText(const QString &text, QStringConverter::Encoding encoding)
{
    QStringEncoder encoder(encoding);
    return encoder(text);
}

QString FileTool::buildCsvRow(const QStringList &columns)
{
    QStringList escapedColumns;
    escapedColumns.reserve(columns.size());

    for (QString column : columns) {
        // 常见 CSV 转义规则：
        // 1. 字段里只要出现分隔符、双引号或换行，就整体加双引号。
        // 2. 字段内部的双引号写成两个双引号。
        const bool needsQuotes = column.contains(',')
            || column.contains('"')
            || column.contains('\n')
            || column.contains('\r');

        column.replace(QStringLiteral("\""), QStringLiteral("\"\""));
        if (needsQuotes)
            column = QStringLiteral("\"%1\"").arg(column);

        escapedColumns.push_back(column);
    }

    return escapedColumns.join(QLatin1Char(',')) + QLatin1Char('\n');
}

bool FileTool::finalizeCsvRow(QStringList *row,
                              QString *field,
                              CsvRowHandler handler,
                              qint64 *rowIndex,
                              bool *shouldStop,
                              QString *error)
{
    if (!row || !field || !rowIndex || !shouldStop) {
        setError(error, QStringLiteral("CSV parser internal state is invalid."));
        return false;
    }

    row->push_back(*field);
    field->clear();

    *shouldStop = !handler(*row, *rowIndex);
    if (!*shouldStop)
        ++(*rowIndex);

    row->clear();
    return true;
}
