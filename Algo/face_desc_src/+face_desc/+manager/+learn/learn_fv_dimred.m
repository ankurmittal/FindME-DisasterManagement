%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

run('./startup.m');

conf = face_desc.config.learn_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);

% number of splits
load(conf.exp.imgIdsPath, 'imgIds');
numSplits = numel(imgIds);

% FV dimensionality reduction params
dimredMethod = conf.exp.dimredMethodInit;
codeDim = conf.exp.dimredFeatDim;

%% split loop
parfor_progress(length(numSplits))
parfor idxSplit = 1:numSplits
% for idxSplit = 1:numSplits
    parfor_progress;
    dimredDir = sprintf('%s/%d/', conf.exp.dimredDir, idxSplit);
    featDir = sprintf('%s/%s/%d/', conf.exp.featDir, conf.descName, idxSplit);
    dimredPath = sprintf('%s/%s_%d.mat', dimredDir, dimredMethod, codeDim);
    dimredDataPath = sprintf('%s/PCA_data.mat', dimredDir);

    if exist(dimredPath, 'file')
        continue;
    end

    ensure_dir(dimredDir);

    %% compute PCA-whitening
    dimred = featpipem.dim_red.PCADimRed(codeDim);
    
    if isequal(dimredMethod, 'PCAW')
        dimred.do_whitening = true;
    end
    
    if exist(dimredDataPath, 'file')
        dimredData = load(dimredDataPath);
        [linTrans, dimredData] = dimred.train('pca_data', dimredData);
    else
        % load FVs
        samples = featpipem.chunkio.loadChunksIntoMat('chunk_dir', featDir);
        samples = samples(:, imgIds{idxSplit});

        [linTrans, dimredData] = dimred.train('feats', samples);
        
        % save
        save_struct(dimredDataPath, dimredData);
    end

    %% save
    save_struct(dimredPath, linTrans);

end
