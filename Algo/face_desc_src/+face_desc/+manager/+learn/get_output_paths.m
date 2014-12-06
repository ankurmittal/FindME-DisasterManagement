%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function outPaths = get_output_paths(conf, idxSplit)

confExp = conf.exp;

%% dimred init path
if ~isequal(confExp.dimredMethodInit, 'none')
    dimredDir = sprintf('%s/%d/', confExp.dimredDir, idxSplit);
    ensure_dir(dimredDir);

    outPaths.dimredPathInit = sprintf('%s/%s_%d.mat', dimredDir, confExp.dimredMethodInit, confExp.dimredFeatDim);
else
    outPaths.dimredPathInit = [];
end

%% model dir
modelDir = sprintf('%s/%s/%d/', confExp.modelDir, conf.class.get_name(), idxSplit);

ensure_dir(modelDir);

% model name
modelName = conf.class.get_model_name_short();

% model path
outPaths.modelPath = sprintf('%s/%s.mat', modelDir, modelName);

%% log path
logDir = sprintf('%s/logs/', modelDir);
ensure_dir(logDir);

outPaths.logPath = sprintf('%s/%s.txt', logDir, modelName);

%% verification score path
if conf.useMirrorFeat
    scoreDir = sprintf('%s/scores_mirr/', modelDir);
else
    scoreDir = sprintf('%s/scores/', modelDir);
end

ensure_dir(scoreDir);

% score path
outPaths.scorePath = sprintf('%s/%s.mat', scoreDir, modelName);

end
