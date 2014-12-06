%% compiles the MATLAB wrapper around GMM and FV code

%%
disp('Making mexGmmTrainSP...');

mex -O mexGmmTrainSP.cxx ../gmm.cxx ../stat.cxx ../simd_math.cxx -largeArrayDims CXXFLAGS="\$CXXFLAGS -O3"
    
%%
disp('Making mexFisherEncodeHelperSP...');

mex -O mexFisherEncodeHelperSP.cxx ../fisher.cxx ../gmm.cxx ../stat.cxx ../simd_math.cxx -largeArrayDims CXXFLAGS="\$CXXFLAGS -O3"