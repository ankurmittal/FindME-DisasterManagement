
# coding: utf-8

# In[1]:

import numpy as np
import scipy.io as io
from glob import glob
import Image
import fnmatch
import os
import h5py
from sklearn import metrics,svm
import matplotlib.pyplot as plt
get_ipython().magic(u'matplotlib inline')
import pandas as pd
import pickle 
from sklearn.grid_search import GridSearchCV
from sklearn.neighbors import NearestNeighbors
from skimage import viewer


# In[11]:

data_path = './data/shared/info/unrest_names.mat'
names = io.loadmat(data_path)


# In[65]:

ground_truth = []
for i in range(0, 750):
    ground_truth.append(names['nameInfo'][0,i][0][0][0][1][0])
ground_truth = np.array(ground_truth);

# In[2]:

img_path='/nfs/bigeye/asarya/google_hack/FindME-DisasterManagement/Algo/data/images/lfw/'
#image_data=glob(img_path)



# In[3]:

image_data = []
for root, dirnames, filenames in os.walk(img_path):
  for filename in fnmatch.filter(filenames, '*.jpg'):
      image_data.append(os.path.join(root, filename))

# In[4]:
image_data=sorted(image_data)


# In[5]:

file_path='./data/lfw_vj/SIFT_1pix_PCA64_GMM512/features/poolfv/1/'
feature_files=sorted(glob(file_path+'*feat_*.mat'))


# In[6]:

data={}
for file_name in feature_files:
    chunk=np.array(h5py.File(file_name)['chunk'])
    index=np.array(h5py.File(file_name)['index'])
    index=tuple([item for sublist in  index.tolist() for item in sublist ])
    for i in range(0,134):
        data[index[i]]=chunk[i,:]
train_data=[]
for item in data.items():
    train_data.append(item[1])
train_data=np.array(train_data)


# In[8]:
neigh = NearestNeighbors(n_neighbors=5, radius=1.0, algorithm='brute',leaf_size=100)

# In[9]:
neigh.fit(train_data)  

def function compute_match(query_data,neigh)
	#query data and model
	match_path=[]
	pos_matches=neigh.kneighbors(query_data, 10, return_distance=False)
	for img_id in pos_matches:
		match_path.append(image_data[img_id])
		
	return match_path


