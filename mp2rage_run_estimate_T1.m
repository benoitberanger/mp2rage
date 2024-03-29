function mp2rage_run_estimate_T1(estimateT1)
%MP2RAGE_RUN_ESTIMATE_T1 Executable job that estimates the quantitative
%T1map and R1map=1/T1map from the UNI image and the sequence parameters.
%
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/T1estimateMP2RAGE.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676
%
% SYNTAX
%       MP2RAGE_RUN_ESTIMATE_T1(estimateT1)
%
% INPUTS
%       estimateT1.fname_T1               (char)   : fullpath of the output T1w file
%       estimateT1.fname_R1               (char)   : fullpath of the output R1  file
%       estimateT1.UNI                    (char)   : path of the UNI  nifti image
%       estimateT1.B0                     (double) : Magnetic field strength B0 in Tesla (T)
%       estimateT1.TR                     (double) : MP2RAGE TR in seconds (s)
%       estimateT1.EchoSpacing            (double) : EchoSpacing in seconds (s). TR of the GRE readout.
%                                                    On Siemens scanners, this is called EchoSpacing.
%       estimateT1.TI                     (double) : Inversion Times in seconds (s) such as [ TI1 TI2 ]
%       estimateT1.FA                     (double) : Flip Angles in degree (°) such as [ FA1 FA2 ]
%       estimateT1.nrSlices               (double) : Number of slices per slab
%       estimateT1.PartiealFourierInSlice (double) : PartialFourierInSlice value range is 0 to 1.
%                                                    On Siemens scanner, it is expressed as a fraction such as 8/8, 7/8, ...
%                                                    On Siemens scanner, it corresponds to SlicePartialFourier, ant not PhasePartialFourier
%       estimateT1.FatSat                 (char)   : (yes/no) Fat saturation pulse
%                                                    On Siemens scanner, this option is in the tab Contrast > Fat Sat
%                                                    On Siemens scanner, the option can be "none", "water excitation normal", "water excitation fast"
%
% See also mp2rage_cfg_matlabbatch

if nargin==0, help(mfilename('fullpath')); return; end


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
