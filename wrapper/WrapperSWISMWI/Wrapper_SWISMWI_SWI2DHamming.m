%% [swi] = Wrapper_SWISMWI_SWI2DHamming(localField,mask,matrixSize,voxelSize,algorParam, headerAndExtraData)
%
% Input
% --------------
% phase         : wrapped phase, in rad
% magn          : magnitude image
% algorParam    : structure contains fields with algorithm-specific parameter(s)
% headerAndExtraData : structure contains extra header info/data for the algorithm
%
% Output
% --------------
% pSWI          : positive phase enhanced SWI
% nSWI          : negative phase enhanced SWI
% swi_phase     : high-pass filtered phase
% pswi_mIP      : minimum intensity projection with positive phased enhanced SWI
%
% Description: This is a wrapper function to access MEDI for SEPIA
%
% Kwok-shing Chan @ DCCN
% kwokshing.chan@donders.ru.nl
% Date created: 14 September 2021
% Date modified: 
%
%
function [swi_phase,pSWI,nSWI,pswi_mIP,nswi_mIP] = Wrapper_SWISMWI_SWI2DHamming(phase,magn,algorParam)
sepia_universal_variables;

% initiate non-essential output
pswi_mIP = [];
nswi_mIP = [];

% get algorithm parameters
algorParam = check_and_set_algorithm_default(algorParam);
filterSize  = algorParam.swi.filterSize;
thres       = algorParam.swi.threshold;
m           = algorParam.swi.m;
method      = algorParam.swi.method;
ismIP       = algorParam.swi.ismIP;
slice_mIP   = algorParam.swi.slice_mIP;
isPositive  = algorParam.swi.isPositive;
isNegative  = algorParam.swi.isNegative;


% add path
sepia_addpath;

%% SWI
disp('Computing SWI...');

[pSWI,nSWI,swi_phase] = swi(magn,phase,filterSize,thres,m,method);

% minimum intensity projection
if ismIP
    if isPositive
        pswi_mIP = zeros(size(swi_phase));
        for kz = 1:size(swi_phase,3) - slice_mIP
            pswi_mIP(:,:,kz,:) = min(pSWI(:,:,kz:kz+slice_mIP-1,:),[],3);
        end
    end
    
    if isNegative
        nswi_mIP = zeros(size(swi_phase));
        for kz = 1:size(swi_phase,3) - slice_mIP
            nswi_mIP(:,:,kz,:) = min(nSWI(:,:,kz:kz+slice_mIP-1,:),[],3);
        end
    end
end


end

%% set default parameter for unspecific input
function algorParam2 = check_and_set_algorithm_default(algorParam)

algorParam2 = algorParam;

try algorParam2.swi.filterSize	= algorParam.swi.filterSize;	catch; algorParam2.swi.filterSize	= 12;	end
try algorParam2.swi.threshold   = algorParam.swi.threshold;     catch; algorParam2.swi.threshold    = pi;	end
try algorParam2.swi.m           = algorParam.swi.m;             catch; algorParam2.swi.m            = 4;	end
try algorParam2.swi.ismIP   	= algorParam.swi.ismIP;         catch; algorParam2.swi.ismIP        = true;	end
try algorParam2.swi.slice_mIP  	= algorParam.swi.slice_mIP; 	catch; algorParam2.swi.slice_mIP	= 4;	end
try algorParam2.swi.isPositive	= algorParam.swi.isPositive; 	catch; algorParam2.swi.isPositive	= true;	end
try algorParam2.swi.isNegative	= algorParam.swi.isNegative; 	catch; algorParam2.swi.isNegative	= false;end
try algorParam2.swi.method      = algorParam.swi.method;        catch; algorParam2.swi.method       = 'default';end

end