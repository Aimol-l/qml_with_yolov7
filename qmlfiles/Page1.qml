import QtQuick 2.15
import QtQuick.Window 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Page {
    id:base_window
    // title: parent.title
    Rectangle {
        width:parent.width
        height:parent.height
        Image {
            id: bg
            anchors.horizontalCenter: parent.horizontalCenter //居中
            anchors.fill: parent
            source:"../resource/BackGround.png"
        }
        Rectangle{
            id:login_back
            width:parent.width*0.54
            height:parent.height*0.41
            color:"#fafafa"
            radius:15
            anchors.horizontalCenter: parent.horizontalCenter //水平居中
            anchors.verticalCenter: parent.verticalCenter //垂直居中
            DropShadow{
                anchors.fill: login_left
                verticalOffset: 2
                horizontalOffset: 2
                radius: 8.0
                samples: 16
                color: "lightgray"
                source: login_left
            }
            // 左边
            Rectangle{
                id:login_left
                width:parent.width*0.63
                height:parent.height
                radius:0
                color:"#f2f2f2"
                Image {
                    id: camera
                    anchors.horizontalCenter: parent.horizontalCenter //居中
                    anchors.verticalCenter: parent.verticalCenter //垂直居中
                    source:"../resource/camera.png"
                }
            }
            // 右边
            Rectangle{
                id:login_right
                width:parent.width*0.37
                height:parent.height
                radius:0
                x:parent.width*0.63
                color:"#fafafa"
                Label {
                    text: "欢迎使用"
                    font.bold: true
                    font.pointSize: 20
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:parent.height*0.13
                    color: "#8080ff"
                    padding: 5
                }
                TextField{
                    id:user_id
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:parent.height*0.3
                    placeholderText:qsTr("输入用户名")
                    text:"Admin"
                    color:"#333333"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 21
                    width:login_right.width*0.7
                    height:40
                    
                    background: Rectangle {
                        border.color: "#26000000"
                        radius:6
                    }
                    onTextChanged: {
                        console.log(user_id.text)
                    }
                }
                TextField{
                    id:passwd
                    echoMode: TextField.Password
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:parent.height*0.45
                    placeholderText:qsTr("验证密钥")
                    text:"12345678"
                    color:"#333333"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 19
                    width:login_right.width*0.7
                    height:40
                    
                    background: Rectangle {
                        border.color: "#26000000"
                        radius:6
                    }
                    // onTextChanged: {
                    //     console.log(passwd.text)
                    // }
                }
                Button{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:parent.height*0.6
                    width:login_right.width*0.65
                    height:40

                    background: Rectangle {
                        id:b_bg
                        color:"#8080FF"
                        radius: 6
                    }
                    contentItem: Text {
                        text: "Login"
                        color: "#f2f2f2"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    
                    //信号槽连接
                    onPressed: {
                        b_bg.color="#a2a2ff"
                    }
                    onReleased: {
                        b_bg.color = "#8080FF"
                    }
                    onClicked:{
                        if(user_id.text=="Admin" && passwd.text =="12345678"){
                            onClicked: stackView.push(page2.createObject(stackView))
                        }else{
                            console.log("账号或密码错误！")
                        }
                        
                    }
                }
            }
        }
        DropShadow{
            anchors.fill: login_back
            verticalOffset: 2
            horizontalOffset: 2
            radius: 15
            samples: 20
            color: "lightgray"
            source: login_back
        }
    }
}
