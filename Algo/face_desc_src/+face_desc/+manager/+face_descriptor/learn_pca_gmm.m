%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

run('./startup.m');

n=matlabpool('size');

if n > 0
	matlabpool close force
end
fprintf('In PCA and GMM file...\n');
matlabpool open
conf = face_desc.config.feat_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);

% number of splits
load(conf.exp.imgIdsPath, 'imgIds');
numSplits = numel(imgIds);

descDim = conf.descDim;
vocSize = conf.vocSize;

augFeat = true;
augDim = 2;

parfor_progress(length(numSplits));
%% split loop
parfor idxSplit = 1:numSplits
% for idxSplit = 1:numSplits
%	keyboard
    parfor_progress;    
    cbookDir = sprintf('%s/%d/', conf.exp.cbookDir, idxSplit);
        
    %% paths
    descPath = sprintf('%s/sift.mat', cbookDir);
    PCADataPath = sprintf('%s/PCA_data.mat', cbookDir);
    dimredPath = sprintf('%s/PCA_%d.mat', cbookDir, descDim);
    kmeansPath = sprintf('%s/kmeans_%d.mat', cbookDir, vocSize);
    gmmPath = sprintf('%s/gmm_%d.mat', cbookDir, vocSize);
    
    if exist(gmmPath, 'file')
        continue;
    end
    
    %% load unprojected dense descriptors
    featImg = load(descPath, 'featImg');
    featImg = featImg.featImg;
    
    if augFeat        
        % remove (x,y) and keep only SIFT
        featImgAug = featImg(end - augDim + 1 : end, :);
        featImg = featImg(1:end - augDim, :);
    end
    
    %% PCA
    if exist(dimredPath, 'file')
        linTrans = load(dimredPath);
    else
        fprintf('compute PCA')
        dimred = featpipem.dim_red.PCADimRed(descDim);

        [linTrans, PCAData] = dimred.train('feats', featImg);

        % save
        save_struct(dimredPath, linTrans);
        save_struct(PCADataPath, PCAData);        
    end
    
    % project
    featImg = linTrans.proj * featImg;
    
    if augFeat
        featImg = [featImg; featImgAug];
    end
    
    %% kmeans
    if exist(kmeansPath, 'file')
        codebook = load(kmeansPath, 'codebook');
        codebook = codebook.codebook;
    else
	 fprintf('compute kmeans')
        codebkgen = featpipem.codebkgen.KmeansCodebkGen(vocSize);
        codebkgen.rand_seed = conf.rngSeed;
        
        % learn codebook
        codebook = codebkgen.train('feats', featImg);
        
        % save
        res = struct;
        res.codebook = codebook;
        
        save_struct(kmeansPath, res);
    end
    
    %% gmm
    if ~exist(gmmPath, 'file')
	 fprintf('compute GMM')
        codebkgen = featpipem.codebkgen.GMMCodebkGen(vocSize);

        % learn codebook
        codebook = codebkgen.train('feats', featImg, 'init_mean', codebook);

        % save
        res = struct;
        res.codebook = codebook;
        
        save_struct(gmmPath, res);        
    end
end
matlabpool close
