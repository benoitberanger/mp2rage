function mp2rage_rmbg(varargin)
%MP2RAGE_RMBG Executable job that removes background noise for mp2rage UNI image.
% The core code of this function is an implementation of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/RobustCombination.m
% Based on the article http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0099676


%% Fetch job 

rmbg = varargin{1};


%% Load volumes

V_INV1 = spm_vol(rmbg.INV1{1});
Y_INV1 = double(spm_read_vols(V_INV1));

V_INV2 = spm_vol(rmbg.INV2{1});
Y_INV2 = double(spm_read_vols(V_INV2));

V_UNI = spm_vol(rmbg.UNI{1});
Y_UNI = double(spm_read_vols(V_UNI));


%% Prepare some local functions

MP2RAGErobustfunc = @(INV1,INV2,beta) (conj(INV1).*INV2-beta)./(INV1.^2+INV2.^2+2*beta);
rootsquares_pos   = @(a,b,c)          (-b+sqrt(b.^2 -4 *a.*c))./(2*a);
rootsquares_neg   = @(a,b,c)          (-b-sqrt(b.^2 -4 *a.*c))./(2*a);


%% converts MP2RAGE to -0.5 to 0.5 scale

if min(Y_UNI(:))>=0 && max(Y_UNI(:))>=0.51
    % converts MP2RAGE to -0.5 to 0.5 scale - assumes that it is getting only
    % positive values
    Y_UNI = (Y_UNI- max(Y_UNI(:))/2)./max(Y_UNI(:));
    integerformat=1;
else
    integerformat=0;
end


%% Computes correct INV1 dataset  

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


%% lambda calculation

% "usually the multiplicative factor shouldn't be greater then 10, but that
% is not the case when the image is bias field corrected, in which case the
% noise estimated at the edge of the image might not be such a good
% measure"

noiselevel = rmbg.regularization * mean(mean(mean( Y_INV2(1:end,end-10:end,end-10:end) )));

Y_T1w = MP2RAGErobustfunc(Y_INV1, Y_INV2, noiselevel.^2);


%% Convert the final image to uint (if necessary)

if integerformat
    Y_T1w = round( 4095*(Y_T1w+0.5) );
end


%% Save volume

% Prepare volume info
V_out                = V_UNI; % copy info from UNI image
[pathstr, name, ext] = fileparts( V_out.fname );
V_out.fname          = [pathstr filesep rmbg.prefix name ext];
V_out.descrip        = sprintf('MP2RAGE background removed with regularization=%g',rmbg.regularization);

% Write volume
spm_write_vol(V_out,Y_T1w);


%% Prepare command line to check the results with spm_check_registration

spm_check_registration( V_UNI.fname, V_out.fname )


end % function
