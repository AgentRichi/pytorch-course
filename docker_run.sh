#!/bin/bash
sudo docker run --gpus all --rm -p 8888:8888 -e JUPYTER_ENABLE_LAB=yes -v /media/richard/:/home/jovyan/work:rw jupyter/pytorch-course
