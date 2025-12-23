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

% Correct T1
%==========================================================================
mp.correctT1.output_T1map_notCorrected.prefix   = 'T1map_notCorrected_';
mp.correctT1.output_T1map_notCorrected.filename = 'T1map_notCorrected';
mp.correctT1.output_T1map_B1corrected .prefix   = 'T1map_B1corrected_';
mp.correctT1.output_T1map_B1corrected .filename = 'T1map_B1corrected';
mp.correctT1.output_diffT1_pct        .prefix   = 'diffT1_pct_';
mp.correctT1.output_diffT1_pct        .filename = 'diffT1_pct';
mp.correctT1.output_diffT1_sec        .prefix   = 'diffT1_sec_';
mp.correctT1.output_diffT1_sec        .filename = 'diffT1_sec';
mp.correctT1.output_UNI_B1corrected   .prefix   = 'UNI_B1corrected_';
mp.correctT1.output_UNI_B1corrected   .filename = 'UNI_B1corrected';


end % function
