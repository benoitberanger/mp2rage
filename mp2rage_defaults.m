function mp = mp2rage_defaults
%MP2RAGE_DEFAULTS contains all defautl values
%
% See also mp2rage_get_defaults


%% Default values

% Remove background / Interactive background
%==========================================================================
mp.rmbg.regularization  = 1;
mp.rmbg.output.prefix   = 'clean_';
mp.rmbg.output.filename = 'clean_UNI';


end % function
