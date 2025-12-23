function mp2rage_run_interactive_synthetic(isynthetic)
%MP2RAGE_RUN_INTERACTIVE_SYNTHETIC will use a T1map to synthetise an image using the provided TI.
% This is done interactivly in a GUI


%% Initialazation : get or set temporary file name

persistent tmpvolname

if isempty(tmpvolname) % First call, create a temporary file name
    tmpvolname = [tempname '.nii'] ; % generate a temporary nifti name
end

default_TI = 0.500;
default_range = [0.010 3.000];


%% Fetch file & load it

if nargin < 1
    T1map_path = spm_select(1,'image','Select T1map (in seconds)');
    if isempty(T1map_path), return, end
else
    T1map_path = isynthetic.T1map;
end
T1map_path = char(T1map_path);

% Load
fprintf('[%s]: Loading T1map = %s \n', mfilename, T1map_path)
V_T1map = spm_vol(T1map_path);
T1map = spm_read_vols(V_T1map);
T1map(isnan(T1map)) = 0;

% Create temporary file
V = V_T1map;
V.fname = tmpvolname;
img =  apply_TI(T1map, default_TI);
spm_write_vol(V,img);

% Open SPM GUI
spm_check_registration(V);


%% UserData (useful for the GUI)

UserData = struct;
UserData.V = V;
UserData.T1map = T1map;


%% GUI
% add a panel so the user can enter the values in the SPM figure

F = spm_figure('FindWin','Graphics');

panel = uipanel(F,...
    'Title','Synthetic',...
    'Units', 'Normalized',...
    'Position',[...
    F.Children(2).Position(1)...
    F.Children(4).Position(2)...
    F.Children(2).Position(3)...
    F.Children(4).Position(4)...
    ],...
    'UserData', UserData);

uicontrol(panel,...
    'Tag', 'edit_TI',...
    'Style','edit',...
    'Units','normalized',...
    'Position',[0.35 0.35 0.3 0.3],...
    'String', num2str(default_TI),...
    'Tooltip','Inversion Time (s)',...
    'Callback',@edit_TI_Callback);

uicontrol(panel,...
    'Tag', 'slider_TI',...
    'Style','slider',...
    'Units','normalized',...
    'Position',[0.0 0.1 1.0 0.2],...
    'Min', default_range(1),...
    'Max', default_range(2),...
    'SliderStep', [0.010 0.100],...
    'Value', default_TI,...
    'Callback',@slider_TI_Callback);


end % fcn

function edit_TI_Callback(hObject, ~)
update_value(hObject.Parent, str2double(hObject.String));
end % fcn

function slider_TI_Callback(hObject, ~)
update_value(hObject.Parent, hObject.Value);
end % fcn

function update_value(panel, value)
img =  apply_TI(panel.UserData.T1map, value);
spm_write_vol(panel.UserData.V,img);
pos = spm_orthviews('Pos');      % Get last cursor position
spm_orthviews('Reposition',pos); % Refresh the display @ last cursor position (it will load the freshly written volume)
for c = 1 : length(panel.Children)
    panel.Children(c).Value = value;
    panel.Children(c).String = num2str(value);
end
end % fcn

function img = apply_TI(T1, TI)
img = abs(1 - 2*exp(-TI/T1));
end % fcn
