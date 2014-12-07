%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function saveMatToChunks(chunk_dir, data, varargin)
% saves a matrix into a number of chunk files

    prms = struct;
    prms.chunk_size = inf;
    prms.set_name = '';
    
    prms = vl_argparse(prms, varargin);

    num_img = size(data, 2);
    
    prms.chunk_size = min(prms.chunk_size, num_img);
    
    ensure_dir(chunk_dir);
    
    chunk_info = struct;
    chunk_info.files{1} = '';
    chunk_info.num_img = num_img;
    chunk_info.dim = size(data, 1);
    chunk_info.class = class(data);
    chunk_info.type = 'mat';
    chunk_info.dir = chunk_dir;
    
    for i = 1 : prms.chunk_size : num_img
        
        chunk_name = sprintf('feat_%d.mat', i);
        chunk_path = fullfile(chunk_dir, chunk_name);
                
        index = i : min(i + prms.chunk_size - 1, num_img);
        chunk = data(:, index);
        chunk_info.files{1}{end + 1} = chunk_name;
        
        save(chunk_path, 'chunk', 'index');    
    end
    
    save(fullfile(chunk_dir, 'chunk_info.mat'), 'chunk_info');

end
