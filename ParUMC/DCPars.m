classdef DCPars < dynamicprops & deepCopyable
%% Data Correction related parameters
properties
    CalibrationData
    GIRF
    GIRFNumberOfAverages
    GradientDelayCorrection
    NumberOfCalibrationSpokes
    PhaseCorrection
    YGradientDelay
    ZGradientDelay
end
methods
    function DC = DCPars()   
        DC.CalibrationData=[];
        DC.NumberOfCalibrationSpokes=0;
        DC.PhaseCorrection='zero'; % 'fit', 'zero','none'
        DC.GradientDelayCorrection='none'; % 'sweep', 'smagdc', 'none'
        DC.GIRF='no'; 
        DC.GIRFNumberOfAverages=0;
	DC.YGradientDelay=[];
	DC.ZGradientDelay=[];
    end
end

% END
end
