function mp = mp2rage_defaults
%MP2RAGE_DEFAULTS contains all default values
%
% See also mp2rage_get_defaults


%% Default values

% Remove background / Interactive background
%==========================================================================
mp.rmbg.regularization  = 1;
mp.rmbg.output.prefix   = 'clean_';
mp.rmbg.output.filename = 'clean_UNI';

% Estimate T1
%==========================================================================
mp.estimateT1.outputT1.prefix   = 'qT1_';
mp.estimateT1.outputT1.filename = 'qT1';
mp.estimateT1.outputR1.prefix   = 'qR1_';
mp.estimateT1.outputR1.filename = 'qR1';

end % function
