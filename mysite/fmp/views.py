
from django.http import HttpResponse
from django.utils import simplejson
import json

from sklearn.neighbors import NearestNeighbors
import ntpath
import numpy as np
import scipy.io as io
from glob import glob
import fnmatch
import os
import h5py


import logging, logging.config
import sys

LOGGING = {
            'version': 1,
                'handlers': {
                            'console': {
                                            'class': 'logging.StreamHandler',
                                                        'stream': sys.stdout,
                                                                }
                                },
                    'root': {
                                'handlers': ['console'],
                                        'level': 'INFO'
                                            }
                    }

logging.config.dictConfig(LOGGING)
logging.info('Hello')

class Cache:

    def __init__(self):
        self.file_path='fmp/data/1/'
        self.feature_files=sorted(glob(self.file_path+'*feat_*.mat'))
        self.img_path='fmp/data/images/lfw/'
        

    def cache_train_data(self):
        data={}
        for file_name in self.feature_files:
            chunk=np.array(h5py.File(file_name)['chunk'])
            index=np.array(h5py.File(file_name)['index'])
            index=tuple([item for sublist in  index.tolist() for item in sublist ])
            for i in range(0,134):
                data[index[i]]=chunk[i,:]

        loc_train_data=[]
        for item in data.items():
            loc_train_data.append(item[1])
        return np.array(loc_train_data)

    '''
    def NearestNeigh(self,neigh_train_data):
        loc_neigh = NearestNeighbors(n_neighbors=5, radius=1.0, algorithm='brute',leaf_size=100)
        loc_neigh.fit(neigh_train_data)
        return loc_neigh
    '''

    def load_images(self):
        loc_image_data = []
        for root, dirnames, filenames in os.walk(self.img_path):
            for filename in fnmatch.filter(filenames, '*.jpg'):
                loc_image_data.append(os.path.join(root, filename))
            
        loc_image_data=sorted(loc_image_data)
    
        return loc_image_data



obj=Cache()
train_data=obj.cache_train_data()
logging.info(type(train_data))
logging.info((os.getcwd()))
neigh = NearestNeighbors(n_neighbors=5, radius=1.0, algorithm='brute',leaf_size=100)
neigh.fit(train_data)

#neigh=obj.NearestNeigh(train_data)


image_data=obj.load_images()


def index(request):
        img_name=request.GET.get('img_name','')
        pos_x=request.GET.get('pos_x','')
        pos_y=request.GET.get('pos_y','')
        height=request.GET.get('height','')
        width=request.GET.get('width','')
        #obj.count=obj.count+1

        #count,person_name,person_id,urls=find_match(img_name,pos_x,pos_y,height,width)
        count,urls=find_match(img_name,pos_x,pos_y,height,width)

        person_name="NULL"
        person_id=1
        
        data_to_return = {
            'matches': count,
            'info': [{
                'person_name':person_name,
                'person_id':person_id,
                'urls':urls,
                }]
        }

        return HttpResponse(json.dumps(data_to_return),content_type="application/json")


def compute_match(query_data,neigh):
        match_path=[]
        pos_matches=neigh.kneighbors(query_data, 10, return_distance=False)
        for img_id in pos_matches[0]:
                match_path.append(image_data[img_id])

        return match_path


def find_match(img_name,pos_x,pos_y,height,width):
        indx=0
        for item in image_data:
            if ntpath.basename(item)==img_name:
                break
            indx+=1
        query_data=train_data[indx,:]

        urls=compute_match(query_data,neigh)
        count=len(urls)

        '''
        count=5
        person_name="Udit"
        person_id=45
        urls=["Udit_Gupta/udit1.jpg","Udit_Gupta/udit2.jpg"]
        
        return (count,person_name,person_id,urls)
        '''
        return (count,urls)


