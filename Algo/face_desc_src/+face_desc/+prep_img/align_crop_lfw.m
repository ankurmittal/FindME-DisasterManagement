%  Copyright (c) 2014, Omkar Parkhi, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script performs pre-processing (alignment and cropping) of LFW images
% the images can be downloaded from http://vis-www.cs.umass.edu/lfw/lfw.tgz
clear;

imgDir = '../data/images/lfw/';
procImgDir = '../data/lfw_aligned/images_preproc/';

% load image list
load('../data/shared/info/database.mat', 'database');
imgList = database.images;

% load landmarks computed using the method of [Everingham et al., IVC 2009]
load('../data/lfw_aligned/lfw_landmarks.mat', 'landmarks');

numImg = numel(imgList);

%% alignment settings

% landmarks in the canonical coordinate system
basePts = [25.0347   34.1802   44.1943   53.4623   34.1208   39.3564   44.9156   31.1454   47.8747 ;
    34.1580   34.1659   34.0936   33.8063   45.4179   47.0043   45.3628   53.0275   52.7999];

% horizontal centre
cx = mean(basePts(1, [1:4, 8:9]));

% eye line
top = mean(basePts(2, 1:4));

% mouth line
bottom = mean(basePts(2, 8:9));

% horizontal distance between eyes
dx = mean(basePts(1, 3:4)) - mean(basePts(1, 1:2));

% vertical distance between eyes & mouth
dy = bottom - top;

% set crop region in the canonical coordinate system
horRatio = 1.6;
topRatio = 2;
bottomRatio = 1.2;

x0 = cx - dx * horRatio;
x1 = cx + dx * horRatio;
y0 = top - dy * topRatio;
y1 = bottom + dy * bottomRatio;

% scale
scale = 2;

basePts = basePts * scale;
x0 = x0 * scale;
x1 = x1 * scale;
y0 = y0 * scale;
y1 = y1 * scale;

%% crop images
% for idxImg = 1:numImg
parfor idxImg = 1:numImg
    
    % image path
    imPath = sprintf('%s/%s', imgDir, imgList{idxImg});
    
    % load an image
    img = imread(imPath);
    img = rgb2gray(im2single(img));
    
    % compute alignment transform
    tform = cp2tform(landmarks{idxImg}', basePts', 'similarity');
    
    % apply transform and do crop
    faceImg{idxImg} = imtransform(img, tform, 'bicubic', 'XData', [x0 x1], 'YData', [y0 y1], 'XYScale', 1);    
end

%% save all images
ensure_dir(procImgDir);
save(sprintf('%s/all_img.mat', procImgDir), 'faceImg');
