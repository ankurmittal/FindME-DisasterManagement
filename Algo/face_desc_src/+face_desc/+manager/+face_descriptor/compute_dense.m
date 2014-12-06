%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

run('./startup.m');

n=matlabpool('size');

if n > 0
	matlabpool close force
end

matlabpool open;
fprintf('Loading database');

conf = face_desc.config.feat_config('expName', expName, 'setName', setName, 'trainSettingName', trainSettingName);
load(conf.database.dbPath, 'database');

fprintf('Computing face descriptors');

% load image ids for each split
load(conf.exp.imgIdsPath, 'imgIds');

% number of features for PCA/GMM learning
totalFeatLimit = 1e6;

imgNames = database.images;

numSplits = numel(imgIds);
numWorkers = max(1, matlabpool('size'));

%% split loop
for idxSplit = 1:numSplits

	descDir = sprintf('%s/%d/', conf.exp.cbookDir, idxSplit);
	descPath = sprintf('%s/sift.mat', descDir);
	% check if already computed
	if exist(descPath, 'file')
	continue;
	end

	ensure_dir(descDir);

	imgNamesSplit = imgNames(imgIds{idxSplit});
	imgIdsSplit = imgIds{idxSplit};
	numImg = numel(imgNamesSplit);

	% features per image
	imgFeatLimit = ceil(totalFeatLimit / numImg);

	% list of images per worker
	workerImgList = cell(1, numSplits);

	for idxWorker = 1:numWorkers
		workerImgList{idxWorker} = idxWorker : numWorkers : numImg;
	end

	featImg = cell(1, numWorkers);


	% By Udit
	parfor_progress(length(numWorkers));
	% images loop
	parfor idxWorker = 1:numWorkers
	%for idxWorker = 1:numWorkers
		parfor_progress;
		% random seed
		rng(conf.rngSeed);
		numImgWorker = numel(workerImgList{idxWorker});

		featImgWorker = cell(1, numImgWorker);

		% load the images
		allImg = load(conf.database.imPath, 'faceImg');

		for k = 1:numImgWorker

			idxImg = workerImgList{idxWorker}(k);

			imName = imgNamesSplit{idxImg};
			imId = imgIdsSplit(idxImg);

			% load image
%             imPath = sprintf('%s/%s', conf.database.imDir, imName);
%             img = imread(imPath);
			img = allImg.faceImg{idxImg};

			% compute dense features
			feats = conf.faceDescriptor.compute(img, 'doPooling', false, 'imName', imName);

			num_feat = size(feats, 2);

			% subsample features
			feat_perm = randperm(num_feat);
			feat_perm = feat_perm(1:min(imgFeatLimit, num_feat));

			featImgWorker{k} = feats(:, feat_perm);
		end

		featImg{idxWorker} = cat(2, featImgWorker{:});
	end

% concat
featImg = cat(2, featImg{:});

% save descriptors
save(descPath, 'featImg');
matlabpool close;
end
