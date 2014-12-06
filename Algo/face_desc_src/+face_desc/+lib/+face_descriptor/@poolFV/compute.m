%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function desc = compute(obj, faceImg, varargin)

    prms.doPooling = true;
    prms.doMirror = false;
            
    [prms, ~] = vl_argparse(prms, varargin);
    
    faceImg = im2single(faceImg);
    
    %% compute descriptor
    
    % horizontal reflection
    if prms.doMirror
        faceImg = flipdim(faceImg, 2);
    end
    
    % compute DSIFT
    [feats, frames] = obj.featextr.compute(faceImg);
    
    if prms.doPooling
        % return FV encoding
        desc = obj.encoder.encode(feats);
    else
        % return dense features
        desc = feats;
    end
    
end
