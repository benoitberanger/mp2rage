function V = mp2rage_display_volume(V,Y)
%MP2RAGE_DISPLAY_VOLUME will write a volume in a temporary file, and
%display it using SPM image display.
%
% INPUT
% - V is a structure, output of V = spm_vol('path/to/volume.nii')
% - Y is a 3D cube, output of Y = spm_read_vols(V)
%     this is the cube==image you want to display
%
% OUTPUT
% - V is the updated V input, modified by spm_write_vol if necessary
%
% see also spm_vol spm_read_vols tempname spm_write_vol spm_image spm_orthviews


%% Initialazation : get or set temporary file name

persistent tmpvolname
global st % this is SPM variable containing all informations about the orthview, including the volume.

if isempty(tmpvolname) % First call, create a temporary file name
    tmpvolname = [tempname '.nii'] ; % generate a temporary nifti name
    V.fname = tmpvolname;
end


%% Write volume

% Write in the temporary volume the new "cube" Y
V = spm_write_vol(V,Y);


%% Display volume

if isempty(st)
    spm_image('Display', V.fname); % Initialize the display
else
    pos = spm_orthviews('Pos');      % Get last cursor position
    spm_orthviews('Reposition',pos); % Refresh the display @ last cursor position (it will load the freshly written volume)
end

end % function
