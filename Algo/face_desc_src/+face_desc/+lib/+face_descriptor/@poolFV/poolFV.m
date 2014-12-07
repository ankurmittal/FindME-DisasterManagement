%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef poolFV < handle
    
    properties        
        featextr
        encoder        
    end
    
    methods
        
        function obj = poolFV(varargin)                        
            
            % DSIFT extractor
            obj.featextr = featpipem.features.IterDSiftExtractor();
            
            % FV encoder
            obj.encoder = [];
        end
        
        desc = compute(obj, img, varargin)
                        
        function name = get_name(obj)
            
            name = 'poolfv';
        end
        
        function set_feat_proj(obj, lin_trans)
            obj.featextr.lin_trans = lin_trans;
        end
        
        function set_codebook(obj, codebook)
            
            % encoder
            obj.encoder = featpipem.encoding.FKEncoder(codebook);
        end
        
        function dim = get_dim(obj)            
            
            dim = obj.encoder.get_output_dim();
        end
        
    end
    
end
