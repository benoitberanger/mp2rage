function signal = mp2rage_solve_bloch( estimateT1, T1, invEFF )
%MP2RAGE_SOLVE_BLOCH function solves Bloch equations for the MP2RAGE pulse
%seqeunce. This process uses the sequence paramteres and the T1 of a the
%tissue, and compute the signal as output.
% MP2RAGE_SOLVE_BLOCH is used to build a lookuptable to associate a MP2RAGE
% UNI image signal value to a T1 value.
%
% This function is almost a copy-paste of https://github.com/JosePMarques/MP2RAGE-related-scripts/blob/master/func/MPRAGEfunc.m

nImages = 2; % INV1 & INV2


%% Link my inputs to the function variables

MPRAGE_tr      = estimateT1.TR;
B0             = estimateT1.B0;
inversiontimes = estimateT1.TI;
nZslices       = estimateT1.nrSlices * [ estimateT1.PartialFourierInSlice*0.5 0.5 ];
FLASH_tr       = estimateT1.EchoSpacing;
flipangle      = estimateT1.FA;
sequence       = estimateT1.FatSat;


%% This part bellow is mostly from the original function
% I didn't rewrite the equation, only the typo


%% Prepare some paramterts


% Fat saturation ?
%--------------------------------------------------------------------------
if strcmpi(sequence,'no')
    normalsequence  = true;
    waterexcitation = false;
else
    normalsequence  = false;
    waterexcitation = true;
    FatWaterCSppm   = 3.3;    % ppm
    gamma           = 42.576; % MHz/T
    pulseSpace      = 1/2/(FatWaterCSppm*B0*gamma);
    
end


% Convert Flip Angles from degree to radian
%--------------------------------------------------------------------------
fliprad = flipangle/180*pi; % Conversion from degrees to radians


% Inversion Efficiency
%--------------------------------------------------------------------------
% ideally invEFF=1;
if nargin < 3
    invEFF=0.96; % Inversion efficiency of the Siemens MP2RAGE PULSE
end


% Slices
%--------------------------------------------------------------------------
nZ_bef   = nZslices(1);
nZ_aft   = nZslices(2);
nZslices = sum( nZslices );


%% Calculating the relevant timing and associated values

if normalsequence
    
    E_1    = exp( -FLASH_tr/T1 ); % recovery between two excitaion
    
    TA     = nZslices * FLASH_tr;
    TA_bef = nZ_bef   * FLASH_tr;
    TA_aft = nZ_aft   * FLASH_tr;
    
    TD  (1)         =             inversiontimes(1)       - TA_bef;
    TD  (nImages+1) = MPRAGE_tr - inversiontimes(nImages) - TA_aft;
    E_TD(1)         = exp( -TD(1)        /T1 );
    E_TD(nImages+1) = exp( -TD(nImages+1)/T1 );
    
    if nImages > 1
        for iImages = 2 : nImages
            TD  (iImages) = inversiontimes(iImages) - inversiontimes(iImages-1) - TA;
            E_TD(iImages) = exp( -TD(iImages)/T1 );
        end
    end
    
    [ cosalfaE1, oneminusE1, sinalfa ] = deal(zeros(1,nImages)); % pre-allocation
    for iImages = 1 : nImages
        cosalfaE1 (iImages) = cos( fliprad(iImages) ) * E_1;
        oneminusE1(iImages) = 1 - E_1;
        sinalfa   (iImages) = sin( fliprad(iImages) );
    end
    
end

if waterexcitation
    
    E_1  = exp( -FLASH_tr              / T1   );
    E_1A = exp( -pulseSpace            / T1   );
    E_2A = exp( -pulseSpace            / 0.06 ); % 60ms is an extimation of the T2star.. not very relevant
    E_1B = exp( -(FLASH_tr-pulseSpace) / T1   );
    
    TA     = nZslices * FLASH_tr;
    TA_bef = nZ_bef   * FLASH_tr;
    TA_aft = nZ_aft   * FLASH_tr;
    
    TD  (1)         =             inversiontimes(1)       - TA_bef;
    TD  (nImages+1) = MPRAGE_tr - inversiontimes(nImages) - TA_aft;
    E_TD(1)         = exp( -TD(1)        /T1 );
    E_TD(nImages+1) = exp( -TD(nImages+1)/T1 );
    
    if nImages > 1
        for iImages = 2 : nImages
            TD  (iImages) = inversiontimes(iImages) - inversiontimes(iImages-1) - TA;
            E_TD(iImages) = exp (-TD(iImages)/T1 );
        end
    end
    
    for iImages = 1 : nImages
        cosalfaE1 (iImages) = ( cos( fliprad(iImages)/2 ) )^ 2 * (E_1A * E_1B) - ( sin( fliprad(iImages)/2 ) )^2 * ( E_2A * E_1B );
        oneminusE1(iImages) = (1 - E_1A) * cos( fliprad(iImages)/2 ) * E_1B + (1 - E_1B);
        sinalfa   (iImages) = sin( fliprad(iImages)/2 ) * cos( fliprad(iImages)/2 ) * (E_1A + E_2A);
    end
    
end


%% Steady state calculation

M0 = 1;

MZss_num = M0 * (1 - E_TD(1));

for iImages = 1 : nImages
    
    % term relative to the image aquisition
    MZss_num = MZss_num * ( cosalfaE1(iImages) )^nZslices    +    M0 * (1 - E_1) * (1 - ( cosalfaE1(iImages) )^nZslices) / (1 - cosalfaE1(iImages));
    
    % term for the relaxation time after it
    MZss_num = MZss_num * E_TD(iImages+1)   +   M0 * (1 - E_TD(iImages+1));
    
end

MZss_den = 1 + invEFF * ( prod(cosalfaE1) )^nZslices * prod(E_TD);

MZss = MZss_num / MZss_den;


%% Signal

signal = zeros(1,nImages);% pre-allocation

iImages = 1;

temp      = (-invEFF * MZss * E_TD(1) + M0 * (1 - E_TD(1))) * ( cosalfaE1(iImages) )^nZ_bef   +   M0 * (1 - E_1) * (1 - ( cosalfaE1(iImages) )^nZ_bef) / (1 - cosalfaE1(iImages));
signal(1) = sinalfa(iImages) * temp ;

if nImages > 1
    for iImages = 2 :(nImages)
        temp = temp * ( cosalfaE1(iImages-1) )^nZ_aft   +   M0 * (1 - E_1) * (1 - ( cosalfaE1(iImages-1) )^nZ_aft) / (1 - cosalfaE1(iImages-1));
        temp = (temp * E_TD(iImages) + M0 * (1-E_TD(iImages))) * ( cosalfaE1(iImages) )^nZ_bef   +   M0 * (1 - E_1) * (1 - ( cosalfaE1(iImages) )^(nZ_bef)) / (1 - cosalfaE1(iImages));
        
        signal(iImages) = sinalfa(iImages) * temp;
    end
end


end % function
