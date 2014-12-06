%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script computes train/test/val pairs and image ids for each split in the restricted setting
clear;

% cut-out numVal pos and numVal neg pairs as the validation set (for bias re-estimation)            
numVal = 100;

config = face_desc.config.learn_config('trainSettingName', 'rest');

resDir = config.exp.trainDataDir;

% load pre-set restricted training & testing pairs
load(sprintf('%s/info/rest_pairs.mat', config.database.sharedDir), 'restSplits');

numSplits = numel(restSplits);
imgIds = cell(1, numSplits);

%%
parfor idxSplit = 1:numSplits
    
    % training indices for this fold
    idx = 1:numSplits;
    idx(idxSplit) = [];
    
    % all training image pairs
    trainPosPairs = cat(2, restSplits(idx).posPairs);
    trainNegPairs = cat(2, restSplits(idx).negPairs);
    
    % training image indices
    imgIds{idxSplit} = unique([trainPosPairs(:); trainNegPairs(:)]);
    
    % split train into train & val
    valData(idxSplit).posPairs = trainPosPairs(:, 1:numVal);
    valData(idxSplit).negPairs = trainNegPairs(:, 1:numVal);
    
    trainData(idxSplit).posPairs = trainPosPairs(:, numVal+1:end);
    trainData(idxSplit).negPairs = trainNegPairs(:, numVal+1:end);
    
    % test data    
    testData(idxSplit).pairs = cat(2, restSplits(idxSplit).posPairs, restSplits(idxSplit).negPairs);
    
    testData(idxSplit).anno = cat(2, ones(1, size(restSplits(idxSplit).posPairs, 2)), ...
        -ones(1, size(restSplits(idxSplit).negPairs, 2)));    
    
end

%% save
ensure_dir(resDir);

imgIdsPath = sprintf('%s/img_ids.mat', resDir);
save(imgIdsPath, 'imgIds');

trainPairsPath = sprintf('%s/pairs_train.mat', resDir);
save(trainPairsPath, 'trainData');

valPairsPath = sprintf('%s/pairs_val.mat', resDir);
save(valPairsPath, 'valData');

testPairsPath = sprintf('%s/pairs_test.mat', resDir);
save(testPairsPath, 'testData');
