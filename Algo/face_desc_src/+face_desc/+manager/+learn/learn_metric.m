%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

%% this script runs FV metric learning
run('./startup.m');

config = face_desc.config.learn_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName, ...
    'modelType', modelType, 'useMirrorFeat', useMirrorFeat, 'descName', descName);

% number of train-test splits
numSplits = config.numSplits;

% number of evaluation measures
numMeasures = numel(config.exp.eval);

% train the models
runTraining = true;

% print results for each split
printSplitRes = true;

% use the scores obtained with the bias (b) re-estimated on the val set
useValBias = true;
    
%% classifier hyper-parameters

% classifier class
className = class(config.class);

% set-up learner-specific grids of hyper-parameters
switch className
    
    case 'face_desc.lib.classifier.dimredClassUnreg'
        
        [gammaSet gammaBiasSet] = ndgrid(gammaSet, gammaBiasSet);

        hyperParams = [gammaSet(:), gammaBiasSet(:)];
        
    case 'face_desc.lib.classifier.dimredJointClassUnreg'
        
        [gammaSet gammaBiasSet] = ndgrid(gammaSet, gammaBiasSet);

        hyperParams = [gammaSet(:), gammaBiasSet(:)];
        
    case 'face_desc.lib.classifier.diagMetricRank'
        
        hyperParams = lambdaSet(:);
        
    case 'face_desc.lib.classifier.L2'
        
        hyperParams = NaN;
        
    otherwise
        hyperParams = [];
        
end

numHyperParams = size(hyperParams, 1);

%% run training-testing (score computation)
if runTraining
    
    % splits - hyperparameters combinations
    [idxSplitSet, idxHyperSet] = ndgrid(1:numSplits, 1:numHyperParams);
%     [idxSplitSet, idxHyperSet] = ndgrid(1, 1:numHyperParams);
    
    idxSplitSet = idxSplitSet(:);
    idxHyperSet = idxHyperSet(:);
    
    numWorkers = max(1, matlabpool('size'));
    
    numExp = numel(idxHyperSet);
        
    % prep experiments' settings
    expSettings = cell(1, numWorkers);
    
    for idxWorker = 1:numWorkers
        
        idxExpSet = idxWorker:numWorkers:numExp;
        
        for k = 1:numel(idxExpSet)
            
            idxSplit = idxSplitSet(idxExpSet(k));
            idxHyper = idxHyperSet(idxExpSet(k));
            
            expSettings{idxWorker}(k).idxSplit = idxSplit;
            expSettings{idxWorker}(k).hyperParams = hyperParams(idxHyper, :);
        end
    end
    
parfor_progress(length(numWorkers))
% for idxSplit = 1:numSplits
 
    % worker loop
 	 parfor idxWorker = 1:numWorkers
% By udit 
   %for idxWorker = 1:numWorkers
    	parfor_progress;
        
        % run several experiments on the worker
        face_desc.manager.learn.execute_experiments(config, expSettings{idxWorker});        
        
    end
end

%% run evaluation

% load test data
load(config.exp.testPairsPath, 'testData');

valMeasure = zeros(numHyperParams, numSplits, 'single');
acc = zeros(numHyperParams, numSplits, 'single');

% hyper-params loop
for idxHyper = 1:numHyperParams
    
    % set params
    config.class.set_params(hyperParams(idxHyper, :));
    
    % evaluation measures for each split
    splitRes = cell(numSplits, 1);
    
    fprintf('%s\n', config.class.get_model_name_long());
    
    % compute measures for each split
    for idxSplit = 1:numSplits
%     for idxSplit = 1
        
        % get split-specific model paths
        outPaths = face_desc.manager.learn.get_output_paths(config, idxSplit);
        
        % load pair scores
        if useValBias
            % scores thresholded using bias learnt on the val set
            load(outPaths.scorePath, 'scoresThresh');
            scores = scoresThresh;
        else
            % scores thresholded using bias learnt on the train set
            load(outPaths.scorePath, 'scores');
        end
        
        % evaluate the results
        splitRes{idxSplit} = face_desc.manager.evaluation.evaluate(config, scores, testData(idxSplit).anno);
        
        % print results for the split
        if printSplitRes
            
            fprintf('[Split %d]\t', idxSplit);
            
            for idxMeasure = 1:numMeasures
                
                curRes = splitRes{idxSplit}(idxMeasure);
                fprintf('%s: %.1f, ', curRes.meas_name, curRes.measure);
            end
            
            fprintf('\n');
        end        
        
    end
    
    % numSplits x numMeasures struct array
    result = cat(1, splitRes{:});
    
    % print results over all splits
    fprintf('[Total]\t');
    
    for idxMeasure = 1:numMeasures
        
        % measure mean & variance across splits
        curRes = [result(:, idxMeasure).measure];
        fprintf('%s: %.2f+-%.2f, ', config.exp.eval(idxMeasure).name, mean(curRes), std(curRes));
    end
    
    fprintf('\n');
    
end
