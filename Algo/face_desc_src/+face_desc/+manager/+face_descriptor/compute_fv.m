%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

run('./startup.m');
n=matlabpool('size');

if n > 0
	matlabpool close force
end

fprintf('In fisher vector file...\n');
matlabpool open
conf = face_desc.config.feat_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);
load(conf.database.dbPath, 'database');

% image ids
load(conf.exp.imgIdsPath, 'imgIds');
numSplits = numel(imgIds);

imgList = database.images;

numImg = numel(imgList);

descDim = conf.descDim;
vocSize = conf.vocSize;

descName = conf.faceDescriptor.get_name();

if conf.compMirrorFeat
    descName = [descName '_mirr'];
end

%% split loop
for idxSplit = 1:numSplits    
    
    % desc path
    featDir = sprintf('%s/%s/%d/', conf.exp.featDir, descName, idxSplit);
    chunkInfoPath = sprintf('%s/chunk_info.mat', featDir);
    
    % check if all descs are already computed
    if exist(chunkInfoPath, 'file')
        continue;
    end
    
    ensure_dir(featDir);
    
    % PCA & GMM paths
    cbookDir = sprintf('%s/%d/', conf.exp.cbookDir, idxSplit);
    
    dimredPath = sprintf('%s/PCA_%d.mat', cbookDir, descDim);
    gmmPath = sprintf('%s/gmm_%d.mat', cbookDir, vocSize);
    
    % load and set SIFT PCA projection
    linTrans = load(dimredPath);        
    conf.faceDescriptor.set_feat_proj(linTrans);
    
    % load and set SIFT codebook
    load(gmmPath, 'codebook');        
    conf.faceDescriptor.set_codebook(codebook);
    
    % FV dimensionality
    featDim = conf.faceDescriptor.get_dim();    
        
    % split the images across workers
    numWorkers = max(1, matlabpool('size'));
 
       


    % By Udit
    parfor_progress(length(numWorkers));
 
    % workers loop
    % for idxWorker = 1:numWorkers
    parfor idxWorker = 1:numWorkers 
    %for idxWorker = 1:numWorkers
	parfor_progress;

        chunkName = sprintf('feat_%d.mat', idxWorker);
        chunkPath = sprintf('%s/%s', featDir, chunkName);
        
        % check if the chunk is already computed
        if exist(chunkPath, 'file')
            continue;
        end
        
        idxImgWorker = idxWorker:numWorkers:numImg;
        numImgWorker = numel(idxImgWorker);
        
        feat = zeros(featDim, numImgWorker, 'single');
        
        % load the images
        allImg = load(conf.database.imPath, 'faceImg');
    
        % image loop
        for i = 1:numImgWorker
            
            idxImg = idxImgWorker(i);
        
            % load image 
%             imPath = sprintf('%s/%s', conf.database.imDir, imgList{idxImg});
%             img = imread(imPath);
            img = allImg.faceImg{idxImg};
  %		keyboard          
            % compute descriptor
            feat(:, i) = conf.faceDescriptor.compute(img, 'doPooling', true, 'compMirrorFeat', conf.compMirrorFeat);

        end
        
        % save the workers' chunk
        out = struct;
        out.chunk = feat;
        out.index = idxImgWorker;
        save_struct(chunkPath, out);
        
        % store chunk names
        chunkNames{idxWorker} = chunkName;
        
    end
    
    % store information about the chunks
    chunk_info = struct;
    
    chunk_info.files{1} = chunkNames;
    chunk_info.num_img = numImg;
    
    chunk_info.dim = featDim;
    chunk_info.class = 'single';
    chunk_info.type = 'mat';
    
    chunk_info.dir = featDir;
    
    save(chunkInfoPath, 'chunk_info');
    
end
matlabpool close
