function [ Y, integerformat ] = mp2rage_scale_UNI( Y )
%MP2RAGE_SCALE_UNI converts MP2RAGE to -0.5 to 0.5 scale, if necessary

if min(Y(:))>=0 && max(Y(:))>=0.51
    % converts MP2RAGE to -0.5 to 0.5 scale - assumes that it is getting only positive values
    Y = (Y- max(Y(:))/2)./max(Y(:));
    integerformat=1;
else
    integerformat=0;
end

end % end
