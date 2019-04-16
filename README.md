# Aggregated Selective Match Kernels (ASMK) for Image Retrieval

This is a Matlab package that we provide to reproduce the results 
of our ICCV 2013 paper. This code implements the ASMK* method, 
which offers the best trade-off between search accuracy and resource
 requirements (memory and speed). We additionally provide the code to 
reproduce the ASMK* results using DELF descriptors in our CVPR 2018 paper.

```
@InProceedings{TAJ13,
  author       = "Giorgos Tolias and Yannis Avrithis and Herv\'e J\'egou",
  title        = "To aggregate or not to aggregate: Selective match kernels for image search",
  booktitle    = "IEEE International Conference on Computer Vision",
  year         = "2013"
}
```

```
@InProceedings{RIT+18,
  author       = "Filip Radenovic, Ahmet Iscen, Giorgos Tolias, Yannis Avrithis, and Ondřej Chum",
  title        = "Revisiting Oxford and Paris: Large-Scale Image Retrieval Benchmarking",
  booktitle    = "IEEE Conference on Computer Vision and Patter Recognition ",
  year         = "2018"
}
```

# Prerequisites

The prerequisites are automatically downloaded when running the main scripts.

# Running

To reproduce the experiments in our ICCV 2013 paper using Hessian Affine features and
SIFT descriptors launch the test program in matlab:
>> test_asmk

# Running (2018)

To reproduce the experiments in our CVPR 2018 paper using [DELF](https://arxiv.org/abs/1612.06321) descriptors 
launch the following commands in matlab:
>> cd revisitop
>> setup
>> create_index
>> search_index
