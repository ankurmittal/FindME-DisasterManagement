%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function execute(config, trainData, testData, valData, feats, featsMirr, outPaths)
% execute a single experiment

confExp = config.exp;

dimredPathInit = outPaths.dimredPathInit;
modelPath = outPaths.modelPath;
logPath = outPaths.logPath;
scorePath = outPaths.scorePath;

% check if scores are already computed
if config.noclobberScores && exist(scorePath, 'file')
    return;
end

%% dimred init-n
if ~isequal(confExp.dimredMethodInit, 'none')
    trainData.dimredModelInit = load(dimredPathInit);    
else
    trainData.dimredModelInit = [];
end

%% train model

trainData.feats = feats;

model = config.class.train(trainData, valData, 'modelPath', modelPath, 'logPath', logPath);

%% test model
if ~(config.noclobberScores && exist(scorePath, 'file'))

    % test on the test set
    scores = face_desc.manager.learn.test_model(config, testData, feats, featsMirr, model);
    
    if ~isempty(valData)
        % re-estimate the bias on val data
        
        % test on the val set
        valData.pairs = [valData.posPairs, valData.negPairs];        
        valData.anno = [ones(1, size(valData.posPairs, 2), 'single'), -ones(1, size(valData.negPairs, 2), 'single')];

        scoresVal = face_desc.manager.learn.test_model(config, valData, feats, featsMirr, model);
        
        % find a threshold on the val set
        [~, extra] = face_desc.lib.evaluation.accuracy.eval_best([], reshape(scoresVal, 1, []), valData.anno);
                
        % adjust the scores w.r.t. the new threshold
        scoresThresh = scores - extra.bestThresh;
        
        save(scorePath, 'scores', 'scoresThresh');
    else
        scoresThresh = scores;
        save(scorePath, 'scores', 'scoresThresh');
    end
    
end

end
