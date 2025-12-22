function [Intensity, T1vector, B1vector] = mp2rage_lookuptable( paramters, B1correction )
%MP2RAGE_LOOKUPTABLE function will use mp2rage_solve_bloch to build the
%lookuptable between signal Intensity and the T1.
%
% This function is almost a copy-paste of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/MP2RAGE_lookuptable.m

invEFF = 1; % Inversion efficiency

if nargin < 2
    B1correction = false;
end


%% Solve Bloch equations

T1vector = 0.01 : 0.01 : 5;

if B1correction
    B1vector = 0.01 : 0.01 : 2.00;
else
    B1vector = 1;
end

Signal = zeros(length(T1vector),length(B1vector),2); % pre-allocation
for idx1 = 1 : length(T1vector)
    for idx2 = 1 : length(B1vector)
        Signal(idx1,idx2,1:2) = mp2rage_solve_bloch( paramters, T1vector(idx1), B1vector(idx2), invEFF);
    end
end


%% Build the table

Intensity = real(Signal(:,:,1).*conj(Signal(:,:,2))) ./ ( abs(Signal(:,:,1)).^2 + abs(Signal(:,:,2)).^2 ) ;


end % function
