%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef diagMetricRank < handle

    properties
        numIter
        lambda
        rngSeed        
    end
    
    methods
        
        function obj = diagMetricRank()
            
            obj.numIter = 1e6;
            obj.lambda = 1e-7;
            obj.rngSeed = 6756;            
        end
        
        model = train(obj, trainData, valData, varargin)
                
        scores = test(obj, model, feat1, feat2)
        
        function modelName = get_model_name_short(obj)
            
            modelName = sprintf('l%g', obj.lambda);
        end
        
        function modelName = get_model_name_long(obj)
            modelName = sprintf('lambda=%g, iterations=%g', obj.lambda, obj.numIter);
        end
        
        % classifier name
        function name = get_name(obj)
            
            name = 'diag_metric_rank';           
            
        end
        
        % set classifier params
        function set_params(obj, prms)
            obj.lambda = prms(1);
        end
        
    end

end
