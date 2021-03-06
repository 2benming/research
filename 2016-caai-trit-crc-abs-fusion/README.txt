CRC算法的融合算法及实验代码

- runAll.m 
  这个脚本会跑所有的库。
  其中，数据库统一放在上一层目录的 datasets 下。

- runOnXXX.m
  跑某一个库的代码。
  其主要流程是准备好数据，将数据按照分类划分，一列表示一个样本。
  然后设置实验参数，包括：训练样本（开始数和结束数）。
  最后是执行算法。

- crc_abs_lambda.m
  这是整合算法的实现代码，能够自动寻找最佳参数。
  这个算法先解出CRC表示结果，对结果求绝对值之后，对它们进行融合。
  在融合时，它会使用所有预设的参数（共24个），反映两个算法的不同权重，
  最后，根据计算结果得到最优的参数和融合结果，将结果保存在文件中。其中：
  “+”号：表示融合后有提升；
  “=”号：表示融合后持平；
  “-”号：表示融合后更差。

- ../datasets 
  所有的数据库，目前算法支持下面的数据库：
  Caltech Faces （未包含）
  Caltech Leaves（未包含）
  CMU Faces		（未包含）
  COIL			（未包含）
  FERET			（未包含）
  GT			（未包含）
  LFW			（未包含）
  ORL			（未包含）
  Senthil		（可运行）
  Yale			（未包含）
  考虑到邮件发送，只留了一个库，其他库需要自行下载。

  注意：运行实验时请把 crc-abs-datasets 重命名为 datasets。
  
  论文：http://www.sciencedirect.com/science/article/pii/S2468232216300294 

  By Shaoning Zeng
  2016.6.6
