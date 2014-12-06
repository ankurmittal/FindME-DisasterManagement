%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function scores = test_model(config, testData, feats, featsMirr, model)

    numPairs = size(testData.pairs, 2);
        
    scores = zeros(1, numPairs, 'single');
    
    % test pairs loop
    for iPair = 1:numPairs
        
        idx1 = testData.pairs(1, iPair);
        idx2 = testData.pairs(2, iPair);
        
        pairScore = [];
        
        % compute scores for reflected pairs
        pairScore(end + 1) = config.class.test(model, feats(:, idx1), feats(:, idx2));
        
        % mirror
        if ~isempty(featsMirr)
                        
            pairScore(end + 1) = config.class.test(model, feats(:, idx1), featsMirr(:, idx2));            
            pairScore(end + 1) = config.class.test(model, featsMirr(:, idx1), feats(:, idx2));            
            pairScore(end + 1) = config.class.test(model, featsMirr(:, idx1), featsMirr(:, idx2));
        end
        
        scores(:, iPair) = mean(pairScore);
    end


end
