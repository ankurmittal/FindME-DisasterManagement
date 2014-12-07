%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function save_struct(FileName, Data)
%   save_struct(FileName, Data)
%   this function can be called from within parfor loops

    save(FileName, '-struct', 'Data', '-v7.3');
end
