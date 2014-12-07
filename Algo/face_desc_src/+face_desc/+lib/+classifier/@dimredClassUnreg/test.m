%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function scores = test(obj, model, feat1, feat2)

    W = model.state.W;
    b = model.state.b;
    
    % project
    testFeats = W * (feat1 - feat2);
    
    % distance
    dist = sum(testFeats .^ 2, 1);
    
    % >=0 => match
    scores = b - dist;

end
