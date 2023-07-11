---
layout: post
title: 从 0 到 1 搭建图像检索系统
categories: [python, ai]
description: 从 0 到 1 搭建图像检索系统
keywords: python, es, milvus, faiss
---

## 一、 介绍

**目的**

为什么我们需要图像搜索系统？

- 时间效率：传统的基于文本的搜索需要用户将他们的查询转化为特定的关键词。这可能需要消耗大量的时间，并且可能无法获得精确的结果。相比之下，图像搜索允许用户立即找到视觉上相似的结果，提高了用户体验。
- 视觉发现：图像是一种通用的语言。通过图像搜索，用户可以在不知道物品名称的情况下找到相关的物品，或者在大型数据库中发现视觉上相似的物品。
- 电商优化：图像搜索可以增强电商平台的购物体验。例如，客户可以上传他们感兴趣的产品的照片，搜索系统可以找到可供购买的相似物品。
- 辅助功能：对于那些由于语言或其他障碍而难以进行文本搜索的人来说，图像搜索提供了一种可行的替代方案。



**图像搜索系统的应用与优势**

- 在电商和零售行业，图像搜索帮助客户快速有效地找到产品。它可以显著提升客户参与度和转化率。
- 在数字图书馆和档案馆，图像搜索帮助馆员和研究人员在大量的收藏中找到特定的图像或类别的图像。
- 在社交媒体平台，图像搜索让用户找到视觉上相似的内容，或者识别出一个图像的来源。
- 在执法部门，图像搜索可以帮助识别嫌疑人，或者在大量的安全视频中找到模式。

从技术角度来看，图像搜索系统采用了如深度学习和神经网络等先进技术。这些方法在图像识别任务上取得了显著的进步，使得图像搜索更加准确和高效。


## 二、 基本概念和原理

### 什么是图像搜索系统？

  通过图像搜索，用户上传一张图片作为查询，而不是传统的文本关键词。系统会返回一系列与查询图片在某种程度上相似的结果。这种相似度可以基于颜色、形状、模式或其他视觉元素。比如谷歌、百度的图片搜索，以及电商平台的商品搜索等，都是图像搜索系统的应用。

### 图像搜索系统是如何工作的？

  图像搜索系统的工作流程如下：

    1. 图像预处理：对于用户上传的图片，系统会对其进行预处理，包括缩放、裁剪、归一化等操作，以便后续的特征提取。
    2. 特征提取：系统会对预处理后的图片提取特征，这些特征可以是颜色、形状、纹理、模式等。特征提取的方法包括传统的计算机视觉技术，如SIFT、SURF、HOG等，也包括深度学习技术，如CNN、ResNet等。本文将介绍如何使用深度学习技术进行特征提取。
    3. 特征存储：系统会提前将提取的特征存储在数据库中，以便后续的搜索。
    4. 特征匹配与搜索：当用户上传一张图片作为查询时，系统会对其进行预处理和特征提取，然后与数据库中的特征进行比较，找到与查询图片相似的结果。
    
  整体结构：

![image search](https://user-images.githubusercontent.com/6406562/252523247-7e6adc9a-c74d-4f56-99bb-9f1c361b4b13.jpeg)


### 相关技术介绍

图像识别，特征提取

  - 图像识别，也叫主体识别，一张图片中可能包含多个物体，比如你划船的照片，既有船，也有人。图像识别的目的是找到图片中的主体，比如照片中的船或人。目前图像识别的技术已经非常成熟，可以达到非常高的准确率。深度学习中的目标检测技术，如 Faster R-CNN、YOLO 等，可以实现图像识别。
  - 特征提取，在图像搜索系统中，特征提取的目的是将图片转化为一组特征向量，以便后续的相似度计算。深度学习中的特征提取技术包括 ResNet, Vit 等。
- 图像相似度的概念以及它在图像搜索系统中的作用
  - 相似度算法：如余弦相似度（DP, dot product），欧式距离(L2)等，用于比较两张图片的相似度。DP 和 L2 都是常用的相似度算法，DP 计算两个向量的夹角余弦，分值越高，相似度越高；L2 计算两个向量的欧式距离，分值越低，相似度越高。
- 向量搜索：ANN 最大临近搜索，用于在数据库中快速找到与查询图片相似的结果。ANN 最大临近搜索算法的原理是将数据库中的向量构建成一棵树，然后在树中搜索与查询图片最相似的结果。ANN 最大临近搜索算法的优点是速度快，缺点是准确率不高。ANN 最大临近搜索算法的实现有多种，如 KNN、KD-Tree、K-Means 等。


## 三、 准备工作

- 搭建开发环境
    - 安装好 Python 环境，推荐使用 Anaconda
    - 安装好 Elasticsearch 环境，使用 es8 及以上版本，因为需要使用 Elasticsearch 的向量相似度搜索功能。
    - 为了方便图片的存储和管理，我们使用 Minio 作为图片数据库。Minio 是一个开源的对象存储服务器，可以用于存储大量的图片。安装好 Minio 后，可以通过浏览器访问 Minio 的管理界面。
- 需要的工具和库：Python, Towhee, OpenCV, Elasticsearch等
    - 安装好 Towhee 环境，Towhee 使用了流水线设计模式，已经支持了常用的已训练的模型，包括计算机视觉、自然语言处理、推荐系统等。我们使用 Towhee 去加载 YOLO 和 VIT 模型进行图像主体检测和特征提取。
    - 安装好 OpenCV 环境，用于图像预处理，包括图片裁剪、缩放、归一化等。
- 数据集选择与准备
    - 本文使用的数据集是: [imageset](https://drive.google.com/file/d/1n_370-5Stk4t0uDV1QqvYkcvyV8rbw0O/view?usp=sharing)


## 四、 构建图像搜索系统

- 图像预处理：缩放，裁剪等
  - 缩放，使用 OpenCV 的 thumbnail 函数，代码如下：

  ```py
  import cv2
  import numpy as np
  import requests
  from PIL import Image

  def thumbnail_bytes(image_bytes: bytes, max_size: int, quality=70) -> bytes:
      """
      Thumbnail the image to max_size and save it to the output_dir
      Args:
          image_bytes: image bytes
          max_size: max size of the image after resizing, width or height
          quality: quality of the resized image, 1-100
      Returns: thumbnail image bytes
      """
      image = Image.open(io.BytesIO(image_bytes))

      image.thumbnail((max_size, max_size))
      if image.mode in ('RGBA', 'LA', 'P'):
          image = image.convert('RGB')

      output = io.BytesIO()
      image.save(output, 'JPEG', optimize=True, quality=quality)
      return output.getvalue()
  ```

  裁剪使用了 Towhee 的图像处理模块，需要传人图像和图像边框 box [x1,y1,x2,y2]（左上点 + 右下点）代码如下：

  ```py
  self.detect_pipeline.flat_map(('img', 'box'), 'object', ops.towhee.image_crop())
  ```


- 图片识别：
  使用 YOLO 模型进行图片识别，通过 Towhee 加载，代码如下：

  ```py
  self.detect_pipeline = (
      pipe.input('url')
      .map('url', 'img', ops.image_decode.cv2_rgb())  # decode image
      .flat_map('img', ('box', 'label', 'score'), ops.object_detection.yolo())  # yolo model
      .filter(('img', 'box', 'label', 'score'), ('img', 'box', 'label', 'score'),
              'score', lambda x: x > 0.5)
  )  # detect pipeline for detect objects in image
  ```
  其他图片识别模型，如 Faster R-CNN 等，也可以使用 Towhee 加载。更多请参考：[Object-Detection](https://towhee.io/tasks/detail/operator?field_name=Computer-Vision&task_name=Object-Detection)

- 特征提取：
  使用 VIT 模型进行特征提取，通过 Towhee 加载，代码如下：

  ```py
  self.extract_pipeline = (
      self.detect_pipeline
      .flat_map(('img', 'box'), 'object', ops.towhee.image_crop())  # crop object
      .map('object', 'vec', ops.image_embedding.timm(model_name='vit_base_patch16_224'))  # vit model for extract features
      .map('vec', 'vec', ops.towhee.np_normalize())
  )  # extract features pipeline
  ```
  其他特征提取模型，如 ResNet 等，也可以使用 Towhee 加载。更多请参考：[Image-Embedding](https://towhee.io/tasks/detail/operator?field_name=Computer-Vision&task_name=Image-Embedding)

- 特征存储：
  使用 Elasticsearch 存储图像特征，注意需要使用 Elasticsearch 8 及以上版本，因为需要使用 Elasticsearch 的向量相似度搜索功能。索引构建代码如下：

  image_key: 图片的唯一标识，可以是图片的 url 或者其他唯一标识
  image_url: 图片的 url
  bbox: 图片中物体的边框
  bbox_score: 图片中物体的边框得分
  label: 图片中物体的类别
  features: 图片的特征向量，使用 dense_vector 类型存储

  ```py
  # create index
  PUT /imgsch
  {
    "mappings": {
      "properties": {
        "image_key": {
          "type": "keyword",
          "index": true
        },
        "image_url": {
          "type": "text",
          "index": false
        },
        "bbox": {
          "type": "keyword",
          "index": false
        },
        "bbox_score": {
          "type": "float",
          "index": true
        },
        "label": {
          "type": "text",
          "index": true
        },
        "features": {
          "type": "dense_vector",
          "dims": 768,
          "index": true,
          "similarity": "dot_product",
          "index_options": {
            "type": "hnsw",
            "m": 16,
            "ef_construction": 256
          }
        }
      }
    },
    "settings": {
      "index": {
        "refresh_interval": "180s",
        "number_of_replicas": "0"
      }
    }
  }
  ```
- 特征匹配与搜索：
  如何使用相似度算法比较和搜索图像，ANN 或 KNN 搜索算法，如何使用 Elasticsearch 的向量相似度搜索功能，如何使用 Towhee 加载 ANN 或 KNN 搜索算法，如何使用 Towhee 加载 Elasticsearch 的向量相似度搜索功能，代码如下：

  ```py
  GET /imgsch/_search
  {
      "knn": {
          "field": "features",
          "query_vector": [
              -0.13201977,
              -0.024913652,
              0.068230286,
              ...
          ],
          "k": 10,
          "num_candidates": 200
      },
      "min_score": 0.35,
      "size": 600
  }
  ```

完整代码：[repo](https://github.com/edtenz/imgsch)

## 五、实例演示

- 基于实际图像数据，提前把图片储存到 MinIO 中，为了方便模型流水线作业，针对 Minio 开发了一个图片代理服务，支持图片的 HTTP 上传和下载。
- 通过 fastAPI 开发了一个图片搜索服务，提供 HTTP 接口，支持图片的搜索，搜索结果返回图片的 url 和边框信息。
- 为了方便展示，使用 Vue3 开发了一个简单的前端页面，通过搜索服务的 HTTP 接口，实现了图片搜索功能。

```sh
├── embedding-pipeline  ## 特征提取流水线, HTTP 服务, Python
├── minio-proxy         ## 图片代理服务, HTTP 服务， Golang
├── search-front        ## 图片搜索前端, VUE3
```
  
- 效果演示：
![image search](https://user-images.githubusercontent.com/6406562/252523338-c0cef17f-8ee0-4155-bad2-aabded7abd50.png)

## 六、 优化与提升

上面的例子，是在本地单机环境下运行的，为了方便演示，使用的是 CPU 版本的模型，对于大规模的图像数据，需要考虑如何优化和提升系统的性能。

方向：
- 分布式，由单机部署变为分布式部署，提高系统的吞吐量
- 降低特征维度，提高特征提取速度
- 使用 GPU 加速
- 探索其他向量搜索中间件，比如 Milvus, 支持更大规模数量
- 




