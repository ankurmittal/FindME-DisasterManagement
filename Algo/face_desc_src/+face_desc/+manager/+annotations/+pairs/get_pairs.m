%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function [posPair, negPair] = get_pairs(names, varargin)

    prms.rngSeed = 6756;
    prms.numPairs = 1e6;
    
    prms = vl_argparse(prms, varargin);

    % make positive & negative pairs
    numNames = numel(names);
    
    % number of images for each person
    numImg = zeros(numNames, 1);
    
    for iName = 1:numNames
        numImg(iName) = numel(names(iName).imgIds);
    end
    
    % can make positives with them
    idxPosNames = find(numImg > 1);
    
    rng(prms.rngSeed);
    
    % indices of people used in pos pairs
    idxPos = randi([1 numel(idxPosNames)], prms.numPairs, 1);
    idxPos = idxPosNames(idxPos);
    
    posPair = zeros(2, prms.numPairs, 'single');
    negPair = zeros(2, prms.numPairs, 'single');
    
    for i = 1:prms.numPairs
        
        % pos pair
        idxPosPair = idxPos(i);
        imgPerm = randperm(numImg(idxPosPair));
        
        posPair(:, i) = names(idxPosPair).imgIds(imgPerm(1:2));
        
        % neg pair
        negPair(1, i) = posPair(1, i);
        
        % pick another person
        while true
            idxNegPair = randi(numNames);
            
            if idxNegPair ~= idxPosPair
                break;
            end
        end
        
        idxNegImg = randi(numImg(idxNegPair));
        negPair(2, i) = names(idxNegPair).imgIds(idxNegImg);
        
    end
    
end
