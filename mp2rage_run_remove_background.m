function mp2rage_run_remove_background(rmbg)
%MP2RAGE_RUN_REMOVE_BACKGROUND Executable job that removes background noise for mp2rage UNI image.
%
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/RobustCombination.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676
%
% SYNTAX
%       MP2RAGE_RUN_REMOVE_BACKGROUND(rmbg)
%
% INPUTS
%       rmbg.fname          (char) : fullpath of the output file
%       rmbg.INV1           (char) : path of the INV1 nifti image
%       rmbg.INV2           (char) : path of the INV2 nifti image
%       rmbg.UNI            (char) : path of the UNI  nifti image
%       rmbg.regularization ( int) : regularization parameter
%       rmbg.show           (char) : can be 'yes', 'interactive'. anything else is discarded
%
% See also mp2rage_cfg_matlabbatch

if nargin==0, help(mfilename('fullpath')); return; end

fname = rmbg.fname;

fprintf('[%s]: Final output = %s \n', mfilename, fname) % for diagnostic

if isfield(rmbg, 'method')
    method = char(fieldnames(rmbg.method));
else
    method = 'iregulsarisation';
end


%% Load common volumes


V_INV2 = spm_vol(rmbg.INV2{1});
Y_INV2 = double(spm_read_vols(V_INV2));

V_UNI = spm_vol(rmbg.UNI{1});
Y_UNI = double(spm_read_vols(V_UNI));


%% Prepare output volume info
V_out       = V_UNI; % copy info from UNI image
V_out.fname = fname;
V_out.dt(1) = spm_type('float32'); % int -> float


%% Computation

if regexp(method,'regulsarisation') % works for both 'regulsarisation' and 'iregulsarisation'

    V_out.descrip = sprintf('[mp2rage] background removed with regularization=%g',rmbg.regularization);

    V_INV1 = spm_vol(rmbg.INV1{1});
    Y_INV1 = double(spm_read_vols(V_INV1));

    % Prepare some local functions
    MP2RAGErobustfunc = @(INV1,INV2,beta) (conj(INV1).*INV2-beta)./(INV1.^2+INV2.^2+2*beta);
    rootsquares_pos   = @(a,b,c)          (-b+sqrt(b.^2 -4 *a.*c))./(2*a);
    rootsquares_neg   = @(a,b,c)          (-b-sqrt(b.^2 -4 *a.*c))./(2*a);

    % Converts MP2RAGE to -0.5 to 0.5 scale
    [ Y_UNI, integerformat ] = mp2rage_scale_UNI( Y_UNI );

    % Computes correct INV1 dataset -------------------------------------------

    % Give the correct polarity to INV1;
    Y_INV1 = sign(Y_UNI).*Y_INV1;

    % "because the INV1 and INV2 is a summ of squares data, while the UNI is a
    % phase sensitive coil combination.. some more maths has to be performed to
    % get a better INV1 estimate which here is done by assuming both INV2 is
    % closer to a real phase sensitive combination"

    INV1pos = rootsquares_pos(-Y_UNI,Y_INV2,-Y_INV2.^2.*Y_UNI);
    INV1neg = rootsquares_neg(-Y_UNI,Y_INV2,-Y_INV2.^2.*Y_UNI);

    Y_INV1( abs(Y_INV1-INV1pos)> abs(Y_INV1-INV1neg) ) = INV1neg( abs(Y_INV1-INV1pos)> abs(Y_INV1-INV1neg) );
    Y_INV1( abs(Y_INV1-INV1pos)<=abs(Y_INV1-INV1neg) ) = INV1pos( abs(Y_INV1-INV1pos)<=abs(Y_INV1-INV1neg) );

    % lambda calculation ------------------------------------------------------

    % "usually the multiplicative factor shouldn't be greater then 10, but that
    % is not the case when the image is bias field corrected, in which case the
    % noise estimated at the edge of the image might not be such a good
    % measure"

    reg2noise = @(reg,INV2) reg * mean(mean(mean( INV2(1:end,end-10:end,end-10:end) )));
    noiselevel = reg2noise(rmbg.regularization,Y_INV2);

    Y_T1w = MP2RAGErobustfunc(Y_INV1, Y_INV2, noiselevel.^2);

    % Convert the final image to uint (if necessary)

    Y_T1w = mp2rage_unscale_UNI( Y_T1w, integerformat );

elseif regexp(method,'psedomask') % works for both 'regulsarisation' and 'iregulsarisation'

    V_out.descrip = '[mp2rage] background removed using psedomask from INV2';

    % generate psedo mask using INV2
    min_INV2 = min(Y_INV2(:));
    max_INV2 = max(Y_INV2(:));
    psedomask = (Y_INV2 - min_INV2) / (max_INV2 - min_INV2);

    Y_T1w = Y_UNI .* psedomask;

else
    error('unknwon method')
end


%% Save volume

V_out = spm_write_vol(V_out,Y_T1w);


%% Check the results with spm_check_registration

if any(strcmpi(rmbg.show,{'Yes','Interactive'}))

    spm_check_registration( V_UNI.fname, V_out.fname )

    if strcmpi(rmbg.show,'Interactive')

        Finter = spm_figure('GetWin', 'Interactive'); % classic popup menu from SPM

        UserData                   = struct;
        UserData.MP2RAGErobustfunc = MP2RAGErobustfunc;
        UserData.integerformat     = integerformat;
        UserData.Y_INV1            = Y_INV1;
        UserData.Y_INV2            = Y_INV2;
        UserData.reg2noise         = reg2noise;
        UserData.V_out             = V_out;

        % Add a text box where the user can edit
        uicontrol(Finter,...
            'Style','edit',...
            'Units', 'Normalized',...
            'Position', [0.25 0.25 0.5 0.5],...
            'String',num2str(rmbg.regularization),...
            'BackgroundColor',[0.9 0.9 0.9],...
            'TooltipString','Set a value here for the noise regularization',...
            'Tag','edit_rmbg_regularization',...
            'UserData',UserData,...
            'Callback',@edit_rmbg_regularization_Callback);

    end

end


end % function


function edit_rmbg_regularization_Callback(src,~)
% Callback when you ask for a new value in SPM Interactive UI

% Check the reg value entered
reg = str2double(src.String);
if ~isscalar(reg) || reg<0 || isnan(reg)
    warning('wrong value : must be positive scalar');
    src.String = num2str(mp2rage_get_defaults('interactive.regularization'));
    reg = str2double(src.String);
end
fprintf('[%s]: new regularization = %g \n', mfilename, reg);

% Fetch inter data
UserData = src.UserData;

% Perform -----------------------------------------------------------------
fprintf('[%s]: computing new T1w \n', mfilename);
noiselevel = UserData.reg2noise(reg,UserData.Y_INV2);
Y_T1w = UserData.MP2RAGErobustfunc(UserData.Y_INV1, UserData.Y_INV2, noiselevel.^2);

fprintf('[%s]: saving volume ... ', mfilename);
Y_T1w = mp2rage_unscale_UNI( Y_T1w, UserData.integerformat );                                % Convert the final image to uint (if necessary)
UserData.V_out.descrip = sprintf('[mp2rage] background removed with regularization=%g',reg); % Prepare volume info
spm_write_vol(UserData.V_out,Y_T1w);                                                         % Write volume
fprintf('done => %s \n', UserData.V_out.fname);

pos = spm_orthviews('Pos');      % Get last cursor position
spm_orthviews('Reposition',pos); % Refresh the display @ last cursor position => this "reloads" the volume from disk

% Save changes
src.UserData = UserData;

end % function
