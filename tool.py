import re
import cv2
import sys
import torch
import yaml
from PySide6.QtCore import QObject, Slot, Signal
from PyQt5.QtWidgets import QFileDialog, QApplication
from PySide6.QtCore import QThread
from PySide6.QtGui import QImage, QPixmap
from PySide6.QtQuick import QQuickPaintedItem
from trackdet.detector import Detector
from bytetrack_realtime.byte_tracker import ByteTracker

p = None

class Model():
    def __init__(self):
        self.dete = None
        self.track = None
        self.total_count_new = 0
        self.total_count_old = 0
        self.class_count = [0,0,0] # person,car,truck
        self.current_count = [0,0,0] # person,car,truck
        self.params = None

    def setup(self,params):
        self.params = params
        self.dete = Detector(weight_path = './weights/' + self.params['weight_path'],
                            imgSize = self.params['imgSize'],
                            threshold = self.params['threshold'],
                            stride = 1,
                            device = '{}'.format(self.params['device']))
        self.track = ByteTracker(track_thresh = self.params['track_thresh'],
                                track_buffer = self.params['track_buffer'], 
                                match_thresh = self.params['match_thresh'])
    def reset_track(self):
        self.class_count = [0,0,0]
        self.total_count_new = 0
        self.total_count_old = 0
        self.track.delete_all_tracks()

    def inference(self,frame):
        ### 推理
        self.current_count = [0,0,0]
        with torch.no_grad():
            bboxes = self.dete.detect(frame)
        converted_bboxes = [([x1, y1, x2 - x1, y2 - y1], float(confidence), detection_class) for x1, y1, x2, y2, detection_class, confidence in bboxes]
        online_targets = self.track.update(detections=converted_bboxes)
        self.plot_boxes(frame, online_targets)
        return frame

    def plot_boxes(self,frame,bboxes):
            self.total_count_new = self.track.total_id
            current_objs = {}
            for bb in bboxes:
                current_objs[bb.track_id] = bb.det_class
            print(self.class_count,"sum=",self.track.total_id)
            if self.total_count_new > self.total_count_old:
                # 说明被跟踪物体有增加,下标起点是上次的total_count_old值
                length = self.total_count_new - self.total_count_old
                for i in range(length):
                    index = self.total_count_old+i+1
                    if index not in current_objs:
                        current_objs[index] ='unknow'
                        # print('unknow',index)
                    if current_objs[index] == "person":
                        self.class_count[0]= self.class_count[0]+1
                        self.total_count_old =self.total_count_old+1
                    if current_objs[index] == "car":
                        self.class_count[1] = self.class_count[1]+1
                        self.total_count_old = self.total_count_old+1
                    if current_objs[index] == "truck":
                        self.class_count[2]= self.class_count[2]+1
                        self.total_count_old =self.total_count_old+1
            for bbox in bboxes:
                track_id = bbox.track_id
                ltrb = bbox.ltrb.astype(int)
                score = bbox.score
                det_class = bbox.det_class
                text = f"{det_class} {track_id} : {score:.2f}"
                x1,y1,x2,y2 =ltrb[0],ltrb[1],ltrb[2],ltrb[3]
                if det_class =='car':
                    self.current_count[1] = self.current_count[1]+1
                    cv2.rectangle(frame, (x1,y1), (x2, y2), (255, 180, 30), thickness=2)
                    cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 180, 30), thickness=2)
                elif det_class =='person':
                    self.current_count[0] = self.current_count[0]+1
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (100, 255, 60), thickness=2)
                    cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 255, 200), thickness=2)
                else:
                    self.current_count[2] = self.current_count[2]+1
                    cv2.rectangle(frame, (x1, y1), (x2, y2), (100, 50, 200), thickness=2)
                    cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 50, 200), thickness=2)

class VideoThread(QThread):
    frameChanged = Signal(QImage)
    objections = Signal(int,int,int)
    videoEnd = Signal(int)
    def __init__(self):
        super().__init__()
        self.video_path = None
        self.running = False
        self.model = None
        self.current = 0
        self.cap = None
        self.frame_count = None
    def run(self):
        pattern = r"^rtmp:\/\/([\d\.]+):(\d+)\/(\w+)\/(\w+)$"
        if re.match(pattern, self.video_path):
            print('这是一个流地址')
            self.frame_count = 999999
        else:
            self.frame_count = int(self.cap.get(cv2.CAP_PROP_FRAME_COUNT))

        while self.running :
            self.current += 1
            global p
            p = self.current/self.frame_count
            ret, frame = self.cap.read()

            if ret:
                frame = self.model.inference(frame)
                # time.sleep(3)
                image = QImage(frame.data, frame.shape[1], frame.shape[0], QImage.Format_RGB888)
                self.frameChanged.emit(image)
            else:
                self.cap.release()
                self.stop()
                break
            if self.current % 30 == 0:
                person,car,truck=self.model.current_count
                self.objections.emit(person,car,truck)
                print("send",self.current,self.model.current_count)

    def stop(self):
        global p
        p = 0
        self.current = 0
        self.running = False
        self.videoEnd.emit(0)

    def pause(self):
        self.running = False
    
    def play(self):
        self.running = True


class MyVideoItem(QQuickPaintedItem):
    sig = Signal(float)
    num = Signal(int,int,int)
    cur_num = Signal(int,int,int)
    end = Signal(int)
    def __init__(self, parent=None):
        QQuickPaintedItem.__init__(self, parent)
        self.thread = VideoThread()
        self.latest_frame = None
        self.frame_count = 0
        self.current_frame = 0
        self.model = Model()
        self.is_played = False
        self.is_loaded = False
        self.thread.frameChanged.connect(self.onFrameChanged)
        self.thread.objections.connect(self.sendObjections)
        self.thread.videoEnd.connect(self.onVideoEnd)

    @Slot(str)
    def setPath(self,path):
        self.thread.video_path = path
        if not self.is_played:
            self.thread.cap = cv2.VideoCapture(path)
            self.is_played = not self.is_played
        print('setpath')
    @Slot()
    def loadModel(self):
        if  not self.is_loaded :
            # 从文件中读取参数
            with open('./config/Hyperparameter.yaml', 'r') as f:
                params = yaml.load(f, Loader=yaml.FullLoader)
            self.thread.model = self.model
            self.is_loaded = not self.is_loaded
            self.model.setup(params)  
            print(params)
        
    @Slot()
    def playVideo(self):
        self.is_finshed = False
        self.thread.play()
        self.thread.start()
        print('play')
    @Slot()
    def pauseVideo(self):
        self.thread.pause()
        print('pause')
    @Slot()
    def stopVideo(self):
        self.thread.stop()
        self.model.reset_track()
        print('stop')

    def onVideoEnd(self,code):
        self.model.reset_track()
        self.is_played = False
        self.end.emit(code)
        print('endvideo')
    def sendObjections(self,person,car,truck):
        self.cur_num.emit(person,car,truck)
        self.num.emit(self.model.class_count[0],self.model.class_count[1],self.model.class_count[2])
    def onFrameChanged(self, image):
        self.latest_frame = image
        self.update()
    def paint(self, painter):
        self.sig.emit(p)
        # self.num.emit(self.model.class_count[0],self.model.class_count[1],self.model.class_count[2])
        if self.thread and self.thread.isRunning():
            pixmap = QPixmap.fromImage(self.latest_frame.rgbSwapped())
            painter.drawPixmap(self.boundingRect().toRect(), pixmap)
            
# 定义一个类，将我们需要用到的方法、变量等都放到里面，便于调用
class Filedialog(QObject):
    def __init__(self):
        super(Filedialog, self).__init__()

    @Slot(result=str) 
    def get_file_path(self):
        app = QApplication(sys.argv)
        file_dialog = QFileDialog()
        file_dialog.setNameFilter("Video Files (*.mp4 *.mkv)")
        file_dialog.exec_()
        selected_files = file_dialog.selectedFiles()
        if len(selected_files):
            return(selected_files[0])
        else:
            return("未设置")

class SetParameter(QObject):
    # param = Signal(int,int,int,int,int,int,int)
    def __init__(self):
        super(SetParameter, self).__init__()
    @Slot(result=list)
    def getparam(self):
        # 读取配置文件
        with open('./config/Hyperparameter.yaml', 'r') as f:
                params = yaml.load(f, Loader=yaml.FullLoader)
        weight_path = params['weight_path']
        threshold = params['threshold']
        device = params['device']
        track_thresh = params['track_thresh']
        track_buffer = params['track_buffer']
        match_thresh = params['match_thresh']
        val =[weight_path,threshold,device,track_thresh,track_buffer,match_thresh]
        all_=[["yolov7.pt", "yolov7-tiny.pt", "yolov7-w6.pt"],
        [0.2,0.3,0.4,0.5,0.6,0.65,0.7,0.75,0.8,0.85,0.9,0.95],
        [0,1],
        [0.5,0.6,0.65,0.7,0.75,0.8],
        [30,40,50,55,60],
        [0.7,0.75,0.8,0.85,0.9,0.95]]
        indexs = [ all_[i].index(val[i]) for i in range(6)]
        return(indexs)
    @Slot(list)
    def setparam(self,params):
        print(params)
        dic = {}
        dic['weight_path']=params[0]
        dic['threshold']=params[1]
        dic['device']=params[2]
        dic['track_thresh']=params[3]
        dic['track_buffer']=params[4]
        dic['match_thresh']=params[5]
        dic['imgSize'] = '640'
        with open('./config/Hyperparameter.yaml', 'w') as f:
           for key,val in dic.items():
            f.write(key+": "+val)
            f.write('\n')