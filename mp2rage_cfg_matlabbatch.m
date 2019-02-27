function mp2rage = mp2rage_cfg_matlabbatch
%MP2RAGE_CFG_MATLABBATCH is the configurarion file for all jobs of the mp2rage branch
% This file is executed by spm job/batch system
%
% See also spm_cfg


%% Batch configuration

% Add the extension/toolbox in matlab path
addpath(fileparts(mfilename('fullpath')));


%% Remove background

%--------------------------------------------------------------------------
% rmbg_INV1
%--------------------------------------------------------------------------
rmbg_INV1         = cfg_files;
rmbg_INV1.tag     = 'INV1';
rmbg_INV1.name    = 'INV1 Image';
rmbg_INV1.help    = {
    'First inversion image'
    ''
    };
rmbg_INV1.filter  = 'image';
rmbg_INV1.ufilter = '.*';
rmbg_INV1.num     = [1 1];
% rmbg_INV1.preview = @(f) spm_image('Display',char(f));
% rmbg_INV1.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% rmbg_INV2
%--------------------------------------------------------------------------
rmbg_INV2         = cfg_files;
rmbg_INV2.tag     = 'INV2';
rmbg_INV2.name    = 'INV2 Image';
rmbg_INV2.help    = {
    'Second inversion image'
    ''
    };
rmbg_INV2.filter  = 'image';
rmbg_INV2.ufilter = '.*';
rmbg_INV2.num     = [1 1];
% rmbg_INV2.preview = @(f) spm_image('Display',char(f));
% rmbg_INV2.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% rmbg_UNI
%--------------------------------------------------------------------------
rmbg_UNI         = cfg_files;
rmbg_UNI.tag     = 'UNI';
rmbg_UNI.name    = 'UNI Image';
rmbg_UNI.help    = {
    'T1 weighted image with "salt and papper" background noise'
    ''
    };
rmbg_UNI.filter  = 'image';
rmbg_UNI.ufilter = '.*';
rmbg_UNI.num     = [1 1];
% rmbg_UNI.preview = @(f) spm_image('Display',char(f));
% rmbg_UNI.preview = @(f) spm_check_registration(char(f));

%--------------------------------------------------------------------------
% rmbg_regularization
%--------------------------------------------------------------------------
rmbg_regularization         = cfg_entry;
rmbg_regularization.tag     = 'regularization';
rmbg_regularization.name    = 'Regulirizaton noise factor';
rmbg_regularization.help    = {
    'Regulirizaton noise factor'
    'The bigger the more background noise is removed, but more intensity bias is introduced.'
    ''
    'scalar : natural number (1..n)'
    ''
    };
rmbg_regularization.strtype = 'n';   % natural number (1..n)
rmbg_regularization.num     = [1 1]; % only a scalar
rmbg_regularization.def     = @(val)mp2rage_get_defaults('rmbg.regularization', val{:});

%--------------------------------------------------------------------------
% rmbg_prefix
%--------------------------------------------------------------------------
rmbg_prefix         = cfg_entry;
rmbg_prefix.tag     = 'prefix';
rmbg_prefix.name    = 'Filename Prefix';
rmbg_prefix.help    = {
    'String to be prepended to the filename of background-removed file.'
    ''
    };
rmbg_prefix.strtype = 's'; % string
rmbg_prefix.num     = [1 Inf];
rmbg_prefix.def     = @(val)mp2rage_get_defaults('rmbg.prefix', val{:});

%--------------------------------------------------------------------------
% rmbg_show
%--------------------------------------------------------------------------
rmbg_show        = cfg_menu;
rmbg_show.tag    = 'show';
rmbg_show.name   = 'Desplay resulst with SPM checkreg';
rmbg_show.labels = {'Yes', 'No'};
rmbg_show.values = {'Yes', 'No'};
rmbg_show.val    = {'Yes'};
rmbg_show.help   = {
    'Display the UNI image and the freshly calculated denoised image'
    'To display both images using ''spm_check_registration'''
    ''
    };

%--------------------------------------------------------------------------
% rmbg
%--------------------------------------------------------------------------
rmbg      = cfg_exbranch;
rmbg.tag  = 'rmbg';
rmbg.name = 'Remove background';
rmbg.help = {
    'Based on https://github.com/JosePMarques/MP2RAGE-related-scripts, this job will remove backgorund noise from the UNI image.'
    'http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676'
    ''
    'The output will be in the same directory as UNI image, with the name = prefix + "same name as UNI image"'
    ''
    };
rmbg.val  = { rmbg_INV1 rmbg_INV2 rmbg_UNI rmbg_regularization rmbg_prefix rmbg_show };
rmbg.prog = @mp2rage_rmbg;


%% Interactive Remove background

%--------------------------------------------------------------------------
% irmbg
%--------------------------------------------------------------------------
irmbg = rmbg; % Copy it, ...
% ... then change what is necessay
irmbg.name = 'Interactive remove background';
irmbg.tag  = 'irmbg';
irmbg.help = {
    'With this job, you will be able to select a noise regularization level interactively'
    ''
    };
irmbg.val{end}.labels = {'Yes - interactive'};
irmbg.val{end}.values = {'Interactive'};
irmbg.val{end}.val    = {'Interactive'};


%% Main

%--------------------------------------------------------------------------
% mp2rage : main
%--------------------------------------------------------------------------
% This is the menue on the batch editor : SPM > Tools > MP2RAGE
mp2rage        = cfg_choice;
mp2rage.tag    = 'mp2rage';
mp2rage.name   = 'MP2RAGE';
mp2rage.help   = {
    'This extension is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts'
    };
mp2rage.values  = { rmbg irmbg };
% mp2rage.prog = @run_mp2rage;
% mp2rage.vout = @vout_mp2rage;


end % function

% %==========================================================================
% % run_mp2rage
% %==========================================================================
% function out = run_mp2rage( job )
%
% out = job;
%
% end % end

% %==========================================================================
% % vout_mp2rage
% %==========================================================================
% function out = vout_mp2rage( job )
%
% out = job;
%
% end % end
