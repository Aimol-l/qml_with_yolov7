import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

ApplicationWindow {
    id: mainWindow
    visible:true
    title: "基于YOLOv7的人流量检测系统"
    minimumWidth: 1560
    maximumWidth: 1920
    minimumHeight: 960
    maximumHeight: 1080
    // width:1920
    // height:1080
    StackView {
        id: stackView
        anchors.fill: parent
        initialItem: page2 //设置初始页面
        Component.onCompleted: {
            stackView.push(page1.createObject(stackView)) //可以在这里添加初始化页面
        }
    }
    Component {
        id: page1
        Page1{}
    }
    // 
    Component {
        id: page2
        Page2{}
    }

}