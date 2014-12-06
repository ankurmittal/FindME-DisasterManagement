%  Copyright (c) 2011, Ken Chatfield
%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function code = encode(obj, feats)
%ENCODE Encode features using the FK method

    %% Initialize encoder wrapper if not done already ----------------------

    if isempty(obj.fc_)
        obj.fisher_params_.grad_weights = obj.grad_weights;
        obj.fisher_params_.grad_means = obj.grad_means;
        obj.fisher_params_.grad_variances = obj.grad_variances;
        obj.fisher_params_.alpha = obj.alpha;
        obj.fisher_params_.pnorm = obj.pnorm;
        
        obj.fc_ = FisherEncoder(obj.codebook_, obj.fisher_params_);
    else
        if ((obj.fisher_params_.grad_weights ~= obj.grad_weights) || ...
                (obj.fisher_params_.grad_means ~= obj.grad_means) || ...
                (obj.fisher_params_.grad_variances ~= obj.grad_variances) || ...
                (obj.fisher_params_.alpha ~= obj.alpha) || ...
                (obj.fisher_params_.pnorm ~= obj.pnorm))
            error(['Fisher parameters cannot be ' ...
                'changed between calls to ''encode()''']);
        end
    end

    %% Apply encoding ------------------------------------------------------
    
    code = obj.fc_.encode(feats);

    %% FV normalisation
    
    % (re-)normalisation applied to the whole vector 
    switch obj.global_norm
        
        case 'l2'
            
            % L2 normalisation
            code_norm = norm(code, 2);
            code = code * (1 / max(code_norm, eps));
            
        case 'helli'
            
            % Hellinger kernel mapping
            code = sign(code) .* sqrt(abs(code));
            code_norm = norm(code, 2);
            code = code * (1 / max(code_norm, eps));            
        
    end
end

