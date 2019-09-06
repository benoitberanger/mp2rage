function fname = mp2rage_gen_out_fname( job, suffix )

if nargin < 2
    suffix = '';
end

field = ['output' suffix];

% 1)
if isfield(job.(field),'prefix')
    [pathstr, name, ext] = spm_fileparts( job.UNI{1} );
    fname                = [pathstr filesep job.(field).prefix name ext];
    
    % 2)
elseif isfield(job.(field),'dirfile')
    fname = char(fullfile(job.(field).dirfile.dirpath, [job.(field).dirfile.filename '.nii']));
    
    % 3)
elseif isfield(job.(field),'fullpathfilename')
    fname = char([job.(field).fullpathfilename '.nii']);
    
    % 4)
elseif isfield(job.(field),'filename')
    fname = char([fullfile(pwd,job.(field).filename) '.nii']);
    
end

end % function
