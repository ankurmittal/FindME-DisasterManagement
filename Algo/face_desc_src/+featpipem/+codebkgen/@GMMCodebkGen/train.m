%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function codebook = train(obj, varargin)
%TRAIN Trains a GMM codebook using EM

    %% load features
    prms = struct;
    prms.init_mean = [];
    prms.feats = [];
    
    prms = vl_argparse(prms, varargin);
    
    feats = prms.feats;
    
    if iscell(feats)
        feats = cat(2, feats{:});
    end

    %% init GMM

    if ~isempty(prms.init_mean)
        
        fprintf('Using pre-computed initial means...\n');
        
        init_mean = prms.init_mean;
        
        fprintf('Computing initial variances and coefficients...\n');

        % compute hard assignments        
        [~, assign] = min(vl_alldist(init_mean, feats), [], 1);

        % mixing coefficients
        init_coef = single(vl_binsum(zeros(obj.cluster_count, 1), 1, double(assign)));
        init_coef = init_coef / sum(init_coef);

        % variances
        init_var = zeros(size(feats, 1), obj.cluster_count, 'single');

        for i = 1:obj.cluster_count
            feats_cluster = feats(:, assign == i);
            init_var(:, i) = var(feats_cluster, 0, 2);
        end

    else
        
        init_mean = [];
        init_var = [];
        init_coef = [];
    end

    %% run GMM learning
    fprintf('Clustering features using GMM...\n');
    fprintf('Dimensionality: %d, number of samples: %d, number of clusters: %d\n', size(feats, 1), size(feats, 2), obj.cluster_count);
    
    gmm_params = struct;

    if ~isempty(init_mean) && ~isempty(init_var) && ~isempty(init_coef)
        codebook = mexGmmTrainSP(feats, obj.cluster_count, gmm_params, init_mean, init_var, init_coef);
    else
        codebook = mexGmmTrainSP(feats, obj.cluster_count, gmm_params);
    end

    fprintf('Done training GMM!\n');

end
