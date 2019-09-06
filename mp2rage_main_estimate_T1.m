function mp2rage_main_estimate_T1(estimateT1)
%MP2RAGE_MAIN_ESTIMATE_T1 Executable job that estimates the quantitative
%T1map and R1map=1/T1map from the UNI image and the sequence paramters.
%
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/T1estimateMP2RAGE.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676


%% Fetch job & build the final fullpath-filename

% T1map
%--------------------------------------------------------------------------
fname_T1 = estimateT1.fname_T1;
fprintf('[%s]: Final output = %s \n', mfilename, fname_T1) % for diagnostic


% R1map
%--------------------------------------------------------------------------
fname_R1 = estimateT1.fname_R1;
fprintf('[%s]: Final output = %s \n', mfilename, fname_R1) % for diagnostic


%% Load volume

V_UNI = spm_vol(estimateT1.UNI{1});
Y_UNI = double(spm_read_vols(V_UNI));


%% Converts MP2RAGE to -0.5 to 0.5 scale

Y_UNI = mp2rage_scale_UNI( Y_UNI );


%% Build lookuptable

[Intensity, T1vector] = mp2rage_lookuptable( estimateT1 );


%% Use lookuptable to transform the UNI into qT1
% Here qT1 is in second, and R1 = 1/T1 is in 1/s.

Y_T1                = interp1( Intensity, T1vector, Y_UNI(:) );
Y_T1( isnan(Y_T1) ) = 0;
Y_T1                = reshape( Y_T1, size(Y_UNI) );

Y_R1                = 1 ./ Y_T1;
Y_R1( isnan(Y_R1) ) = 0;


%% Write volumes

% Remove previous scaling factor
V_UNI = rmfield(V_UNI, 'pinfo');

V_T1         = V_UNI; % copy info from UNI image
V_T1.fname   = fname_T1;
V_T1.descrip = '[mp2rage] quantitative T1 map, in second (s)';

V_R1         = V_UNI; % copy info from UNI image
V_R1.fname   = fname_R1;
V_R1.descrip = '[mp2rage] quantitative R1 map, in second^(-1) (s^(-1))';

% Security check :
% I already messed up with volumes by overwriting the original volumes, instead of writing a new one...
assert( ~strcmp(V_UNI.fname,V_T1.fname), '[%s]: The output filename is the same as the input UNI filename. Do not overwrite your input UNI', mfilename )
assert( ~strcmp(V_UNI.fname,V_R1.fname), '[%s]: The output filename is the same as the input UNI filename. Do not overwrite your input UNI', mfilename )

% Write volumes
spm_write_vol(V_T1,Y_T1);
spm_write_vol(V_R1,Y_R1);


end % function
