%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

classdef dimredClassUnreg < handle

    properties
        numIter
        gamma
        gammaBias
        rngSeed
        logStep
        verbose
        targetDim        
    end
    
    methods
        
        function obj = dimredClassUnreg(targetDim)
            
            obj.numIter = 1e6;

            obj.gamma = 1;
            obj.gammaBias = 0;
            obj.rngSeed = 6756;
            obj.logStep = 20e3;
            obj.verbose = true;  
            obj.targetDim = targetDim;
        end
        
        % training
        model = train(obj, trainData, valData, varargin)
                
        % evaluation
        scores = test(obj, model, feat1, feat2)
        
        function modelName = get_model_name_short(obj)
            modelName = sprintf('g%g_gb%g', obj.gamma, obj.gammaBias);
        end
        
        function modelName = get_model_name_long(obj)
            modelName = sprintf('learnRate=%g, learnRateBias=%g, iterations=%d', obj.gamma, obj.gammaBias, obj.numIter);
        end
        
        % classifier name
        function name = get_name(obj)
            
            name = sprintf('dimred_class_unreg_%d', obj.targetDim);
        end
        
        % set classifier params
        function set_params(obj, prms)
            obj.gamma = prms(1);
            obj.gammaBias = prms(2);
        end
        
    end

end
