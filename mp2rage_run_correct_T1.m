function mp2rage_run_correct_T1(correctT1)
%MP2RAGE_RUN_CORRECT_T1 Executable job that estimates the quantitative
%T1map from the UNI image and the sequence parameters, and correct it for B1
%inhomogeneities. Quality control images will be also written.
%
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/T1estimateMP2RAGE.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676
%
% This code is also adapted from previous code developped at CRMBM, Aix Marseille Univ, CNRS, Marseille, France
% (CRMBM contributors : O.M. Girard, L. de Rochefort, A. Massire, A. Le Troter, contact : olivier.girard@univ-amu.fr)
% Copyright © 2025 amU, CNRS
%
% SYNTAX
%       MP2RAGE_RUN_ESTIMATE_T1(correctT1)
%
% INPUTS
%       correctT1.fname_T1map_notCorrected (char)   : fullpath of the output T1map without B1 correction file
%       correctT1.fname_T1map_B1corrected  (char)   : fullpath of the output T1map corrected B1 file
%       correctT1.fname_diffT1_pct         (char)   : fullpath of difference of T1 expressed in percentage (%), WITH vs WITHOUT the B1 correction
%       correctT1.fname_diffT1_sec         (char)   : fullpath of difference of T1 expressed in seconds    (s), WITH vs WITHOUT the B1 correction
%       correctT1.UNI                      (char)   : path of the UNI nifti image
%       correctT1.B1map                    (char)   : path of the B1map nifti image : this image will be rescaled to become "relative"
%       correctT1.B1scaling                (double) : scaling factor, multiplied to the B1map to make relative
%       correctT1.B0                       (double) : Magnetic field strength B0 in Tesla (T)
%       correctT1.TR                       (double) : MP2RAGE TR in seconds (s)
%       correctT1.EchoSpacing              (double) : EchoSpacing in seconds (s). TR of the GRE readout.
%                                                    On Siemens scanners, this is called EchoSpacing.
%       correctT1.TI                       (double) : Inversion Times in seconds (s) such as [ TI1 TI2 ]
%       correctT1.FA                       (double) : Flip Angles in degree (°) such as [ FA1 FA2 ]
%       correctT1.nrSlices                 (double) : Number of slices per slab
%       correctT1.PartiealFourierInSlice   (double) : PartialFourierInSlice value range is 0 to 1.
%                                                    On Siemens scanner, it is expressed as a fraction such as 8/8, 7/8, ...
%                                                    On Siemens scanner, it corresponds to SlicePartialFourier, ant not PhasePartialFourier
%       correctT1.FatSat                   (char)   : (yes/no) Fat saturation pulse
%                                                    On Siemens scanner, this option is in the tab Contrast > Fat Sat
%                                                    On Siemens scanner, the option can be "none", "water excitation normal", "water excitation fast"
%
% See also mp2rage_cfg_matlabbatch

if nargin==0, help(mfilename('fullpath')); return; end


%% Fetch job & build the final fullpath-filename

fprintf('[%s]: Final output = %s \n', mfilename, correctT1.fname_T1map_notCorrected)
fprintf('[%s]: Final output = %s \n', mfilename, correctT1.fname_T1map_B1corrected )
fprintf('[%s]: Final output = %s \n', mfilename, correctT1.fname_diffT1_pct        )
fprintf('[%s]: Final output = %s \n', mfilename, correctT1.fname_diffT1_sec        )

%% Relice B1map to T1 resolution

reliced_B1 = spm_file(correctT1.B1map,'prefix','reslicedT1_');
[pth,nam,ext] = spm_fileparts(reliced_B1);
reliced_B1_path = fullfile(pth, [nam ext]);
if ~exist(reliced_B1_path,'file')
    fprintf('[%s]: Reslicing B1map to T1 resolution = %s \n', mfilename, reliced_B1_path)
    matlabbatch = {};
    matlabbatch{1}.spm.spatial.coreg.write.ref = correctT1.UNI;
    matlabbatch{1}.spm.spatial.coreg.write.source = correctT1.B1map;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.interp = 4;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
    matlabbatch{1}.spm.spatial.coreg.write.roptions.mask = 0;
    matlabbatch{1}.spm.spatial.coreg.write.roptions.prefix = 'reslicedT1_';
    spm_jobman('run', matlabbatch)
else
    fprintf('[%s]: Found resliced B1map to T1 resolution = %s \n', mfilename, reliced_B1_path)
end


%% Load resliced B1map

fprintf('[%s]: Loading resliced B1map = %s \n', mfilename, reliced_B1_path)

V_B1map = spm_vol(reliced_B1{1});
Y_B1map = double(spm_read_vols(V_B1map));

Y_relB1map = Y_B1map * correctT1.B1scaling;


%% Load volume

fprintf('[%s]: Loading resliced B1map = %s \n', mfilename, correctT1.UNI{1})
V_UNI = spm_vol(correctT1.UNI{1});
Y_UNI = double(spm_read_vols(V_UNI));


%% Converts MP2RAGE to -0.5 to 0.5 scale

Y_UNI = mp2rage_scale_UNI( Y_UNI );


%% Build lookuptable

fprintf('[%s]: Computing mp2rage_lookuptable \n', mfilename)
[Intensity, T1vector, B1vector] = mp2rage_lookuptable( correctT1, true );
nT1vector = numel(T1vector);
nB1vector = numel(B1vector);


%% Check for bijectivity

[gridT1, gridB1] = meshgrid(T1vector, B1vector);
gridIntensity = Intensity';

gradIntensity = gradient(gridIntensity);
limitItensity = gradIntensity >= 0;

AcceptedT1_idx = sum(limitItensity,1) < 1;
AcceptedT1 = T1vector(AcceptedT1_idx);
AcceptedT1_min_value = min(AcceptedT1);
AcceptedT1_max_value = max(AcceptedT1);

gridIntensityBij = gridIntensity;
for b1_idx = 1 : nB1vector
    vectorIntensity = gridIntensity(b1_idx,:);
    [vectorIntensity_min_value, vectorIntensity_min_idx] =  min(vectorIntensity);
    [vectorIntensity_max_value, vectorIntensity_max_idx] =  max(vectorIntensity);
    gridIntensityBij(b1_idx, 1                      :vectorIntensity_max_idx) = vectorIntensity_max_value;
    gridIntensityBij(b1_idx, vectorIntensity_min_idx:nT1vector              ) = vectorIntensity_min_value;
end

% f = figure(1);
% clf(f);
% ax(1) = subplot(3,1,1);
% f1 = surf(gridT1, gridB1, gridIntensity);
% f1.EdgeColor = 'none';
% ax(2) = subplot(3,1,2);
% f2 = surf(gridT1, gridB1, gridIntensityBij);
% f2.EdgeColor = 'none';
% ax(3) = subplot(3,1,3);
% f3 = surf(gridT1, gridB1, gridIntensityBij - gridIntensity );
% f3.EdgeColor = 'none';

idx_B1ok = B1vector==1;
IntensityB1ok = gridIntensityBij(idx_B1ok,:);
limitItensityB1ok = limitItensity(idx_B1ok,:)<1;

fprintf('[%s]: Without B1 correction // UNI signal is only bijective in the range [ %5.3f %5.3f ]s \n', mfilename, min(T1vector(limitItensityB1ok)), max(T1vector(limitItensityB1ok)))
fprintf('[%s]: Without B1 correction // You should only consider T1  in the range [ %5.3f %5.3f ]s \n', mfilename, min(T1vector(limitItensityB1ok)), max(T1vector(limitItensityB1ok)))
fprintf('[%s]: With    B1 correction // UNI signal is only bijective in the range [ %5.3f %5.3f ]s \n', mfilename, AcceptedT1_min_value, AcceptedT1_max_value)
fprintf('[%s]: With    B1 correction // You should only consider T1  in the range [ %5.3f %5.3f ]s \n', mfilename, AcceptedT1_min_value, AcceptedT1_max_value)


%% T1map_notCorrected
% performs 1D interp : use a much faster method than 2D interp

fprintf('[%s]: Perform 1D interp for B1 uncorrected T1map \n', mfilename)
Y_T1map_notCorrected = interp1( IntensityB1ok(limitItensityB1ok), T1vector(limitItensityB1ok), Y_UNI(:) );
Y_T1map_notCorrected = reshape( Y_T1map_notCorrected, size(Y_UNI) );
Y_T1map_notCorrected(Y_T1map_notCorrected<0            ) = 0;
Y_T1map_notCorrected(Y_T1map_notCorrected>max(T1vector)) = 0;


%% T1map_notCorrected
% performs 2D interp : use a much faster method than 2D interp

fprintf('[%s]: Perform 2D interp for B1 corrected T1map \n', mfilename)
fprintf('[%s]: This may take a while (~1 min for 1mm whole brain)... \n', mfilename)

interpolator = scatteredInterpolant(gridIntensity(:), gridB1(:)  , gridT1(:));
t0 = tic;
Y_T1map_B1corrected = interpolator(Y_UNI, Y_relB1map);
fprintf('[%s]: 2D interp took %gs \n', mfilename, toc(t0))
Y_T1map_B1corrected(Y_T1map_B1corrected<0            ) = 0;
Y_T1map_B1corrected(Y_T1map_B1corrected>max(T1vector)) = 0;


%% Quality control : difference of T1map before vs after B1 correction

fprintf('[%s]: Computing diffT1, in percentage and in seconds \n', mfilename)
Y_diffT1_pct = 100 * (Y_T1map_B1corrected./Y_T1map_notCorrected - 1);
Y_diffT1_sec = Y_T1map_B1corrected - Y_T1map_notCorrected;


%% Write volumes

fprintf('[%s]: Write volumes \n', mfilename)

% Remove previous scaling factor
HEADER       = rmfield(V_UNI, 'pinfo');
HEADER.dt(1) = spm_type('float32');

write_volume( ...
    HEADER, ...
    correctT1.fname_T1map_notCorrected, ...
    '[mp2rage] not B1 corrected // quantitative T1 map, in second (s)', ...
    Y_T1map_notCorrected)

write_volume( ...
    HEADER, ...
    correctT1.fname_T1map_B1corrected, ...
    '[mp2rage] B1 corrected // quantitative T1 map, in second (s)', ...
    Y_T1map_B1corrected)

write_volume( ...
    HEADER, ...
    correctT1.fname_diffT1_pct, ...
    '[mp2rage] T1map_B1correted vs T1map_notCorrected : in percentage (%)', ...
    Y_diffT1_pct)

write_volume( ...
    HEADER, ...
    correctT1.fname_diffT1_sec, ...
    '[mp2rage] T1map_B1correted vs T1map_notCorrected : in seconds (s)', ...
    Y_diffT1_sec)


end % function

function write_volume(header, fname, comment, Y)
V = header; % make copy
V.fname   = fname;
V.descrip = comment;
assert( ~strcmp(header.fname,V.fname), ...
    '[%s]: The output filename is the same as the input UNI filename. Do not overwrite your input UNI', mfilename )
spm_write_vol(V,Y);
fprintf('[%s]: Volume = %s \n', mfilename, fname)
end
