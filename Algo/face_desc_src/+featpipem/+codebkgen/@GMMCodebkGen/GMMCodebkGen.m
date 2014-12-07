%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef GMMCodebkGen < handle
    %GMMCodebkGen Generate codebook of visual words using GMM
    
    properties
        cluster_count % number of visual words in a codebook
    end
    
    methods
        function obj = GMMCodebkGen(cluster_count)
            obj.cluster_count = cluster_count;
        end
        
        codebook = train(obj, varargin)
    end
    
end

