function mp = mp2rage_defaults
%MP2RAGE_DEFAULTS contains all defautl values
%
% See also mp2rage_get_defaults


%% Default values

% Remove background
%==========================================================================
mp.rmbg.regularization = 10;
mp.rmbg.prefix         = 'clean_';

% Interactive Remove background
%==========================================================================
mp.interactive.regularization = 1;
mp.interactive.prefix         = 'interactive_clean_';


end % function
