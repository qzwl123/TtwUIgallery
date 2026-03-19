#include "fileio.h"

#include <QDebug>

#include <FileTools/filetool.h>

FileIO::FileIO(QObject *parent)
    : QObject(parent)
{
}

QString FileIO::resolvePath(const QUrl &fileUrl) const
{
    if (fileUrl.isEmpty())
        return {};

    if (fileUrl.isLocalFile())
        return fileUrl.toLocalFile();

    if (fileUrl.scheme() == "qrc")
        return ":" + fileUrl.path();

    QString filePath = fileUrl.toString();
    if (filePath.startsWith("qrc:"))
        filePath.replace(0, 4, ":");

    return filePath;
}

QString FileIO::readTextFile(const QUrl &fileUrl)
{
    const QString filePath = resolvePath(fileUrl);
    if (filePath.isEmpty())
        return {};

    QString error;
    const QString content = FileTool::readText(filePath, &error);
    if (error.isEmpty())
        return content;

    qWarning() << "[FileIO] Failed to read file:" << filePath;
    qWarning() << "[FileIO] Error:" << error;

    return QString("// Failed to read file.\n"
                   "//\n"
                   "// Target path: %1\n"
                   "// Error: %2\n"
                   "//\n"
                   "// Checklist:\n"
                   "// 1. Confirm the file is included in CMake/qrc.\n"
                   "// 2. Confirm the path spelling and case.\n"
                   "// 3. Re-run CMake and rebuild after adding new files.")
        .arg(filePath, error);
}

QVariantList FileIO::previewCsvFile(const QUrl &fileUrl, int maxRows)
{
    QVariantList previewRows;

    const QString filePath = resolvePath(fileUrl);
    if (filePath.isEmpty())
        return previewRows;

    FileTool::CsvReadOptions options;
    options.maxRows = qMax(0, maxRows);

    QString error;
    const bool ok = FileTool::readCsvRows(
        filePath,
        [&previewRows](const QStringList &columns, qint64 rowIndex) {
            Q_UNUSED(rowIndex);

            QVariantList rowData;
            rowData.reserve(columns.size());
            for (const QString &column : columns)
                rowData.push_back(column);

            previewRows.push_back(rowData);
            return true;
        },
        options,
        &error);

    if (!ok) {
        qWarning() << "[FileIO] Failed to preview CSV:" << filePath;
        qWarning() << "[FileIO] Error:" << error;
        return {};
    }

    return previewRows;
}
