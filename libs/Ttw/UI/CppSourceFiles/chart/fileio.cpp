#include "fileio.h"

#include <QFile>
#include <QTextStream>
#include <QDebug>

FileIO::FileIO(QObject *parent) : QObject(parent)
{
}

QString FileIO::readTextFile(const QUrl &fileUrl)
{
    if (fileUrl.isEmpty()) {
        return QString();
    }

    QString filePath;

    // 1. 智能解析 QML 传过来的 URL 路径
    if (fileUrl.isLocalFile()) {
        // 处理 file:/// 格式的本地物理文件（通常在开发调试阶段绝对路径加载时遇到）
        filePath = fileUrl.toLocalFile();
    } else if (fileUrl.scheme() == "qrc") {
        // 处理 qrc:/ 或 qrc:/// 格式的资源文件
        // QFile 识别资源文件必须以 ":" 开头，所以这里做个替换
        filePath = ":" + fileUrl.path();
    } else {
        // 兜底处理：直接取字符串形式
        filePath = fileUrl.toString();
        // 应对某些特殊写法的 qrc 路径
        if (filePath.startsWith("qrc:")) {
            filePath.replace(0, 4, ":");
        }
    }

    // 2. 尝试以只读和文本模式打开文件
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "[FileIO] 读取文件失败:" << filePath;
        qWarning() << "[FileIO] 错误原因:" << file.errorString();

        // 🌟 极其友好的 UI 报错反馈：如果找不到文件，直接在代码面板里把错误原因打印出来！
        return QString("// ⚠️ 读取失败：无法找到或打开文件。\n"
                       "// \n"
                       "// 尝试加载的底层路径: %1\n"
                       "// 系统报错信息: %2\n"
                       "// \n"
                       "// 【排查指南】\n"
                       "// 1. 检查 CMakeLists.txt 的 QML_FILES 列表中是否包含了该文件。\n"
                       "// 2. 确认文件路径是否拼写错误（注意大小写）。\n"
                       "// 3. 每次新增 .qml 文件后，必须执行一次「Run CMake」并「Rebuild」！")
            .arg(filePath)
            .arg(file.errorString());
    }

    // 3. 高效读取内容 (使用 Qt 6 标准的 UTF-8 编码读取，防止中文乱码)
    QTextStream in(&file);
    in.setEncoding(QStringConverter::Utf8);
    QString content = in.readAll();

    file.close();

    return content;
}
