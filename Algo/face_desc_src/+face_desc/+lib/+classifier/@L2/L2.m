%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef L2 < handle

    properties        
    end
    
    methods
        
        function obj = L2()
        end
        
        % no training
        function model = train(obj, trainData, valData, varargin)
            model = [];
        end
        
        % unsupervised L2 distance
        function scores = test(obj, model, feat1, feat2)
            scores = -sum((feat1 - feat2) .^ 2, 1);
        end            
        
        function modelName = get_model_name_short(obj)            
            modelName = 'L2';
        end
        
        function modelName = get_model_name_long(obj)
            modelName = sprintf('L2');
        end
        
        % classifier name
        function name = get_name(obj)
            
            name = 'L2';            
        end
        
        % set classifier params
        function set_params(obj, prms)
        end
        
    end

end
