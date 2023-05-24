# import cv2
# import torch
# import time
# from trackdet.detector import Detector
# from bytetrack_realtime.byte_tracker import ByteTracker

# YOLOV7_WEIGHT_PATH = '/home/aimol/文档/Python/Graduation/Test/weights/yolov7.pt'
# IMAGE = '/home/aimol/文档/Git_File/yolov7/coco/images/val2017/*'
# VIDEO = './videos/6.mkv'
# THREShOLD = 0.5
# def plot_boxes(frame,bboxes):
#     for bbox in bboxes:
#         track_id = bbox.track_id
#         ltrb = bbox.ltrb.astype(int)
#         score = bbox.score
#         det_class = bbox.det_class

#         text = f"{det_class} {track_id} : {score:.2f}"
#         x1,y1,x2,y2 =ltrb[0],ltrb[1],ltrb[2],ltrb[3]

#         if det_class =='car':
#             cv2.rectangle(frame, (x1,y1), (x2, y2), (255, 180, 30), thickness=2)
#             cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (200, 180, 30), thickness=2)
#         elif det_class =='person':
#             cv2.rectangle(frame, (x1, y1), (x2, y2), (100, 255, 60), thickness=2)
#             cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 255, 200), thickness=2)
#         else:
#             cv2.rectangle(frame, (x1, y1), (x2, y2), (100, 50, 200), thickness=2)
#             cv2.putText(frame, text, (x1, y1-10), cv2.FONT_HERSHEY_SIMPLEX, 0.5, (100, 50, 200), thickness=2)
        
# #### Load model
# device = 'cuda' if torch.cuda.is_available() else 'cpu'
# dete = Detector(weight_path=YOLOV7_WEIGHT_PATH,
#                 imgSize=640,
#                 threshold=THREShOLD,
#                 stride=1,
#                 device='0')
# #### Load model successful
# tracker = ByteTracker(track_thresh=0.6, track_buffer=50, match_thresh=0.9) # load track model
# def main():
#     cap = cv2.VideoCapture(VIDEO)
#     if not cap.isOpened():
#         print("无法打开视频文件！")
#         exit()
#     # 循环读取视频帧
#     while True:
#         ret, frame = cap.read()  # 读取一帧
#         # 判断是否读取到帧
#         if not ret:break
#         # 对帧进行处理
#         ### 推理
#         with torch.no_grad():
#             start_time = time.time()
#             bboxes = dete.detect(frame)
#             end_time = time.time()
#             elapsed_time = end_time - start_time
#             print("推理耗费时间为：{:.2f}毫秒".format(elapsed_time*1000))
#         converted_bboxes = [([x1, y1, x2 - x1, y2 - y1], float(confidence), detection_class) for x1, y1, x2, y2, detection_class, confidence in bboxes]
#         online_targets = tracker.update(detections=converted_bboxes)
#         info = f"total objections: {tracker.total_id}"
#         cv2.putText(frame, info, (5,25), cv2.FONT_HERSHEY_SIMPLEX, 1, (100, 117, 255), thickness=2)
#         plot_boxes(frame, online_targets)
#         # 显示处理后的帧
#         cv2.imshow("Frame", frame)
#         # 按下q键退出循环
#         if cv2.waitKey(1) == ord("q"):
#             break
#     # 释放VideoCapture对象
#     cap.release()
# if __name__ == '__main__':
#     main()
 
import sys
from pathlib import Path
# from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine
from PySide6.QtQml import QQmlApplicationEngine,qmlRegisterType
from tool import Filedialog, MyVideoItem,SetParameter
from PySide6.QtWidgets import QApplication

if __name__ == '__main__':
    app = QApplication(sys.argv)
    qmlRegisterType(MyVideoItem, "MyVideoItem", 1, 0, "MyVideoItem")
    engine = QQmlApplicationEngine()
    qml_file = Path(__file__).resolve().parent / "./qmlfiles/main.qml"
    x = Filedialog()
    setparam = SetParameter()
    engine.rootContext().setContextProperty('filedialog', x)
    engine.rootContext().setContextProperty('setparameter', setparam)
    engine.load(qml_file)
    if not engine.rootObjects():
        sys.exit(-1)
    sys.exit(app.exec())
