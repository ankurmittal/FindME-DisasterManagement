%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

% configuration file for feature computation
function conf = feat_config(varargin)

prms = struct;
prms.expName = 'dummy';
prms.setName = 'lfw_vj';

prms.trainSettingName = 'unrest';
prms.trainViewName = 'eval';

prms = vl_argparse(prms, varargin);

fprintf('Loading Configuration\n');
conf = [];

conf.rngSeed = 6756;
rng(conf.rngSeed);

familyDir = '../data/';

conf.database.setDir = sprintf('%s/%s/', familyDir, prms.setName);
conf.database.sharedDir = sprintf('%s/shared/', familyDir);

conf.database.dbPath = sprintf('%s/info/database.mat', conf.database.sharedDir);

conf.database.imDir = sprintf('%s/images/', conf.database.setDir);
conf.database.imPath = sprintf('%s/images_preproc/all_img.mat', conf.database.setDir);

% set to true to compute FV on flipped images
conf.compMirrorFeat = false;
% conf.compMirrorFeat = true;

conf.exp.rootDir = sprintf('%s/%s/', conf.database.setDir, prms.expName);
conf.exp.cbookDir = sprintf('%s/codebooks/', conf.exp.rootDir);
conf.exp.dimredDir = sprintf('%s/code_dimred/', conf.exp.rootDir);
conf.exp.featDir = sprintf('%s/features/', conf.exp.rootDir);

% views and settings
conf.exp.training.viewName = prms.trainViewName; 
conf.exp.training.settingName = prms.trainSettingName; 

% dir with the training data: image pairs and image ids for each split
conf.exp.trainDataDir = sprintf('%s/train_data/%s_%s/', conf.database.sharedDir, conf.exp.training.settingName, conf.exp.training.viewName);

% path to image ids
conf.exp.imgIdsPath = sprintf('%s/img_ids.mat', conf.exp.trainDataDir);

%% face descriptor

conf.faceDescriptor = face_desc.lib.face_descriptor.poolFV();

% PCA-SIFT dimensionality
conf.descDim = 64;

% GMM size
conf.vocSize = 512;

end
