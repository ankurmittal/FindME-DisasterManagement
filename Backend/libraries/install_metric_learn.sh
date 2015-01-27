#!/bin/sh
url="https://github.com/all-umass/metric_learn.git"
folder="metric_learn"

git clone "$url"
cd "$folder"
python setup.py install
cd ..
