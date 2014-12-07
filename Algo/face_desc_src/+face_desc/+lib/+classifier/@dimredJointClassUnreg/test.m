%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function scores = test(obj, model, feat1, feat2)

    W = model.state.W;
    V = model.state.V;
    b = model.state.b;
    
    featDiffProj = W * (feat1 - feat2);
    feat1Proj = V * feat1;
    feat2Proj = V * feat2;
    
    dist = 0.5 * norm(featDiffProj) ^ 2 - (feat1Proj' * feat2Proj);
    
    % >=0 => match
    scores = b - dist;

end
