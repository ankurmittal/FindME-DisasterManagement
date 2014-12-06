%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this example script shows how to compute a dimensionality-reduced FV face representation of a single image
clear;

run('./startup.m');

% load SIFT PCA projection
linTrans = load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/codebooks/10/PCA_64.mat');

% load GMM
load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/codebooks/10/gmm_512.mat', 'codebook');

% FV encoder
faceDescriptor = face_desc.lib.face_descriptor.poolFV();
faceDescriptor.set_feat_proj(linTrans);
faceDescriptor.set_codebook(codebook);

% load a discriminative FV projection
load('../data/lfw_vj/SIFT_1pix_PCA64_GMM512/models/dimred_class_unreg_128/10/g0.25_gb10.mat', 'model');

% load a face image
allImg = load('../data/lfw_vj/images_preproc/all_img.mat');
faceImg = allImg.faceImg{1};

% compute the descriptor
faceDesc = faceDescriptor.compute(faceImg, 'doPooling', true);

% project onto low-dim subspace
faceDescProj = model.state.W * faceDesc;
