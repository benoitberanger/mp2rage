function default = mp2rage_get_defaults(defstr)
%MP2RAGE_GET_DEFAULTS Get the defaults values associated with an identifier
%
% Example : reg    = mp2rage_get_defaults('rmbg.regularisation')
%           alldef = mp2rage_get_defaults
%
% See also mp2rage_defaults

% Get all defaults parameters
mp = mp2rage_defaults;

if nargin == 0
    default = mp;
    return
end

% Construct subscript reference struct from dot delimited tag string
tags = textscan(defstr,'%s', 'delimiter','.');
subs = struct('type','.','subs',tags{1}');

% Fetch
default = subsref(mp, subs);

end % function
