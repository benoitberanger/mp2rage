function output = mp2rage_matlabbatch_job_output( job_name, display_name )

if nargin < 2
    display_name = '';
end

%--------------------------------------------------------------------------
% prefix
%--------------------------------------------------------------------------
prefix         = cfg_entry;
prefix.tag     = 'prefix';
prefix.name    = '1) Filename Prefix';
prefix.help    = {
    'String to be prepended to the filename of background-removed file.'
    ''
    };
prefix.strtype = 's'; % string
prefix.num     = [1 Inf];
prefix.def     = @(val) mp2rage_get_defaults([job_name '.prefix'], val{:});

%--------------------------------------------------------------------------
% filename
%--------------------------------------------------------------------------
filename         = cfg_entry;
filename.tag     = 'filename';
filename.name    = 'Output Filename';
filename.help    = {
    'Output Filename'
    ''
    };
filename.strtype = 's';
filename.num     = [1 Inf];
filename.def     = @(val) mp2rage_get_defaults([job_name '.filename'], val{:});

%--------------------------------------------------------------------------
% directory
%--------------------------------------------------------------------------
directory         = cfg_files;
directory.tag     = 'dirpath';
directory.name    = 'Output Directory';
directory.help    = {
    'Output Directory'
    ''
    };
directory.filter  = 'dir';
directory.ufilter = '.*';
directory.num     = [1 1];

%--------------------------------------------------------------------------
% dirfile
%--------------------------------------------------------------------------
dirfile         = cfg_branch;
dirfile.tag     = 'dirfile';
dirfile.name    = '2) Other dirirectory + filename';
dirfile.help    = {
    'Define output directory and the output filename'
    ''
    };
dirfile.val  = { directory filename };

%--------------------------------------------------------------------------
% fullpath
%--------------------------------------------------------------------------
fullpath         = cfg_entry;
fullpath.tag     = 'fullpathfilename';
fullpath.name    = '3) Output fullpath Filename';
fullpath.help    = {
    'Output fullpath Filename, such as /path/to/filename'
    ''
    };
fullpath.strtype = 's';
fullpath.num     = [1 Inf];

%--------------------------------------------------------------------------
% file
%--------------------------------------------------------------------------
file         = cfg_entry;
file.tag     = 'filename';
file.name    = '4) Output Filename';
file.help    = {
    'This file will be written in the current directory'
    ''
    };
file.strtype = 's';
file.num     = [1 Inf];
file.def     = @(val) mp2rage_get_defaults([job_name '.filename'], val{:});

%--------------------------------------------------------------------------
% output
%--------------------------------------------------------------------------
output        = cfg_choice;
output.tag    = ['output' display_name];
output.name   = ['Output style : ' display_name];
output.help   = {
    '1) Output is written in the same dir as the UNI image and prepend with a prefix.'
    '   out = prefix + UNI file, written in UNI directory'
    ''
    '2) Output is defined by outdir + outfilename'
    '   out = fullfile(''outdir'',''outfilename'')'
    ''
    '3) Output is defined by fullpath-filename'
    '   out = ''/path/to/filename'''
    ''
    '4) Output is defined by filename, written in the current directory'
    '   out = fullfile(pwd,''outfilename'')'
    ''
    };
output.val    = { prefix };
output.values = { prefix dirfile fullpath file };

end % function
