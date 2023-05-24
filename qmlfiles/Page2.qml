import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects
import MyVideoItem 1.0
import QtCharts 2.15
import QtQuick.Dialogs 

Page {
    // title: parent.title
    property bool unfold: false
    // 选择视频源窗口
    Select{
        id: select
        path: ""
        onPathChanged:{
            source_info.text="视频来源：" + select.path
            video_page.video_path = select.path
            select.visible = false
        } 
    }
    Rectangle{
        width:parent.width
        height:parent.height
        color: "white"
        visible:true
        // 侧边栏
        Rectangle{
            id: barRect;
            width: unfold ? 180 : 50;
            height: parent.height;
            radius: 0;
            color: "#FFFFFF";
            clip: true;
            border.color: "#e6e6e6";
            // 定义打开/关闭抽屉的动画
            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.InOutQuad }
            }
            ListModel{
                id: appModel;
                ListElement{
                    name: "Video";
                    icon: "../resource/home.png";
                }
                ListElement{
                    name: "Info";
                    icon: "../resource/user.png";
                }
                ListElement{
                    name: "Setting";
                    icon: "../resource/setting.png";
                }
                // ListElement{
                //     name: "Exit";
                //     icon: "../resource/exit.png";
                // }
            }
            Component{
                id: appDelegate;
                Rectangle {
                    id: delegateBackground;
                    width: barRect.width;
                    height: 48;
                    radius: 5;
                    color: "#00000000";
                    //显示图标
                    Image {
                        id: imageIcon;
                        width: 24;
                        height: 24;
                        anchors.verticalCenter: parent.verticalCenter;
                        anchors.left: parent.left;
                        anchors.leftMargin: 18;
                        mipmap: true;
                        source: icon;
                    }
                    //显示APP文字
                    Text {
                        anchors.left: imageIcon.right;
                        anchors.leftMargin: 40;
                        anchors.verticalCenter: imageIcon.verticalCenter;
                        color: "#6843d1"
                        text: name;
                        font{family: "微软雅黑"; pixelSize: 20;}
                    }
                    //鼠标处理
                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true;
                        onEntered: delegateBackground.color = "#10000000";
                        onExited: delegateBackground.color = "#00000000";
                        onClicked:{
                            switch (name) {
                                case "Video":
                                    video_page.visible=true;
                                    info_page.visible=false;
                                    setting_page.visible=false;
                                    // exit_page.visible=false;
                                    break;
                                case "Info":
                                    video_page.visible=false;
                                    info_page.visible=true;
                                    setting_page.visible=false;
                                    // exit_page.visible=false;
                                    break;
                                case "Setting":
                                    video_page.visible=false;
                                    info_page.visible=false;
                                    setting_page.visible=true;
                                    // exit_page.visible=false;
                                    break;
                                case "Exit":
                                    video_page.visible=false;
                                    info_page.visible=false;
                                    setting_page.visible=false;
                                    // exit_page.visible=true;
                                    // onClicked: stackView.pop()
                                    break;
                            }
                            
                        }
                    }
                }
            }
            GridView{
                id: appGrid;
                width: 160;
                height: parent.height;
                anchors.left: parent.left;
                anchors.top: parent.top;
                anchors.topMargin: 12   ;
                model: appModel;
                delegate: appDelegate;
                cellWidth: width;
                cellHeight: 60; 
            }
        }
        // 展开/收回按钮
        Rectangle{
            width: 34;
            height: width;
            radius: width/2;
            color: "white";
            border.color: "white";
            border.width: 5;
            anchors.left: barRect.right;
            anchors.leftMargin: -width/2;
            anchors.verticalCenter: barRect.verticalCenter;
            Image {
                width: 24;
                height: 24;
                anchors.centerIn: parent;
                mipmap: true;
                //此处使用旋转1180度实现展开按钮图标和收回按钮图标
                rotation: unfold? 180:0;
                source: "../resource/arrows.png";
            }
            MouseArea{
                anchors.fill: parent;
                onClicked: {
                    unfold = !unfold;
                }
            }
        }
        // 视频播放页面
        Rectangle{
            id:video_page
            height:parent.height
            width:parent.width-barRect.width
            anchors.right:parent.right
            color:"#f2f2f2"
            x:barRect.width+5
            visible:false
            property string video_path: ""
            
            MyVideoItem {
                id: videoItem
                anchors.fill: parent
            }
            // 来源提示信息
            Text {
                id: source_info
                text: "视频来源：未设置"  // 设置文本内容
                font.pixelSize: 22     // 设置字体大小
                color: "red"           // 设置文本颜色
            }
            // 进度条
            Rectangle{
                id:bar_background
                anchors.right: parent.right
                anchors.bottom:parent.bottom
                width:parent.width
                height:15
                radius:3
                color:"#ebebff"
                Rectangle{
                    id:bar_front
                    width:0
                    height:parent.height
                    color:"#665cff"
                }
            }
            //控制栏
            Rectangle{
                id:bottom_info
                y:parent.height-height-bar_background.height-3
                x:5
                height:40
                width:80
                radius:5
                // play
                Rectangle{
                    id:play
                    width:40
                    height:40
                    anchors.left:parent.left
                    visible:true
                    radius:5
                    property bool is_played:false
                    Image {
                        smooth: true
                        anchors.centerIn: parent;
                        width: 40
                        height: 40
                        source:"../resource/play.png"
                    }
                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered: parent.color="#ebebff"
                        onExited: parent.color="white"
                        onClicked:{
                            play.visible = !play.visible
                            pause.visible = !pause.visible
                            // 判断是否是第一次播放，如果是就加载模型，并播放
                            // 如果不是，而是继续播放暂停的视频，那么继续播放
                            videoItem.setPath(video_page.video_path)
                            videoItem.loadModel()
                            videoItem.playVideo()
                            img_button.visible = false
                        }
                    }
                }
                // pause
                Rectangle{
                    id:pause
                    width:40
                    height:40
                    anchors.left:parent.left
                    visible:false
                    radius:5
                    Image {
                        smooth: true
                        anchors.centerIn: parent;
                        width: 40
                        height: 40
                        source:"../resource/pause.png"
                    }
                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered: parent.color="#ebebff"
                        onExited: parent.color="white"
                        onClicked:{
                            pause.visible = !pause.visible
                            play.visible = !play.visible
                            videoItem.pauseVideo()
                        }
                    }
                }
                // stop
                Rectangle{
                    id:stop
                    width:40
                    height:40
                    anchors.right:parent.right
                    visible:true
                    radius:5
                    Image {
                        smooth: true
                        anchors.centerIn: parent;
                        width: 40
                        height: 40
                        source:"../resource/stop.png"
                    }
                    MouseArea{
                        anchors.fill: parent;
                        hoverEnabled: true
                        onEntered: parent.color="#ebebff"
                        onExited: parent.color="white"
                        onClicked:{
                            videoItem.stopVideo()
                            bar_front.width=0
                        }
                    }
                }
            }
            // 添加视频
            Rectangle{
                id:img_button
                width:80
                height:80
                radius:40
                anchors.centerIn: parent;
                border.color: "#cccccc";
                color:"white"
                Image {
                    id: video_bg
                    smooth: true
                    anchors.centerIn: parent;
                    width: 50
                    height: 50
                    source:"../resource/add.png"
                }
                MouseArea{
                    anchors.fill: parent;
                    onEntered: parent.color="#ebebff"
                    onExited: parent.color="white"
                    onClicked:{
                        select.visible = true
                    }
                }
            }
            function onPReceived(value) {
                var w =bar_background.width
                bar_front.width = w * value

            }
            function onCodeReceived(code) {
                img_button.visible = true
                pause.visible = false
                play.visible = true
                line_person.clear()
                line_car.clear()
                line_truck.clear()
                bar_person.clear()
                bar_car.clear()
                bar_truck.clear()
                series.at(0).value=0
                series.at(1).value=0
                series.at(2).value=0
                info_page.current_frame = 0
            }
            Component.onCompleted: {
                videoItem.sig.connect(onPReceived)
                videoItem.end.connect(onCodeReceived)
            }
        }
        // 信息可视化页面
        Rectangle{
            id:info_page
            width:parent.width-barRect.width-10
            height:parent.height-10
            color:"red"
            radius:10
            x:barRect.width+5
            y:3
            visible:false
            property int current_frame: 0
            // property int last_person: 0
            // property int last_car: 0
            // property int last_truck: 0

            function onNumReceived(person,car,truck) {
                info_page.current_frame = info_page.current_frame + 1
                var x_point = info_page.current_frame * 1
                var slice_person = series.at(0)
                var slice_car = series.at(1)
                var slice_truck = series.at(2)
                // 饼图
                slice_person.value = person
                slice_car.value = car
                slice_truck.value = truck
                // 折线图
                var max_ = Math.max(person,car,truck)
                valueAxisY.max = Math.ceil((max_+1) / 20) * 20
                valueAxisX.max = Math.ceil(info_page.current_frame/ 30) * 30
                line_person.append(x_point, person)
                line_car.append(x_point, car)
                line_truck.append(x_point, truck)
                line_person.name = "Person(%1人)".arg(person)
                line_car.name = "Car(%1辆)".arg(car)
                line_truck.name = "Truck(%1辆)".arg(truck)
                textEdit.append("累积Person数：%1人".arg(person))
                textEdit.append("累积Car数：%1辆".arg(car))
                textEdit.append("累积Truck数：%1辆".arg(truck))
                textEdit.append("--------------------")
                if(x_point < 60){
                    textEdit.append("估计人流量为：%1人 / min".arg(person))
                    textEdit.append("估计小车流量为：%1辆 / min".arg(car))
                    textEdit.append("估计卡车流量为：%1辆 / min".arg(truck))
                }else{
                    var avg_p = Math.ceil(person*60/x_point)
                    var avg_c = Math.ceil(car*60/x_point)
                    var avg_t = Math.ceil(truck*60/x_point)

                    textEdit.append("估计人流量为：%1人 / min".arg(avg_p))
                    textEdit.append("估计小车流量为：%1辆 / min".arg(avg_c))
                    textEdit.append("估计卡车流量为：%1辆 / min".arg(avg_t))
                }
            }
            function getCurrent(person,car,truck) {
                var x_point = info_page.current_frame
                var max_ = Math.max(person,car,truck)
                bar_y.max = Math.ceil((max_+1) / 10) * 10
                bar_x.max = Math.ceil(info_page.current_frame / 10) * 10

                bar_person.append(x_point, person)
                bar_car.append(x_point, car)
                bar_truck.append(x_point, truck)

                bar_person.name = "Person(%1人)".arg(person)
                bar_car.name = "Car(%1辆)".arg(car)
                bar_truck.name = "Truck(%1辆)".arg(truck)
                // 文本框
                textEdit.clear()
                textEdit.append("\n--------------------")
                textEdit.append("当前帧有：Person：%1人".arg(person))
                textEdit.append("当前帧有：Car：%1辆".arg(car))
                textEdit.append("当前帧有：Truck：%1辆".arg(truck))
                

            }
            Component.onCompleted: {
                videoItem.num.connect(onNumReceived)
                videoItem.cur_num.connect(getCurrent)
            }
            Image {
                id: info_bg
                smooth: true
                anchors.centerIn: parent;
                width: parent.width
                height: parent.height
                source:"../resource/infobg.png"
            }
            // pip
            Rectangle{
                id:pip
                width:parent.width*0.4
                height:parent.height*0.5
                visible:true
                color:"#f2f2f2"
                radius:10
                x:20
                y:15
                ChartView {
                    id: chartView
                    anchors.fill: parent
                    legend.visible: true
                    title: "Pie Chart Example"
                    antialiasing:true
                    legend.alignment: Qt.AlignRight
                    PieSeries {
                        id: series
                        PieSlice { value: 0; label: "Person(%1%)".arg((value/series.sum*100).toFixed(1));color:"#209fdf"}
                        PieSlice { value: 0; label: "Car(%1%)".arg((value/series.sum*100).toFixed(1)) ;color:"#99ca53"}
                        PieSlice { value: 0; label: "Truck(%1%)".arg((value/series.sum*100).toFixed(1));color:"#f6a625" }
                    }
                }
            }
            //bar
            Rectangle{
                id:bar
                width:parent.width*0.55
                height:parent.height*0.5
                visible:true
                color:"#f2f2f2"
                radius:10
                x:pip.width+40
                y:15
                ValueAxis {
                    id: bar_x
                    min: 0
                    max: 50
                }
                ValueAxis {
                    id: bar_y
                    min: 0
                    max: 10
                }
                ChartView {
                    id: bar_view
                    anchors.fill: parent
                    SplineSeries {
                        axisX: bar_x
                        axisY: bar_y
                        id: bar_person
                        name: "Person"
                    }
                    SplineSeries {
                        axisX: bar_x
                        axisY: bar_y
                        id: bar_car
                        name: "Car"
                    }
                    SplineSeries {
                        axisX: bar_x
                        axisY: bar_y
                        id: bar_truck
                        name: "Truck"
                    }
                }
            }
            //spline
            Rectangle{
                id:spline
                width:parent.width*0.65
                height:parent.height*0.45
                visible:true
                color:"#f2f2f2"
                radius:10
                x:20
                y:pip.height+40
               ValueAxis {
                    id: valueAxisX
                    min: 0
                    max: 50
                }
                ValueAxis {
                    id: valueAxisY
                    min: 0
                    max: 50
                }
                ChartView {
                    id: spline_view
                    anchors.fill: parent
                    SplineSeries {
                        axisX: valueAxisX
                        axisY: valueAxisY
                        id: line_person
                        name: "Person"
                    }
                    SplineSeries {
                        axisX: valueAxisX
                        axisY: valueAxisY
                        id: line_car
                        name: "Car"
                    }
                    SplineSeries {
                        axisX: valueAxisX
                        axisY: valueAxisY
                        id: line_truck
                        name: "Truck"
                    }
                }
            }
            // txt
            Rectangle{
                id:txt
                width:parent.width*0.3
                height:parent.height*0.45
                visible:true
                color:"#fafaff"
                radius:10
                x:spline.width+40
                y:pip.height+40
                TextEdit {
                    id:textEdit
                    anchors.centerIn:parent
                    width:parent.width*0.8
                    height:parent.height*0.9
                    // 设置文本框中显示的文本
                    text: "欢迎使用！"
                    // 设置文本框中的字体大小和颜色
                    font.pixelSize: 20
                    color: "black"
                    // 其他属性设置
                    wrapMode: TextEdit.Wrap
                    readOnly: true
                    selectByMouse: true
                }
            }
        }
        // 设置页面
        Rectangle{
            id:setting_page
            width:parent.width-barRect.width-10
            height:parent.height-10
            color:"gray"
            radius:10
            anchors.right:parent.right
            y:3
            visible:false

            // 目标跟踪方式，，设备，目标跟踪阈值，匹配阈值，跟踪缓存大小
            Image {
                    id: set_bg
                    smooth: true
                    anchors.centerIn: parent;
                    width: parent.width
                    height: parent.height
                    source:"../resource/settingbg.png"
            }
            // 所有设置
            Rectangle{
                id:sett
                width:600
                height:parent.height-300
                radius:10
                anchors.horizontalCenter: parent.horizontalCenter //水平居中
                anchors.verticalCenter:parent.verticalCenter
                color:"white"
                // yolov7模型版本
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70
                    width:550
                    Label {
                        text: "目标检测模型"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox1
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["yolov7.pt", "yolov7-tiny.pt"]
                        currentIndex: 0
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 目标跟踪方式 
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*2
                    width:550
                    Label {
                        text: "目标跟踪模型"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox2
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["ByteTrack"]
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 目标检测阈值 
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*3
                    width:550
                    Label {
                        text: "目标检测置信度下限"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox3
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["0.2","0.3","0.4","0.5","0.6","0.65","0.7","0.75","0.8","0.85","0.9","0.95"]
                        currentIndex: 3
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 设备 
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*4
                    width:550
                    Label {
                        text: "运算模型设备"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox4
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["0","1"]
                        currentIndex: 0
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 目标跟踪阈值
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*5
                    width:550
                    Label {
                        text: "目标跟踪置信度下限"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox5
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model:  ["0.5","0.6","0.65","0.7","0.75","0.8"]
                        currentIndex: 1
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 跟踪缓存大小 
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*6
                    width:550
                    Label {
                        text: "目标跟踪缓存大小"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox6
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["30","40","50","55","60"]
                        currentIndex: 2
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                // 匹配阈值
                Rectangle{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*7
                    width:550
                    Label {
                        text: "目标跟踪匹配阈值"
                        font.bold: true
                        font.pointSize: 14
                        color: "#666666"
                        padding: 5
                    }
                    ComboBox {
                        id: comboBox7
                        width: 150
                        height:35
                        anchors.right:parent.right
                        font.pointSize: 15
                        model: ["0.7","0.75","0.8","0.85","0.9","0.95"]
                        currentIndex: 4
                        background: Rectangle {
                            color: "#e6e6ff"
                            radius:5
                        }
                    }
                }
                Button{
                    anchors.horizontalCenter: parent.horizontalCenter //水平居中
                    y:70*8
                    height:40
                    width:100
                    background: Rectangle {
                        id:appl
                        color:"#8080FF"
                        radius: 6
                    }
                    contentItem: Text {
                        text: "应用配置"
                        color: "#f2f2f2"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        elide: Text.ElideRight
                    }
                    onPressed: {
                        appl.color="#a2a2ff"
                    }
                    onReleased: {
                        appl.color = "#8080FF"
                    }
                    onClicked:{
                        var a =comboBox1.currentText
                        var b =comboBox3.currentText
                        var c =comboBox4.currentText
                        var d =comboBox5.currentText
                        var e =comboBox6.currentText
                        var f =comboBox7.currentText
                        setparameter.setparam([a,b,c,d,e,f])
                    }
                }
                // reset
                Label{
                    id:reset
                    x:parent.width-165
                    y:70*8
                    text:"重置到默认参数"
                    color:"#b2b2b2"
                    font.family: "Microsoft YaHei"
                    font.pixelSize: 15
                    MouseArea{
                        anchors.fill: parent
                        hoverEnabled: true
                        onEntered:reset.color="#666666"
                        onExited:reset.color="#b2b2b2"
                        onClicked:{
                            comboBox1.currentIndex=0
                            comboBox2.currentIndex=0
                            comboBox3.currentIndex=3
                            comboBox4.currentIndex=0
                            comboBox5.currentIndex=1
                            comboBox6.currentIndex=2
                            comboBox7.currentIndex=4
                        }
                    }
                }
            }
            DropShadow{
                anchors.fill: sett
                verticalOffset: 2
                horizontalOffset: 2
                radius: 15
                samples: 20
                color: "lightgray"
                source: sett
            }
            property var varray: new Array
            Component.onCompleted: {
                // console.log(setparameter.getparam())
                varray= setparameter.getparam()
                comboBox1.currentIndex=varray[0]
                comboBox3.currentIndex=varray[1]
                comboBox4.currentIndex=varray[2]
                comboBox5.currentIndex=varray[3]
                comboBox6.currentIndex=varray[4]
                comboBox7.currentIndex=varray[5]
            }
        }
    }
}
