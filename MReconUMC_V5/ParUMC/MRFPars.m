classdef MRFPars < dynamicprops & deepCopyable
%Declare all parameters related to MR fingerprinting. The data is slightly
% different oriented, e.g. always 1000 dynamics and requires an additional
% dictionary matching step at the end.
% 
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    Fingerprinting % |YesNo|
    Dictionary % |String| Location of the dictionary (.mat file)
    QuantitativeMaps % |Matrix| Quantitative maps result
end

%% Set default values
methods
    function MRF = MRFPars()   
        MRF.Fingerprinting='no';
        MRF.Dictionary='';
        MRF.QuantitativeMaps=[];
    end
end

% END
end