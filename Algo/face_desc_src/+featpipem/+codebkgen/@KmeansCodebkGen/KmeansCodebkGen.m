%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef KmeansCodebkGen < handle
    %KMEANSCODEBKGEN Generate codebook of visual words using kmeans
    
    properties
        cluster_count % number of visual words in a codebook
        rand_seed
    end
    
    methods
        function obj = KmeansCodebkGen(cluster_count)
            
            obj.cluster_count = cluster_count;
            obj.rand_seed = 2215;
        end
        
        codebook = train(obj, varargin)
    end
    
end
