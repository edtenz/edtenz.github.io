---
layout: post
title: 从 0 到 1 搭建图像检索系统
categories: [python, ai]
description: 从 0 到 1 搭建图像检索系统
keywords: python, es, milvus, faiss
---

## 一、图像检索可以做什么?

在信息被视觉内容淹没的今天，用户上传一张图片比描述它更自然。一个成熟的图像检索系统通常能带来几件事：

- 更短的寻找路径：无需猜关键词，直接以图搜图，业务流程更顺畅。
- 更好的发现体验：面对不熟悉的物品或复杂场景，只要拍照即可找到类似内容。
- 更高的可及性：对语言不敏感的用户，用图像与系统对话更轻松。

从电商选品、数字档案检索到公共安全分析，图像检索早已遍布各类应用。支撑它的是成熟的深度学习模型、向量数据库、ANN 检索算法等基础能力。


## 二、图像检索系统的工作原理

### 1. 什么是“以图搜图”

用户提交的是一张图片而非句子，系统需要在图库中找到视觉上相似的样本。相似度可以基于颜色、纹理、结构乃至更抽象的语义特征。谷歌、百度图片搜索和各类“拍照找同款”功能都遵循这一思路。

### 2. 标准处理流程

1. **图像预处理**：统一尺寸、裁剪噪声、归一化通道，确保输入干净稳定。
2. **特征提取**：将图片映射成定长向量。可以依赖 SIFT、HOG 等传统特征，也可以直接使用 CNN/ViT 这类深度模型输出语义向量。
3. **特征存储**：在数据库里保存向量、图片信息以及检测到的主体标签、边框等上下文。
4. **相似度检索**：对查询图像做同样的预处理和特征提取，再与库中的向量比对，返回最接近的若干结果。

#### 系统结构示意

![image search](https://user-images.githubusercontent.com/6406562/252523247-7e6adc9a-c74d-4f56-99bb-9f1c361b4b13.jpeg)

### 3. 核心技术点

- **主体识别**：Faster R-CNN、YOLO 等检测网络能够在画面中找到人、物体、场景，为下游特征提取提供精准裁剪。
- **特征提取**：ResNet、ViT 等模型把图像转成向量表示；Towhee 这样的流水线框架能快速加载主流模型。
- **相似度度量**：常用指标包括余弦相似度（dot product）和欧氏距离（L2）。两者都能衡量向量之间的距离，只是方向不同：dot product 越高越相似，L2 越低越相似。
- **向量搜索**：为了在海量向量中快速定位，通常用 ANN（Approximate Nearest Neighbor）算法，如 KNN、KD-Tree、HNSW 等。它们用树或图结构近似真实距离，在速度与精度之间取得平衡。


## 三、动手前的准备

- **基础环境**
  - Python（建议 Conda 管理），便于快速构建数据处理与服务逻辑。
  - Elasticsearch 8+，因为需要使用原生的向量相似度检索能力。
  - MinIO 作为对象存储，统一管理原始图片与裁剪结果。
- **关键依赖**
  - Towhee：流水线式机器学习框架，直接加载 YOLO、ViT 等模型。
  - OpenCV：完成缩放、裁剪、格式转换等图像预处理。
  - 其他常见工具：requests、Pillow 等，用于处理图像输入输出。
- **数据准备**
  - 文中演示使用 [imageset](https://drive.google.com/file/d/1n_370-5Stk4t0uDV1QqvYkcvyV8rbw0O/view?usp=sharing)，也可以替换成业务数据，只需确保图片带有可追踪的唯一标识。


## 四、一步步搭起图像检索系统

### 1. 图像预处理

统一尺寸与质量是所有后续工作的基础。可以用 Pillow 实现一个轻量的缩略函数：

```py
import io
from PIL import Image

def thumbnail_bytes(image_bytes: bytes, max_size: int, quality=70) -> bytes:
    image = Image.open(io.BytesIO(image_bytes))
    image.thumbnail((max_size, max_size))
    if image.mode in ('RGBA', 'LA', 'P'):
        image = image.convert('RGB')

    output = io.BytesIO()
    image.save(output, 'JPEG', optimize=True, quality=quality)
    return output.getvalue()
```

主体裁剪则交给 Towhee 的算子，输入图像以及 YOLO 检测出的 `box=[x1,y1,x2,y2]` 即可：

```py
self.detect_pipeline.flat_map(('img', 'box'), 'object', ops.towhee.image_crop())
```

### 2. 主体检测

用 Towhee 调用 YOLO，构建检测流水线：

```py
self.detect_pipeline = (
    pipe.input('url')
    .map('url', 'img', ops.image_decode.cv2_rgb())
    .flat_map('img', ('box', 'label', 'score'), ops.object_detection.yolo())
    .filter(('img', 'box', 'label', 'score'),
            ('img', 'box', 'label', 'score'),
            'score', lambda x: x > 0.5)
)
```

如果需要别的检测器（如 Faster R-CNN），只要替换对应算子。Towhee 提供的 [Object-Detection](https://towhee.io/tasks/detail/operator?field_name=Computer-Vision&task_name=Object-Detection) 列表可以直接参考。

### 3. 特征提取

在检测出的 `object` 上堆叠 ViT 模型，输出归一化向量：

```py
self.extract_pipeline = (
    self.detect_pipeline
    .flat_map(('img', 'box'), 'object', ops.towhee.image_crop())
    .map('object', 'vec', ops.image_embedding.timm(model_name='vit_base_patch16_224'))
    .map('vec', 'vec', ops.towhee.np_normalize())
)
```

ResNet、CLIP 等模型也能无缝替换，详见 [Image-Embedding](https://towhee.io/tasks/detail/operator?field_name=Computer-Vision&task_name=Image-Embedding)。

### 4. 向量与元数据存储

Elasticsearch 8+ 已经原生支持 `dense_vector` 与 HNSW 索引，结构可以设计为：

- `image_key`：图片唯一标识（URL 或业务 ID）。
- `image_url`：原图访问地址。
- `bbox` / `bbox_score` / `label`：检测结果。
- `features`：向量，设为 768 维 dot product 索引。

```json
PUT /imgsch
{
  "mappings": {
    "properties": {
      "image_key": { "type": "keyword" },
      "image_url": { "type": "text", "index": false },
      "bbox": { "type": "keyword", "index": false },
      "bbox_score": { "type": "float" },
      "label": { "type": "text" },
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

### 5. 相似度检索

无论是 ANN 库还是 Elasticsearch，查询思路都一致：以查询图像向量为中心，寻找最近邻。ES 中的 KNN 查询示例如下：

```json
GET /imgsch/_search
{
  "knn": {
    "field": "features",
    "query_vector": [
      -0.13201977,
      -0.024913652,
      0.068230286,
      "...省略向量..."
    ],
    "k": 10,
    "num_candidates": 200
  },
  "min_score": 0.35,
  "size": 600
}
```

完整实现可以参考仓库：[repo](https://github.com/edtenz/imgsch)。


## 五、端到端示例

- 图片统一上传到 MinIO。为了屏蔽底层存储细节，单独写了一个 Golang 的图片代理服务，负责 HTTP 上传、下载、鉴权。
- 特征抽取流水线通过 FastAPI 暴露 HTTP 接口，接收图片 URL 或文件流，完成检测、裁剪、向量化，并向 Elasticsearch 写入记录。
- 前端使用 Vue3 构建，只需调检索接口即可实时展示搜索结果与边框信息。

```sh
├── embedding-pipeline  ## 特征提取流水线, HTTP 服务, Python
├── minio-proxy         ## 图片代理服务, HTTP 服务， Golang
├── search-front        ## 图片搜索前端, VUE3
```

实际效果如下：

![image search](https://user-images.githubusercontent.com/6406562/252523338-c0cef17f-8ee0-4155-bad2-aabded7abd50.png)


## 六、进一步优化的方向

示例系统为了简单起见在本机 CPU 上运行，如果要应对大规模图片，需要尽早考虑：

- **分布式部署**：检测、特征提取、向量检索分别水平扩展，配合消息队列解耦。
- **特征压缩**：蒸馏或 PCA 降维，减少存储和算力开销。
- **GPU 加速**：在线检索可用 GPU 版模型；离线批处理也可用 GPU 集群提速。
- **更专业的向量库**：如 Milvus、Faiss 或向量数据云服务，在亿级数据量时更具性价比。

当这些环节打磨完毕，一个真实可用、体验平滑的图像检索系统就初具雏形了。
