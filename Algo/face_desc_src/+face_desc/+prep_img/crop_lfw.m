%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script performs pre-processing (cropping) of LFW images
% the images can be downloaded from http://vis-www.cs.umass.edu/lfw/lfw.tgz
clear;

imgDir = '../data/images/lfw/';
procImgDir = '../data/lfw_vj/images_preproc/';

% load image list
load('../data/shared/info/database.mat', 'database');
imgList = database.images;

numImg = numel(imgList);

%% crop images
% for idxImg = 1:numImg
parfor idxImg = 1:numImg  
    % image path
    imPath = sprintf('%s/%s', imgDir, imgList{idxImg});
    
    % load an image
    img = imread(imPath);
    img = rgb2gray(im2single(img));
    
    % crop a Viola-Jones face detection
    faceImg{idxImg} = img(68:181, 68:181);
end

%% save all images
ensure_dir(procImgDir);
save(sprintf('%s/all_img.mat', procImgDir), 'faceImg');
