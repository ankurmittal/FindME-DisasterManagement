%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef PCADimRed < handle
    %PCADimRed Learns descriptor dimensionality reduction using PCA
    
    properties
        dim % target dimensionality
        do_whitening % true if whitening is done after PCA
    end
    
    methods
        function obj = PCADimRed(dim)
            
            obj.dim = dim;            
            obj.do_whitening = false;
        end
        
        [lin_trans pca_data] = train(obj, varargin)
    end
    
end

