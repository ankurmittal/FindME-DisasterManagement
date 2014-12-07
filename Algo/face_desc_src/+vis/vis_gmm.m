%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script visualises the most and the least important Gaussians in a GMM according to the learnt FV dimensionality reduction model

clear;

%% settings
setName = 'lfw_aligned';
expName = 'SIFT_1pix_PCA64_GMM512';
trainSettingName = 'unrest';
gamma = 0.25;
gammaBias = 1;
idxSplit = 10;

% index of the image for visualisation
idxImg = 2050;

% config & database
conf = face_desc.config.feat_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);
confLearn = face_desc.config.learn_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);

%% load an image

allImg = load(conf.database.imPath, 'faceImg');
faceImg = allImg.faceImg{idxImg};

%% load & convert GMM
cbookDir = sprintf('%s/%d/', conf.exp.cbookDir, idxSplit);
gmmPath = sprintf('%s/gmm_512.mat', cbookDir);
gmm = load(gmmPath);

w = size(faceImg, 2);
h = size(faceImg, 1);

meanX = w * (gmm.codebook.mean(end-1, :) + 0.5);
meanY = h * (gmm.codebook.mean(end, :) + 0.5);
stdX = w * sqrt(gmm.codebook.variance(end-1, :));
stdY = h * sqrt(gmm.codebook.variance(end, :));

%% load dimensionality reduction model
confLearn.class.gamma = gamma;
confLearn.class.gammaBias = gammaBias;
outPaths = face_desc.manager.learn.get_output_paths(confLearn, idxSplit);

load(outPaths.modelPath, 'model');
W = model.state.W;

W1 = W(:, 1:end/2);
W2 = W(:, end/2 + 1 : end);

W1 = reshape(W1, [], gmm.codebook.n_gauss);
W2 = reshape(W2, [], gmm.codebook.n_gauss);

E = sum(W1 .^ 2, 1) + sum(W2 .^ 2, 1);
[sortE, sortIdxE] = sort(E, 'descend');

%% show the image and top-50 or bottom-50 Gaussians

if true
    % top-50
    idxGauss = sortIdxE(1:50);    
else
    % bottom-50
    idxGauss = sortIdxE(end-50+1:end);    
end

% show image + all Gaussians
figure;
imshow(faceImg);

hold on;

scatter(meanX(idxGauss), meanY(idxGauss), '+', 'green');
vis.ellipse(stdX(idxGauss), stdY(idxGauss), zeros(1, numel(idxGauss)), meanX(idxGauss), meanY(idxGauss), 'Color', 'red', 'LineWidth', 1);

axis equal;
