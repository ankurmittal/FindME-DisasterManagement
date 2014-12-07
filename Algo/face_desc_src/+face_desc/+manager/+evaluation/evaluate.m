%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function result = evaluate(config, scores, gt)

    scores = reshape(scores, 1, []);

    % evaluation measure loop
    for i = 1:numel(config.exp.eval)
        
        switch config.exp.eval(i).name
            
            case 'ap'
                [res, extra] = face_desc.lib.evaluation.ap.eval(config.exp.eval(i), scores, gt);
                
            case 'roc'
                [res, extra] = face_desc.lib.evaluation.roc.eval(config.exp.eval(i), scores, gt);
                
            case 'accuracy'
                [res, extra] = face_desc.lib.evaluation.accuracy.eval(config.exp.eval(i), scores, gt);
            
        end
        
        % measure name
        result(i).meas_name = config.exp.eval(i).name;
        
        % measure value (a scalar)
        result(i).measure = res;
        
        % extra data in a struct (e.g. optimal thresh), or empty
        result(i).extra = extra;
       
    end

end
