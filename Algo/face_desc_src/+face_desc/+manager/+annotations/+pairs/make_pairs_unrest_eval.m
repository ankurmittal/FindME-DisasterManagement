%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script computes train/val pairs and image ids for each split in the unrestricted setting, evaluation View2
clear;

run('./startup.m');

config = face_desc.config.learn_config('trainSettingName', 'unrest');

resDir = config.exp.trainDataDir;

load(sprintf('%s/info/unrest_names.mat', config.database.sharedDir), 'nameInfo');

rngSeed = 6756;

% 10% images used for validation pairs
valCutOffRatio = 0.1;

% make training or validation image pairs 
% makeTrain = true;
makeTrain = false;

if makeTrain
    % number of pairs
    numPairs = 4e6;
    
    pairsPath = sprintf('%s/pairs_train.mat', resDir);
else
    % val
    numPairs = 10e3;
    
    pairsPath = sprintf('%s/pairs_val.mat', resDir);
end

ensure_dir(resDir);
idsPath = sprintf('%s/img_ids.mat', resDir);

numSplits = numel(nameInfo);

posPairs = cell(1, numSplits);
negPairs = cell(1, numSplits);
imgIds = cell(1, numSplits);

% for idxSplit = 1:numSplits
parfor idxSplit = 1:numSplits

    idxTrainSplits = 1:numSplits;
    idxTrainSplits(idxSplit) = [];
        
    names = cat(2, nameInfo(idxTrainSplits).names);
    
    imgIds{idxSplit} = [names.imgIds];
    
    rng(rngSeed);
    
    numNames = numel(names);
    
    namesPerm = randperm(numNames);
    cutOff = round(numNames * valCutOffRatio);
    
    if makeTrain
        names = names(namesPerm(cutOff + 1 : end));
    else
        names = names(namesPerm(1:cutOff));
    end
    
    [posPairsSplit, negPairsSplit] = face_desc.manager.annotations.pairs.get_pairs(names, 'numPairs', numPairs, 'rngSeed', rngSeed);
    
    trainData(idxSplit).posPairs = posPairsSplit;
    trainData(idxSplit).negPairs = negPairsSplit;
end

%% save

if ~makeTrain
    valData = trainData;
    save(pairsPath, 'valData');
end

if ~exist(idsPath, 'file')
    save(idsPath, 'imgIds');
end
