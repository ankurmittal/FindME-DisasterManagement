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
        V = model.state.V;
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
            V = trainData.dimredModelInit.proj;
        end
        
        if true
            
            % init b on the train set            
            numTrainBias = 1e3;
            
            % make a subset of train pairs
            rng(obj.rngSeed);
            
            idxBiasTrainPos = posPair(:, randi(nPos, numTrainBias, 1));
            idxBiasTrainNeg = negPair(:, randi(nNeg, numTrainBias, 1));
            
            % pos
            
            featBiasTrain1 = faceFeat(:, idxBiasTrainPos(1, :));
            featBiasTrain2 = faceFeat(:, idxBiasTrainPos(2, :));
            
            featDiff = W * (featBiasTrain1 - featBiasTrain2);
            biasTrainDistPos = 0.5 * sum(featDiff .^ 2, 1) - sum((V * featBiasTrain1) .* (V * featBiasTrain2), 1);
            
            % neg
            
            featBiasTrain1 = faceFeat(:, idxBiasTrainNeg(1, :));
            featBiasTrain2 = faceFeat(:, idxBiasTrainNeg(2, :));
            
            featDiff = W * (featBiasTrain1 - featBiasTrain2);
            biasTrainDistNeg = 0.5 * sum(featDiff .^ 2, 1) - sum((V * featBiasTrain1) .* (V * featBiasTrain2), 1);
            
            % compute bias
            biasTrainAnno = [ones(1, numTrainBias, 'single'), -ones(1, numTrainBias, 'single')];
            
            [~, extra] = face_desc.lib.evaluation.accuracy.eval_best([], -[biasTrainDistPos, biasTrainDistNeg], biasTrainAnno);
            b = -extra.bestThresh;
            
            clear featBiasTrain1;
            clear featBiasTrain2;
        else
            b = 0;
        end       
        
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
        
        maxValPairs = 5e3;
        valData.posPairs = valData.posPairs(:, 1:maxValPairs);
        valData.negPairs = valData.negPairs(:, 1:maxValPairs);
        
        valData.allPairs = [valData.posPairs, valData.negPairs];        
        valData.anno = [ones(1, size(valData.posPairs, 2), 'single'), -ones(1, size(valData.negPairs, 2), 'single')];
        
        % shuffle 
        rng(obj.rngSeed);
        valFeatPerm = randperm(numel(valData.anno));
        
        valData.anno = valData.anno(valFeatPerm);
        valData.allPairs = valData.allPairs(:, valFeatPerm);
        
        % compute val pair feats
        valData.pairFeat = faceFeat(:, valData.allPairs(1, :)) - faceFeat(:, valData.allPairs(2, :));
        
        valData.feat1 = faceFeat(:, valData.allPairs(1, :));
        valData.feat2 = faceFeat(:, valData.allPairs(2, :));
        
        if t0 == 1
            
            eer = get_val_eer(W, V);

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
            feat1 = faceFeat(:, posPair(1, idxPos));
            feat2 = faceFeat(:, posPair(2, idxPos));
            featDiff = feat1 - feat2;
            
            featDiffProj = W * featDiff;
            feat1Proj = V * feat1;
            feat2Proj = V * feat2;
            
            score = 0.5 * norm(featDiffProj) ^ 2 - (feat1Proj' * feat2Proj);
                        
            % update
            if score > b - 1
                W = W - (gamma * featDiffProj) * featDiff';
                V = V + (gamma * feat1Proj) * feat2' + (gamma * feat2Proj) * feat1';
                b = b + gammaBias;
            end
            
        else
            
            % negative sample
            idxNeg = idxNeg + 1;
            
            if idxNeg > nNeg
                idxNeg = 1;
            end
            
            % feature vector
            feat1 = faceFeat(:, negPair(1, idxPos));
            feat2 = faceFeat(:, negPair(2, idxPos));
            featDiff = feat1 - feat2;
            
            featDiffProj = W * featDiff;
            feat1Proj = V * feat1;
            feat2Proj = V * feat2;
            
            score = 0.5 * norm(featDiffProj) ^ 2 - (feat1Proj' * feat2Proj);
            
            % update w
            if score < b + 1
                W = W + (gamma * featDiffProj) * featDiff';
                V = V - (gamma * feat1Proj) * feat2' - (gamma * feat2Proj) * feat1';
                b = b - gammaBias;
            end
            
        end  
        
        
        % log
        if mod(t, obj.logStep) == 0
            
            if doVal
            
                timerTrainEnd = toc(timerTrainStart);
                timerValStart = tic;

                eer = get_val_eer(W, V);

                eerLog = [eerLog, eer];  

                % save model
                model = get_model();
                save(prms.modelPath, 'model');

                timerValEnd = toc(timerValStart);

                if obj.verbose
                    fprintf(fid, 't: %d, eer: %g, time: %.2fs, time_val: %.2fs\n', t, eer, timerTrainEnd, timerValEnd);
                end

                timerTrainStart = tic;
            
            else
                
                timerTrainEnd = toc(timerTrainStart);
                
                % save model
                model = get_model();
                save(prms.modelPath, 'model');
                
                if obj.verbose
                    fprintf(fid, 't: %d, time: %.2fs\n', t, timerTrainEnd);
                end

                timerTrainStart = tic;
                
            end
            
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
        model.state.V = V;
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
    function eer = get_val_eer(W, V)
        
        valFeatsProj = W * valData.pairFeat;    
        valDist = 0.5 * sum(valFeatsProj .^ 2, 1) - sum((V * valData.feat1) .* (V * valData.feat2), 1);
                
        [~,~,info] = vl_roc(valData.anno, -valDist);
        eer = 1 - info.eer;
        
    end
    
    
end
