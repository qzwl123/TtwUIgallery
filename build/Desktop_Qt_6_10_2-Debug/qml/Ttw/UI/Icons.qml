pragma Singleton
import QtQuick

QtObject {
    // ==========================================
    // 导航与菜单 (Navigation & Menu)
    // ==========================================
    property string globalNavButton: "\uE700" // 汉堡菜单 (三道杠)
    property string wifi:            "\uE701"
    property string bluetooth:       "\uE702"
    property string connect:         "\uE703"
    property string share:           "\uE72D"
    property string link:            "\uE71B"
    property string home:            "\uE80F"
    property string settings:        "\uE713"
    property string back:            "\uE72B" // 向左箭头
    property string forward:         "\uE72A" // 向右箭头
    property string up:              "\uE74A"
    property string down:            "\uE74B"
    property string more:            "\uE712" // 三个点 (...)
    property string moreVertical:    "\uF1FA" // 竖着的三个点
    property string search:          "\uE721"
    property string history:         "\uE81C"
    property string filter:          "\uE71C"

    // ==========================================
    // 编辑与操作 (Action & Edit)
    // ==========================================
    property string add:             "\uE710" // 加号
    property string cancel:          "\uE711" // 叉号 (X)
    property string edit:            "\uE70F" // 铅笔
    property string trash:           "\uE74D" // 垃圾桶
    property string remove:          "\uE738" // 减号
    property string save:            "\uE74E"
    property string saveAs:          "\uE792"
    property string rename:          "\uE8AC"
    property string copy:            "\uE8C8"
    property string paste:           "\uE77F"
    property string cut:             "\uE8C6"
    property string send:            "\uE724"
    property string checkMark:       "\uE73E" // 对勾
    property string lock:            "\uE72E"
    property string unlock:          "\uE785"
    property string refresh:         "\uE72C"
    property string sync:            "\uE895"
    property string flag:            "\uE7C1"
    property string pin:             "\uE718"
    property string unpin:           "\uE719"

    // ==========================================
    // 媒体控制 (Media)
    // ==========================================
    property string play:            "\uE768"
    property string pause:           "\uE769"
    property string stop:            "\uE71A"
    property string previous:        "\uE892"
    property string next:            "\uE893"
    property string volume:          "\uE767"
    property string volumeMute:      "\uE74F"
    property string camera:          "\uE722"
    property string video:           "\uE714"
    property string microphone:      "\uE720"

    // ==========================================
    // 文件与文件夹 (File & Folder)
    // ==========================================
    property string folder:          "\uE8B7"
    property string folderOpen:      "\uE838"
    property string file:            "\uE7C3"
    property string document:        "\uE8A5"
    property string picture:         "\uE8B9"
    property string download:        "\uE896"
    property string upload:          "\uE898"
    property string cloud:           "\uE753"
    property string pdf:             "\uEA90"
    property string zipFolder:       "\uF012"

    // ==========================================
    // 系统与状态 (System & Status)
    // ==========================================
    property string info:            "\uE946" // 圆圈 i
    property string warning:         "\uE7BA" // 三角感叹号
    property string error:           "\uE783" // 圆圈叉号
    property string question:        "\uE9CE" // 问号
    property string user:            "\uE77B" // 用户头像
    property string group:           "\uE902" // 用户组
    property string calendar:        "\uE787"
    property string clock:           "\uE916"
    property string mail:            "\uE715"
    property string phone:           "\uE717"
    property string heart:           "\uEB51" // 爱心实心
    property string heartEmpty:      "\uEB52" // 爱心空心
    property string star:            "\uE735" // 星星实心
    property string starEmpty:       "\uE734" // 星星空心
    property string power:           "\uE7E8" // 电源键
    property string printIcon:       "\uE749"
    property string zoomIn:          "\uE8A3"
    property string zoomOut:         "\uE71F"
    property string sun:             "\uE706" // 太阳 (亮色模式用)
    property string moon:            "\uE708" // 月亮 (暗色模式用)
    property string windowMaximize:  "\uE922" // 最大化单方块
    property string windowRestore:   "\uE923" // 还原双层方块
}
