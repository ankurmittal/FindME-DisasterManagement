%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function [lin_trans pca_data] = train(obj, varargin)
% computes PCA or PCA-whitening transformation

    prms = struct;
    prms.pca_data = [];
    prms.feats = [];
    
    prms = vl_argparse(prms, varargin);
    
    pca_data = prms.pca_data;
    feats = prms.feats;
    
    % run PCA
    if isempty(pca_data)
        
        % PCA
        fprintf('Performing PCA...\n');

        pca_data = struct;

        % sample mean
        pca_data.mu = mean(feats, 2);
        
        feats = bsxfun(@minus, feats, pca_data.mu);

        % PCA
        [pca_data.covEigvec, ~, pca_data.covEigval] = princomp(feats', 'econ');
        
    end
    
    lin_trans = struct;
    lin_trans.mu = pca_data.mu;
    
    if ~obj.do_whitening
        
        % PCA
        lin_trans.proj = pca_data.covEigvec(:, 1:obj.dim)';
        
    else
        
        % PCA + whitening
        lin_trans.proj = diag(1 ./ sqrt(pca_data.covEigval(1:obj.dim) + 1e-5)) * pca_data.covEigvec(:, 1:obj.dim)';
    end
    
    lin_trans.muProj = lin_trans.proj * lin_trans.mu;
            
    fprintf('Done learning dimensionality reduction!\n');

end

