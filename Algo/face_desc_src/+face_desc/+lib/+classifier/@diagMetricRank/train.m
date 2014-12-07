%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function model = train(obj, trainData, valData, varargin)

    prms = struct;
    prms.modelPath = [];
    prms.logPath = [];
    
    prms = vl_argparse(prms, varargin);
    
    if exist(prms.modelPath, 'file')
        load(prms.modelPath, 'model');
        return;
    end

    trainFeatsPos = ( trainData.feats(:, trainData.posPairs(1, :)) - trainData.feats(:, trainData.posPairs(2, :)) ) .^ 2;
    trainFeatsNeg = ( trainData.feats(:, trainData.negPairs(1, :)) - trainData.feats(:, trainData.negPairs(2, :)) ) .^ 2;
    
    featDim = size(trainData.feats, 1);
    lambda = obj.lambda;
        
    w = zeros(featDim, 1, 'single');
    
    % sets of positives & negatives
    nPos = size(trainData.posPairs, 2);    
    nNeg = size(trainData.negPairs, 2);    
        
    rng(obj.rngSeed);
    
    % positive & negative pairs for each iteration
    idxPos = randi([1 nPos], obj.numIter, 1);
    idxNeg = randi([1 nNeg], obj.numIter, 1);
        
    for t = 1:obj.numIter
        
        % learning rate
        gamma = 1 / (lambda * t);
        
        % feature vector
        feat = trainFeatsPos(:, idxPos(t)) - trainFeatsNeg(:, idxNeg(t));
        
        % update w
        if w' * feat > -1
            w = w * (1 - gamma * lambda) - gamma * feat;
        else
            w = w * (1 - gamma * lambda);
        end
        
    end
    
    % save learnt model     
    model = struct;
    
    % current state
    model.state.w = w;
    model.state.t = t;
        
    % params
    model.params.lambda = lambda;
        
    % save
    save(prms.modelPath, 'model');
    
end
