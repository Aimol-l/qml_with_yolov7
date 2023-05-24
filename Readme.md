# QML目标跟踪可视化

使用QML将YOLOv7目标检测和ByteTrack多目标跟踪结果可视化，同时实现了统计可视化。

 # 安装/Install

```bash
pip install -r requirements.txt
cd bytetrack_realtime && pip3 install .
```

项目依赖可能不完整，你需要自行补充。

项目需要CUDA环境！！

# 运行/Run

```bash
python main.py
```

# 功能列表/List

+ 支持识别本地.mp4和.mkv视频文件。
+ 支持识别RTMP协议的网络视频流。
+ 实现了视频的播放/暂停/停止。
+ 实现了 超参数的读取/保存。

# 使用截图/ScreenShot

![](/home/aimol/文档/Python/Graduation/code/images/dect.png)

![](/home/aimol/文档/Python/Graduation/code/images/test2.png)

## License

this project is licensed under [GPLv3](https://github.com/linuxdeepin/dde-file-manager/blob/master/LICENSE)

