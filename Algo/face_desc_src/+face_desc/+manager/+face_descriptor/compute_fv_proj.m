%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script computes projected FV features based on pre-computed FV features and discriminatively learnt projections
clear;

run('./startup.m');

% settings
setName = 'lfw_vj';
expName = 'SIFT_1pix_PCA64_GMM512';
gamma = 0.25;
gammaBias = 1;

% setName = 'lfw_vj';
% expName = 'SIFT_1pix_PCA64_GMM512';
% gamma = 0.25;
% gammaBias = 10;

%% project FV features of both original and flipped images
for useMirrorFeat = [false, true]

    % config for FV features
    config = face_desc.config.learn_config('expName', expName, 'setName', setName, 'modelType', 'metric', 'useMirrorFeat', useMirrorFeat, 'descName', 'poolfv');

    config.class.gamma = gamma;
    config.class.gammaBias = gammaBias;

    % config for projected FV features
    configProj = face_desc.config.learn_config('expName', expName, 'setName', setName, 'modelType', 'metric', 'useMirrorFeat', useMirrorFeat, 'descName', 'poolfv_proj');

    %% loop over splits
    parfor idxSplit = 1:config.numSplits

        % load FV features
        if config.useMirrorFeat
            featDir = config.exp.descPathMirr{idxSplit};
        else
            featDir = config.exp.descPath{idxSplit};
        end

        feats = featpipem.chunkio.loadChunksIntoMat('chunk_dir', featDir);        

        % load projection
        outPaths = face_desc.manager.learn.get_output_paths(config, idxSplit);

        proj = load(outPaths.modelPath, 'model');
        W = proj.model.state.W;

        % project features
        feats = W * feats;

        % save projected features
        if config.useMirrorFeat
            featProjDir = configProj.exp.descPathMirr{idxSplit};
        else
            featProjDir = configProj.exp.descPath{idxSplit};
        end

        ensure_dir(featProjDir);    
        featpipem.chunkio.saveMatToChunks(featProjDir, feats);    
    end
    
end
