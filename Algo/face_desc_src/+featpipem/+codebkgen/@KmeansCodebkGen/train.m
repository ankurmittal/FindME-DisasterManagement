%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function codebook = train(obj, varargin)
%TRAIN Trains a codebook of visual words using kmeans

    %% load features
    prms = struct;
    prms.feats = [];
    
    prms = vl_argparse(prms, varargin);
    
    feats = prms.feats;
    
    if iscell(feats)
        feats = cat(2, feats{:});
    end
    
    %% compute codebook
    fprintf('Clustering features...\n');

    vl_twister('STATE', obj.rand_seed);
        
    codebook = vl_kmeans(feats, obj.cluster_count, 'verbose', 'algorithm', 'elkan', 'initialization', 'plusplus');

    fprintf('Done training codebook!\n');

end

