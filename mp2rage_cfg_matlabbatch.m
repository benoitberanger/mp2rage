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
rmbg_regularization.def     = @(val) mp2rage_get_defaults('rmbg.regularization', val{:});

%--------------------------------------------------------------------------
% rmbg_show
%--------------------------------------------------------------------------
rmbg_show        = cfg_menu;
rmbg_show.tag    = 'show';
rmbg_show.name   = 'Desplay resulst with SPM checkreg';
rmbg_show.labels = {'Yes', 'No'};
rmbg_show.values = {'yes', 'no'};
rmbg_show.val    = {'yes'};
rmbg_show.help   = {
    'Display the UNI image and the freshly calculated denoised image'
    'Display both images using ''spm_check_registration'''
    ''
    };

%--------------------------------------------------------------------------
% rmbg_output
%--------------------------------------------------------------------------
rmbg_output = mp2rage_matlabbatch_job_output( 'rmbg.output' );

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
    };
rmbg.val  = { rmbg_INV1 rmbg_INV2 rmbg_UNI rmbg_regularization rmbg_output rmbg_show };
rmbg.prog = @prog_rmbg;
rmbg.vout = @vout_rmbg;


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


%% Estimate T1

%--------------------------------------------------------------------------
% estimateT1_UNI
%--------------------------------------------------------------------------
estimateT1_UNI         = cfg_files;
estimateT1_UNI.tag     = 'UNI';
estimateT1_UNI.name    = 'UNI Image';
estimateT1_UNI.help    = {
    'T1 weighted image with "salt and papper" background noise'
    ''
    };
estimateT1_UNI.filter  = 'image';
estimateT1_UNI.ufilter = '.*';
estimateT1_UNI.num     = [1 1];

%--------------------------------------------------------------------------
% estimateT1_B0
%--------------------------------------------------------------------------
estimateT1_B0         = cfg_entry;
estimateT1_B0.tag     = 'B0';
estimateT1_B0.name    = 'Magnetic field strengh B0 (T)';
estimateT1_B0.help    = {
    'In Tesla (T)'
    ''
    };
estimateT1_B0.strtype = 'r';   % real number
estimateT1_B0.num     = [1 1]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_ES
%--------------------------------------------------------------------------
estimateT1_TR         = cfg_entry;
estimateT1_TR.tag     = 'TR';
estimateT1_TR.name    = 'MP2RAGE TR (s)';
estimateT1_TR.help    = {
    'In seconds (s)'
    ''
    'Repetition time (TR) of the MP2RAGE'
    ''
    };
estimateT1_TR.strtype = 'r';   % real number
estimateT1_TR.num     = [1 1]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_ES
%--------------------------------------------------------------------------
estimateT1_ES         = cfg_entry;
estimateT1_ES.tag     = 'EchoSpacing';
estimateT1_ES.name    = 'EchoSpacing (s)';
estimateT1_ES.help    = {
    'In seconds (s)'
    ''
    'TR of the GRE readout'
    'On Siemens scanners, this is called EchoSpacing.'
    ''
    };
estimateT1_ES.strtype = 'r';   % real number
estimateT1_ES.num     = [1 1]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_TI
%--------------------------------------------------------------------------
estimateT1_TI         = cfg_entry;
estimateT1_TI.tag     = 'TI';
estimateT1_TI.name    = 'Inversion Times (s)';
estimateT1_TI.help    = {
    'In seconds (s)'
    'such as [ TI1 TI2 ]'
    ''
    };
estimateT1_TI.strtype = 'r';   % real number
estimateT1_TI.num     = [1 2]; % 1 x 2 vector

%--------------------------------------------------------------------------
% estimateT1_FA
%--------------------------------------------------------------------------
estimateT1_FA         = cfg_entry;
estimateT1_FA.tag     = 'FA';
estimateT1_FA.name    = 'Flip Angles (°)';
estimateT1_FA.help    = {
    'In degree (°)'
    'such as [ FA1 FA2 ]'
    ''
    };
estimateT1_FA.strtype = 'r';   % real number
estimateT1_FA.num     = [1 2]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_nrSlices
%--------------------------------------------------------------------------
estimateT1_nrSlices         = cfg_entry;
estimateT1_nrSlices.tag     = 'nrSlices';
estimateT1_nrSlices.name    = 'Number of slices per slab';
estimateT1_nrSlices.help    = {
    'Number of slices per slab'
    ''
    };
estimateT1_nrSlices.strtype = 'n';   % real number
estimateT1_nrSlices.num     = [1 1]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_PF
%--------------------------------------------------------------------------
estimateT1_PF         = cfg_entry;
estimateT1_PF.tag     = 'PartialFourierInSlice';
estimateT1_PF.name    = 'PartialFourierInSlice';
estimateT1_PF.help    = {
    'The value range is 0 to 1'
    ''
    'On Siemens scanner, it is expressed as a fraction such as 8/8, 7/8, ...'
    'On Siemens scanner, it corresponds to SlicePartialFourier, ant not PhasePartialFourier'
    ''
    };
estimateT1_PF.strtype = 'r';   % real number
estimateT1_PF.num     = [1 1]; % only a scalar

%--------------------------------------------------------------------------
% estimateT1_fatsat
%--------------------------------------------------------------------------
estimateT1_fatsat        = cfg_menu;
estimateT1_fatsat.tag    = 'FatSat';
estimateT1_fatsat.name   = 'Fat saturation pulse';
estimateT1_fatsat.labels = {'No', 'Yes'};
estimateT1_fatsat.values = {'no', 'yes'};
estimateT1_fatsat.help   = {
    'On Siemens scanner, this option is in the tab Contrast > Fat Sat'
    'On Siemens scanner, the option can be "none", "water excitation normal", "water excitation fast"'
    ''
    };

%--------------------------------------------------------------------------
% estimateT1_outputT1
%--------------------------------------------------------------------------
estimateT1_outputT1 = mp2rage_matlabbatch_job_output( 'estimateT1.outputT1', 'T1' );

%--------------------------------------------------------------------------
% estimateT1_outputR1
%--------------------------------------------------------------------------
estimateT1_outputR1 = mp2rage_matlabbatch_job_output( 'estimateT1.outputR1', 'R1' );

%--------------------------------------------------------------------------
% estimateT1
%--------------------------------------------------------------------------

estimateT1 = cfg_exbranch;
estimateT1.tag  = 'estimateT1';
estimateT1.name = 'Estimate T1';
estimateT1.help = {
    'Based on https://github.com/JosePMarques/MP2RAGE-related-scripts, this job will use the UNI image and sequence paramters to estimate the T1map.'
    'http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676'
    ''
    'The outputs are T1map (in second) and R1map (in 1/second)'
    ''
    };
estimateT1.val  = {
    estimateT1_UNI ... % UNI image
    estimateT1_B0 estimateT1_TR estimateT1_ES estimateT1_TI estimateT1_FA estimateT1_nrSlices estimateT1_PF estimateT1_fatsat ... % sequence paramters
    estimateT1_outputT1 estimateT1_outputR1 ... % outputs
    };
estimateT1.prog = @prog_estimateT1;
estimateT1.vout = @vout_estimateT1;


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
mp2rage.values  = { rmbg irmbg estimateT1 };


end % function mp2rage_cfg_matlabbatch


%==========================================================================
% rmbg
%==========================================================================

function out = prog_rmbg( job )

fname = mp2rage_generate_output_fname( job );

out       = struct;
out.files = {fname};

job.fname = fname;
mp2rage_main_remove_background(job);

end % function

function dep = vout_rmbg( ~ )

dep            = cfg_dep;
dep.sname      = 'Background free image';
dep.src_output = substruct('.','files');
dep.tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

end % function


%==========================================================================
% estimateT1
%==========================================================================

function out = prog_estimateT1( job )

fname_T1 = mp2rage_generate_output_fname( job, 'T1' );
fname_R1 = mp2rage_generate_output_fname( job, 'R1' );

out       = struct;
out.files = {fname_T1 fname_R1};

job.fname_T1 = fname_T1;
job.fname_R1 = fname_R1;
mp2rage_main_estimate_T1(job);

end % function

function dep = vout_estimateT1( ~ )

dep               = cfg_dep;

dep(1).sname      = 'T1 image';
dep(1).src_output = substruct('.','files','()',{1});
dep(1).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});


dep(2).sname      = 'R1 image';
dep(2).src_output = substruct('.','files','()',{2});
dep(2).tgt_spec   = cfg_findspec({{'filter','image','strtype','e'}});

end % function

