%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

% configuration file for metric learning
function conf = learn_config(varargin)

prms = struct;

% experiment name
prms.expName = 'dummy';

% set name ('lfw_aligned', 'lfw_vj', or 'lfw_funneled')
prms.setName = 'lfw_vj';

% initialise with unrestricted set-up (train: unrest, test: rest)
% training setting and view
prms.trainSettingName = 'unrest';
prms.trainViewName = 'eval';

% testing setting and view
prms.testSettingName = 'rest';
prms.testViewName = 'eval';

% face verification model ('metric', 'metric_sim', 'diag_metric')
prms.modelType = 'metric';

% descriptor name: 'poolfv' - Fisher vector; 'poolfv_proj' - projected Fisher vector
prms.descName = 'poolfv';

% if true, uses horizontal image flipping for test set augmentation
prms.useMirrorFeat = false;

prms = vl_argparse(prms, varargin);

conf = [];

conf.rngSeed = 6756;
rng(conf.rngSeed);

conf.descName = prms.descName;

%% 

conf.noclobberScores = true;
conf.noclobberModels = true;

familyDir = '../data/';

conf.database.setDir = sprintf('%s/%s/', familyDir, prms.setName);
conf.database.sharedDir = sprintf('%s/shared/', familyDir);

conf.useMirrorFeat = prms.useMirrorFeat;

%% evaluation measure settings
conf.exp.eval(1).name = 'ap';

conf.exp.eval(2).name = 'roc';

conf.exp.eval(3).name = 'accuracy';
conf.exp.eval(3).threshold = 0;

%% 

% views and settings
conf.exp.training.viewName = prms.trainViewName; 
conf.exp.training.settingName = prms.trainSettingName; 

conf.exp.testing.viewName = prms.testViewName; 
conf.exp.testing.settingName = prms.testSettingName; 

% dir with image pairs, split image ids, and other (shared) training data
conf.exp.trainDataDir = sprintf('%s/train_data/%s_%s/', conf.database.sharedDir, conf.exp.training.settingName, conf.exp.training.viewName);

% path to image ids
conf.exp.imgIdsPath = sprintf('%s/img_ids.mat', conf.exp.trainDataDir);

% paths to training & validation pairs
conf.exp.trainPairsPath = sprintf('%s/pairs_train.mat', conf.exp.trainDataDir);
conf.exp.valPairsPath = sprintf('%s/pairs_val.mat', conf.exp.trainDataDir);
conf.exp.testPairsPath = sprintf('%s/pairs_test.mat', conf.exp.trainDataDir);

% number of splits
conf.numSplits = 1;

%% classifier instance

switch prms.modelType
    
    case 'metric'
        
        % target dimensionality
        conf.exp.dimredFeatDim = 128;
        
        % verification model
        conf.class = face_desc.lib.classifier.dimredClassUnreg(conf.exp.dimredFeatDim);
                
        % init-n method
        conf.exp.dimredMethodInit = 'PCAW';
        
    case 'metric_sim'
        
        % target dimensionality for each of the two projections
        conf.exp.dimredFeatDim = 128;
        
        % verification model
        conf.class = face_desc.lib.classifier.dimredJointClassUnreg(conf.exp.dimredFeatDim);
        
        % initialisation method
        conf.exp.dimredMethodInit = 'PCAW';
        
    case 'diag_metric'
        
        % diagonal metric
        conf.class = face_desc.lib.classifier.diagMetricRank();
                
        conf.exp.dimredMethodInit = 'none';
        conf.exp.dimredFeatDim = [];
        
    case 'L2'
        
        % Euclidean distance
        conf.class = face_desc.lib.classifier.L2();
        
        conf.exp.dimredMethodInit = 'none';
        conf.exp.dimredFeatDim = [];
end

%% dirs
conf.exp.name = prms.expName;
conf.exp.rootDir = sprintf('%s/%s/', conf.database.setDir, conf.exp.name);
conf.exp.featDir = sprintf('%s/features/', conf.exp.rootDir);
conf.exp.modelDir = sprintf('%s/models/', conf.exp.rootDir);
conf.exp.dimredDir = sprintf('%s/code_dimred/', conf.exp.rootDir);

% descriptor paths;
% each split is stored separately
for iSplit = 1:conf.numSplits
    
    conf.exp.descPath{iSplit} = sprintf('%s/%s/%d/', conf.exp.featDir, conf.descName, iSplit);
    conf.exp.descPathMirr{iSplit} = sprintf('%s/%s_mirr/%d/', conf.exp.featDir, conf.descName, iSplit);
end

end
