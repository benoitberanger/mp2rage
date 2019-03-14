function Y = mp2rage_unscale_UNI( Y, integerformat )
%MP2RAGE_UNSCALE_UNI converts back MP2RAGE from -0.5 to 0.5 scale to 0 4095, if necessary

if integerformat
    Y = round( 4095*(Y+0.5) );
end

end % end
