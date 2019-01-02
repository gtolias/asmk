# ASMK

This is a Matlab package that we provide to reproduce the results 
of our ICCV paper (paper homepage: http://hal.inria.fr/docs/00/86/46/84/PDF/iccv13_tolias.pdf).
This code implements the ASMK* method, which offers the best trade-off between 
search accuracy and resource requirements (memory and speed).

@InProceedings{TAJ13,
  author       = "Giorgos Tolias and Yannis Avrithis and Herv\'e J\'egou",
  title        = "To aggregate or not to aggregate: Selective match kernels for image search",
  booktitle    = "IEEE International Conference on Computer Vision",
  month        = "dec",
  year         = "2013",
  url          = "http://hal.inria.fr/docs/00/86/46/84/PDF/iccv13_tolias.pdf"
}


# Prerequisites

The prerequisites are:
- a working version of Matlab/mex. 
  Remark: recently several problems occur with Matlab/Mex when using 
  recent versions of MacOS. Please do not contact us to solve these problems, 
  which are not specific to our package. 
- a working and recent version of Yael library (version >= v366)

We have tested the software with version R2011a under Linux. 


# Installation

These instructions are for Linux and MacOS X (just take care for
64-bits Matlab to use "long" instead of "int" for sgemm calls). This
package is not supported for Windows. Sorry.

The commands below should be lanched from the directory where you
unzipped this package.

1) Download the Yael library and the ASMK package. 

The current package library has been tested with version SVN_v366 of the 
Yael library, but forward compatibility should be preserved. 
The Yael library can be obtained from the website: 
https://gforge.inria.fr/frs/?group_id=2151

The asmk package is available on github:
https://github.com/gtolias/asmk


2) Compile the Matlab interface of yael. In linux, this can be done as: 
> tar xvzf yael_v366.tar.gz
> rm yael_v366.tar.gz
> mv yael_v366 yael
> cd yael
> ./configure.sh
> cd matlab
> make
> cd ../..

Alternately, you can also try the new Make.m file to compile directly from Matlab
> matlab
>> Make

If this does not work on your platform, please take a look at the README 
file and the Yael getting started manual. Note that you might face other 
problems with recent version of MacOS X, in particular on how to use
multi-threading. If such problems occur, consider deactivating multi-threading.


3) Get the SIFT descriptors associated with the Oxford database
> cd asmk
> wget -nH --cut-dirs=4 -r -Pdata/ ftp://ftp.irisa.fr/local/texmex/corpus/iccv2013/


4) Launch the test program in matlab:
>> test_asmk

