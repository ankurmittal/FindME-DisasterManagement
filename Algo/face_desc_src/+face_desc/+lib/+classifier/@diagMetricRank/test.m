%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function scores = test(obj, model, feat1, feat2)

    % squared difference feature
    testFeats = (feat1 - feat2) .^ 2;
    
    % compute test scores
    scores = -model.state.w' * testFeats;

end
