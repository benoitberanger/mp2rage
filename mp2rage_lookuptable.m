function [Intensity, T1vector, IntensityBeforeComb] = mp2rage_lookuptable( estimateT1 )
%MP2RAGE_LOOKUPTABLE function will use mp2rage_solve_bloch to build the
%lookuptable between signal Intensity and the T1.
%
% This function is almost a copy-paste of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/MP2RAGE_lookuptable.m

invEFF = 1; % Inversion efficiency


%% Solve Bloch equations

T1vector = 0.01 : 0.01 : 5;

Signal = zeros(length(T1vector),2); % pre-allocation
for idx =  1 : length(T1vector)
    Signal(idx,1:2) = mp2rage_solve_bloch( estimateT1, T1vector(idx), invEFF);
end


%% Build the table

Intensity          = real(Signal(:,1).*conj(Signal(:,2))) ./ ( abs(Signal(:,1)).^2 + abs(Signal(:,2)).^2 ) ;

% Trick to make sure there is no flat part in the curve Intensity=f(T1vector)
% Solving https://github.com/benoitberanger/mp2rage/issues/5
dIntensity = diff(Intensity);
flat_idx = dIntensity == 0;
Intensity(flat_idx) = [];
T1vector (flat_idx) = [];

[ ~, minindex ]    = max(Intensity);
[ ~, maxindex ]    = min(Intensity);
Intensity          = Intensity(minindex:maxindex);
T1vector           = T1vector (minindex:maxindex);
Intensity([1 end]) = [0.5 -0.5]; % pads the look up table to avoid points that fall out ot the lookuptable

IntensityBeforeComb = Signal(minindex:maxindex,1,:);


end % function
