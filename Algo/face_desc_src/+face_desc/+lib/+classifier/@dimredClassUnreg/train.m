%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function model = train(obj, trainData, valData, varargin)

    prms = struct;
    prms.modelPath = [];
    prms.logPath = [];
    
    prms = vl_argparse(prms, varargin);
    
    % face features
    faceFeat = trainData.feats;
    
    posPair = trainData.posPairs;
    negPair = trainData.negPairs;
    
    % FV dim
    featDim = size(faceFeat, 1);
        
    % projected FV dim
    lowFeatDim = obj.targetDim;
    
    % learning rates
    gamma = obj.gamma;    
    gammaBias = obj.gammaBias;  
    
    nPos = size(posPair, 2);
    nNeg = size(negPair, 2);
    
    % prep validation
    doVal = ~isempty(valData);
    
    % init
    if exist(prms.modelPath, 'file')
        
        % load current model
        load(prms.modelPath, 'model');
        
        t0 = model.state.t + 1;
        idxPos = model.state.idxPos;
        idxNeg = model.state.idxNeg;
                
        if t0 > obj.numIter
            return;
        end
        
        W = model.state.W;
        b = model.state.b;
        
        if doVal
            eerLog = model.state.eerLog;
        end        
        
    else
        
        t0 = 1;
        idxPos = 0;
        idxNeg = 0;
        
        if isempty(trainData.dimredModelInit)
            W = randn(lowFeatDim, featDim, 'single');            
        else
            W = trainData.dimredModelInit.proj;
        end
        
        % init b on the train set            
        numTrainBias = 1e3;
        
        % make a subset of train pairs
        rng(obj.rngSeed);
        
        idxBiasTrainPos = posPair(:, randi(nPos, numTrainBias, 1));
        idxBiasTrainNeg = negPair(:, randi(nNeg, numTrainBias, 1));
        
        featDiff = W * (faceFeat(:, idxBiasTrainPos(1, :)) - faceFeat(:, idxBiasTrainPos(2, :)));
        biasTrainDistPos = sum(featDiff .^ 2, 1);
        
        featDiff = W * (faceFeat(:, idxBiasTrainNeg(1, :)) - faceFeat(:, idxBiasTrainNeg(2, :)));
        biasTrainDistNeg = sum(featDiff .^ 2, 1);
        
        biasTrainAnno = [ones(1, numTrainBias, 'single'), -ones(1, numTrainBias, 'single')];
        
        [~, extra] = face_desc.lib.evaluation.accuracy.eval_best([], -[biasTrainDistPos, biasTrainDistNeg], biasTrainAnno);
        b = -extra.bestThresh;
        
    end
    
    % log
    if isempty(prms.logPath)
        fid = 1;
    else
        fid = fopen(prms.logPath, 'a');
    end
    
    if obj.verbose
        fprintf(fid, 'Starting from t=%d\n', t0);
    end
    
    % load validation data
    if doVal
        
        valData.allPairs = [valData.posPairs, valData.negPairs];        
        valData.anno = [ones(1, size(valData.posPairs, 2), 'single'), -ones(1, size(valData.negPairs, 2), 'single')];
        
        % shuffle 
        rng(obj.rngSeed);
        valFeatPerm = randperm(numel(valData.anno));
        
        valData.anno = valData.anno(valFeatPerm);
        valData.allPairs = valData.allPairs(:, valFeatPerm);
        
        % compute val pair feats
        valData.pairFeat = faceFeat(:, valData.allPairs(1, :)) - faceFeat(:, valData.allPairs(2, :));
        
        if t0 == 1
            
            eer = get_val_eer(W);

            eerLog = eer;

            if obj.verbose
                fprintf(fid, 't: %d, eer: %g, time: %gs\n', 0, eer, 0);
            end
        end
    end
    
    timerTrainStart = tic;    
    
    % SGD iterations
    for t = t0:obj.numIter
        
        if mod(t, 2) == 1            
           
            % positive sample
            idxPos = idxPos + 1;
            
            if idxPos > nPos
                idxPos = 1;
            end
            
            % feature vector
            featDiff = faceFeat(:, posPair(1, idxPos)) - faceFeat(:, posPair(2, idxPos));
            featDiffProj = W * featDiff;
                        
            % update
            if norm(featDiffProj) ^ 2 > b - 1
                W = W - (gamma * featDiffProj) * featDiff';
                b = b + gammaBias;
            end
            
        else
            
            % negative sample
            idxNeg = idxNeg + 1;
            
            if idxNeg > nNeg
                idxNeg = 1;
            end
            
            % feature vector
            featDiff = faceFeat(:, negPair(1, idxNeg)) - faceFeat(:, negPair(2, idxNeg));
            featDiffProj = W * featDiff;
            
            % update w
            if norm(featDiffProj) ^ 2 < b + 1
                W = W + (gamma * featDiffProj) * featDiff';
                b = b - gammaBias;
            end
            
        end  
        
        
        % log
        if doVal && mod(t, obj.logStep) == 0
            
            timerTrainEnd = toc(timerTrainStart);
            timerValStart = tic;
            
            eer = get_val_eer(W);
            
            eerLog = [eerLog, eer];  
            
            % save model
            model = get_model();
            save(prms.modelPath, 'model');
            
            timerValEnd = toc(timerValStart);
                        
            if obj.verbose
                fprintf(fid, 't: %d, eer: %g, time: %.2fs, time_val: %.2fs\n', t, eer, timerTrainEnd, timerValEnd);
            end
            
            timerTrainStart = tic;
            
        end 
           
    end
    
    % close log
    if fid ~= 1
        fclose(fid);
    end
    
    % current state
    function model = get_model()
        
        model = struct;
        
        % current state
        model.state.W = W;
        model.state.b = b;
        
        model.state.t = t;
        model.state.idxPos = idxPos;
        model.state.idxNeg = idxNeg;
        
        % params
        model.params.gamma = gamma;
        model.params.gammaBias = gammaBias;
        
        if doVal
            model.state.eerLog = eerLog;
        end
    end

    % val eer
    function eer = get_val_eer(W)
        
        valFeatsProj = W * valData.pairFeat;    
        valDist = sum(valFeatsProj .^ 2, 1);
                
        [~,~,info] = vl_roc(valData.anno, -valDist);
        eer = 1 - info.eer;
        
    end
    
    
end
