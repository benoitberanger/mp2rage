function mp2rage_main_estimate_T1(varargin)
%MP2RAGE_MAIN_ESTIMATE_T1 Executable job that estimates the quantitative
%T1map and R1map=1/T1map from the UNI image and the sequence paramters.
%
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/T1estimateMP2RAGE.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676


%% Fetch job & build the final fullpath-filename

estimateT1 = varargin{1};

% T1map
%--------------------------------------------------------------------------

% 1)
if isfield(estimateT1.outputT1,'prefix')
    [pathstr_T1, name_T1, ext_T1] = spm_fileparts( estimateT1.UNI{1} );
    fname_T1                = [pathstr_T1 filesep estimateT1.outputT1.prefix name_T1 ext_T1];
    
    % 2)
elseif isfield(estimateT1.outputT1,'dirfile')
    fname_T1 = char(fullfile(estimateT1.outputT1.dirfile.dirpath, [estimateT1.outputT1.dirfile.filename '.nii']));
    
    % 3)
elseif isfield(estimateT1.outputT1,'fullpathfilename')
    fname_T1 = char([estimateT1.outputT1.fullpathfilename '.nii']);
    
    % 4)
elseif isfield(estimateT1.outputT1,'filename')
    fname_T1 = char([fullfile(pwd,estimateT1.outputT1.filename) '.nii']);
    
end

fprintf('[%s]: Final output = %s \n', mfilename, fname_T1) % for diagnostic


% R1map
%--------------------------------------------------------------------------

% 1)
if isfield(estimateT1.outputR1,'prefix')
    [pathstr_R1, name_R1, ext_R1] = spm_fileparts( estimateT1.UNI{1} );
    fname_R1                = [pathstr_R1 filesep estimateT1.outputR1.prefix name_R1 ext_R1];
    
    % 2)
elseif isfield(estimateT1.outputR1,'dirfile')
    fname_R1 = char(fullfile(estimateT1.outputR1.dirfile.dirpath, [estimateT1.outputR1.dirfile.filename '.nii']));
    
    % 3)
elseif isfield(estimateT1.outputR1,'fullpathfilename')
    fname_R1 = char([estimateT1.outputR1.fullpathfilename '.nii']);
    
    % 4)
elseif isfield(estimateT1.outputR1,'filename')
    fname_R1 = char([fullfile(pwd,estimateT1.outputR1.filename) '.nii']);
    
end

fprintf('[%s]: Final output = %s \n', mfilename, fname_R1) % for diagnostic


%% Load volume

V_UNI = spm_vol(estimateT1.UNI{1});
Y_UNI = double(spm_read_vols(V_UNI));


%% Converts MP2RAGE to -0.5 to 0.5 scale

[ Y_UNI, integerformat ] = mp2rage_scale_UNI( Y_UNI );


%%

T1 = 0.5;
invEFF = 1;
mp2rage_solve_bloch( estimateT1, T1, invEFF)

end % function

