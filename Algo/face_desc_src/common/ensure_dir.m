%  Copyright (c) 2014, Karen Simonyan
%  All rights reserved.
%  This code is made available under the terms of the BSD license (see COPYING file).

function ensure_dir(Dir)

    system(sprintf('mkdir -p %s', Dir));

end
