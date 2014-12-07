%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function execute_experiments(config, expSettings)
% execute a set of experiments

numExp = numel(expSettings);

%% arrange experiments in the split ascending order (to avoid re-loading split-specific features)
[~, sortIdx] = sort([expSettings.idxSplit], 'ascend');
expSettings = expSettings(sortIdx);

%% check if the scores are already computed for all experiments
if config.noclobberScores
    allLearnt = true;

    for idxExp = 1:numExp

        idxSplit = expSettings(idxExp).idxSplit;
        hyperParams = expSettings(idxExp).hyperParams;

        % set params
        config.class.set_params(hyperParams);        

        % get split-specific score paths
        outPaths = face_desc.manager.learn.get_output_paths(config, idxSplit);

        if ~exist(outPaths.scorePath, 'file')
            allLearnt = false;
            break;
        end
    end

    if allLearnt
        return;
    end
end

%% load train/test/val pairs
load(config.exp.trainPairsPath, 'trainData');
load(config.exp.valPairsPath, 'valData');
load(config.exp.testPairsPath, 'testData');

%% run experiments
for idxExp = 1:numExp
    
    idxSplit = expSettings(idxExp).idxSplit;
    hyperParams = expSettings(idxExp).hyperParams;
    
    % load split-specific features
    
    % check if the split is the same as at previous iteration => no need to re-load
    if ~(idxExp > 1 && idxSplit == expSettings(idxExp - 1).idxSplit)
    
        feats = featpipem.chunkio.loadChunksIntoMat('chunk_dir', config.exp.descPath{idxSplit});

        % also load features of the flipped images
        if config.useMirrorFeat            
            featsMirr = featpipem.chunkio.loadChunksIntoMat('chunk_dir', config.exp.descPathMirr{idxSplit});
        else
            featsMirr = [];
        end
    end

    % set params
    config.class.set_params(hyperParams);        
    
    % get split-specific model paths
    outPaths = face_desc.manager.learn.get_output_paths(config, idxSplit);

    % run the pipeline for the current experiment
    face_desc.manager.learn.execute(config, trainData(idxSplit), testData(idxSplit), valData(idxSplit), feats, featsMirr, outPaths);
end

end
