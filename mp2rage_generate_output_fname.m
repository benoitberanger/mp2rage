function fname = mp2rage_generate_output_fname( job, suffix )

if nargin < 2
    suffix = '';
end

field = ['output' suffix];

% put upstair the sub-fields
if isfield(job,'method')
    fieldname = fieldnames(job.method);
    fields = fieldnames(job.method.(fieldname{1}));
    for f = 1 : length(fields)
        job.(fields{f}) = job.method.(fieldname{1}).(fields{f});
    end
end

% 1)
if isfield(job.(field),'prefix')
    [pth,nam,~] = spm_fileparts(job.UNI{1}); % to strip the extension, if there is
    fname = spm_file(fullfile(pth,[nam '.nii']), 'prefix', job.(field).prefix);

    % 2)
elseif isfield(job.(field),'dirfile')
    [~,nam,~,~] = spm_fileparts(job.(field).dirfile.filename); % to strip the extension, if there is
    fname = char(fullfile(job.(field).dirfile.dirpath, [nam '.nii']));

    % 3)
elseif isfield(job.(field),'fullpathfilename')
    [pth,nam,~,~] = spm_fileparts(job.(field).fullpathfilename); % to strip the extension, if there is
    fname = char(fullfile(pth,[nam '.nii']));

    % 4)
elseif isfield(job.(field),'filename')
    [~,nam,~,~] = spm_fileparts(job.(field).filename); % to strip the extension, if there is
    fname = char([fullfile(pwd,nam) '.nii']);

end

end % function
