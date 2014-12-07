%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function res = loadChunksIntoMat(varargin)
% Loads data chunks from a directory into a single matrix

    params = struct;
    params.chunk_info = [];
    params.chunk_dir = [];
    params.data_dim_chunk = [];
    params.verbose = false;
        
    params = vl_argparse(params, varargin);
    
    % chunk info
    if ~isempty(params.chunk_info)
        chunk_info = params.chunk_info;
    else
        % load from the dir
        chunk_info_name = sprintf('%s/chunk_info.mat', params.chunk_dir);
        load(chunk_info_name, 'chunk_info');
        
        % override dir
        chunk_info.dir = params.chunk_dir;
    end

    chunk_files = chunk_info.files;
    num_img = sum(chunk_info.num_img);
    
    % resulting data dimensionality
    data_dim = chunk_info.dim;
    
    data_class = chunk_info.class;
    store_mat = isequal(chunk_info.type, 'mat');
    
    % dimensions to load
    if isempty(params.data_dim_chunk)
        params.data_dim_chunk = 1:data_dim;
    else
        data_dim = numel(params.data_dim_chunk);
    end

    % pre-allocate the matrix to the exact size
    if store_mat
        res = ones(data_dim, num_img, data_class);
    else
        res = cell(1, num_img);
    end

    idxoffset = 0;

    % iterate over chunkfiles
    num_sets = numel(chunk_files);

    for si = 1:num_sets

        if params.verbose
            fprintf('Processing set %d of %d...\n', si, num_sets);
        end

        num_img_chunk = numel(chunk_files{si});

        for ci = 1:num_img_chunk

            if params.verbose
                fprintf('  Loading in features from chunk %d of %d...\n', ci, num_img_chunk);
            end

            % load chunk
            chunk_path = fullfile(chunk_info.dir, chunk_files{si}{ci});
            ch = load(chunk_path);
            
            % apply index offset if required
            ch.index = ch.index + idxoffset;

            % copy matrix or cell
            if store_mat
                res(:, ch.index) = ch.chunk(params.data_dim_chunk, :);                
            else
                res(ch.index) = ch.chunk;
            end
        end

        idxoffset = idxoffset + chunk_info.num_img(si);
    end

end

