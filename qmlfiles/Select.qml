import QtQuick 
import QtQuick.Controls 
import Qt5Compat.GraphicalEffects
Window {
    title: "视频源选择"
    minimumWidth: 500
    maximumWidth: 500
    minimumHeight: 300
    maximumHeight: 300
    property string path: "未设置"

    Text {
        x:5
        y:parent.height*0.2
        text: "视频源："  // 设置文本内容
        font.pixelSize: 22     // 设置字体大小
        color: "#665cff"           // 设置文本颜色
    }
    Rectangle{
        id:textEdit
        x:100
        y:parent.height*0.2
        height:70
        width:parent.width*0.6
        TextEdit {
            id:txt
            anchors.verticalCenter:parent.verticalCenter
            width:parent.width
            text: "rtmp://49.235.224.58:1935/live/1234567"
            color: "black"
            wrapMode: TextEdit.WordWrap
            readOnly: false
            selectByMouse: true
            font.pixelSize: 20
        }
    }
    Button{
        y:parent.height*0.6
        anchors.horizontalCenter: parent.horizontalCenter //水平居中
        width: 100
        height: 40
        text: "确定"
        onClicked:{
            path = txt.text
        }
    }
    Button{
        x:parent.width*0.82
        y:parent.height*0.2
        width: 80
        height: 35
        text: "使用本地"
        onClicked:{
            txt.text=filedialog.get_file_path()
        }
    }
    DropShadow{
        anchors.fill: textEdit
        verticalOffset: 0
        horizontalOffset: 0
        radius: 5
        samples: 20
        color: "black"
        source: textEdit
    }

}