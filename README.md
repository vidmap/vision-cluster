Vision cluster deployment
=========================

Currently under development.

This ansible playbook installs a standard set of software
to support vision, including current Nvidia CUDA and CUDNN drivers,
Intel MKL, a shared python 3 Anaconda, and a set of other libraries
and packages.

TODO:
  * Consider whether it makes sense to install standard builds
    of Caffe, Theano, TensorFlow, Torch, and pyTorch.

To use:
  * Install ansible 2.1 or better.
  * ansible-playbook vision.yml
