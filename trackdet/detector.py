import torch
import numpy as np
from models.experimental import attempt_load
from utils.general import non_max_suppression, scale_coords
from utils.datasets import letterbox
from utils.torch_utils import select_device, TracedModel
# OBJ_LIST = ['person', 'car']
OBJ_LIST = ['person', 'car','truck']
class Detector(object):
    def __init__(self, weight_path, imgSize=640, threshold=0.3, stride=1,device='cpu'):
        super(Detector, self).__init__()
        self.device = device
        self.init_model(weight_path)
        self.img_size = imgSize
        self.threshold = threshold
        self.stride = stride
    def init_model(self, weight_path):
        self.weights = weight_path
        self.device = select_device(self.device)
        model = attempt_load(self.weights, map_location=self.device)
        model = TracedModel(model, self.device,640)
        model.to(self.device).eval()
        # model.half()
        model.float()
        self.m = model
        self.names = model.module.names if hasattr(
            model, 'module') else model.names
    def preprocess(self, img):
        img = letterbox(img, new_shape=self.img_size)[0]
        img = img[:, :, ::-1].transpose(2, 0, 1)
        img = np.ascontiguousarray(img)
        img = torch.from_numpy(img).to(self.device)
        # img = img.half()  # 半精度
        img = img.float()
        img /= 255.0  # 图像归一化
        if img.ndimension() == 3:
            img = img.unsqueeze(0)
        return  img

    def detect(self, im):
        img = self.preprocess(im)
        im_shape = im.shape
        pred = self.m(img, augment=False)[0]
        pred = pred.float()
        pred = non_max_suppression(pred, self.threshold, 0.4)
        pred_boxes = []
        for det in pred:
            if det is not None and len(det):
                det[:, :4] = scale_coords(
                    img.shape[2:], det[:, :4], im_shape).round()
                for *x, conf, cls_id in det:
                    lbl = self.names[int(cls_id)]
                    if not lbl in OBJ_LIST:
                        continue
                    x1, y1 = int(x[0]), int(x[1])
                    x2, y2 = int(x[2]), int(x[3])
                    pred_boxes.append(
                        (x1, y1, x2, y2, lbl, conf))
        return pred_boxes

