
%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

clear;

% set to 'false' to run locally
isCluster = false;

% experiment name
prms.expName = 'SIFT_1pix_PCA64_GMM512';

% image set name
prms.setName = 'lfw_vj';

% 'unrest': unrestricted, 'rest': restricted
prms.trainSettingName = 'unrest';

% prms.expName = 'SIFT_1pix_PCA64_GMM512_restricted';
% prms.setName = 'lfw_funneled';
% prms.trainSettingName = 'rest';

%%
if isCluster
    
    % run on the cluster

    fprintf('Computing DSIFT...\n');
    JD1 = batch('face_desc.manager.face_descriptor.compute_dense', 'matlabpool', 11, 'workspace', prms); 
    wait(JD1);

    fprintf('Learning PCA and codebooks...\n');
    JD2 = batch('face_desc.manager.face_descriptor.learn_pca_gmm', 'matlabpool', 10, 'workspace', prms);
    wait(JD2);

    fprintf('Computing FV...\n');
    JD3 = batch('face_desc.manager.face_descriptor.compute_fv', 'matlabpool', 11, 'workspace', prms); 

else
    
    % copy params struct to the current workspace & run the code
    prmsName = fieldnames(prms);
    
    for idxName = 1:numel(prmsName)
        assignin('base', prmsName{idxName}, prms.(prmsName{idxName}));
    end
    
    % subset of dense SIFT features
    fprintf('Dense trajectories...\n');
    face_desc.manager.face_descriptor.compute_dense;
    
    % SIFT-PCA & GMM learning
    fprintf('Learning PCA and codebooks...\n');
    face_desc.manager.face_descriptor.learn_pca_gmm;
    
    % FV computation
    fprintf('Computing FV...\n');
    face_desc.manager.face_descriptor.compute_fv;    
end
