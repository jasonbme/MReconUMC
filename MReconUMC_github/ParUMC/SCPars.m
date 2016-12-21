classdef SCPars < dynamicprops & deepCopyable
% 20161206 - Introduce all parameters that are related to system
% corrections.

properties
    CalibrationData
    GradientDelayCorrection
    NumberOfCalibrationSpokes
    PhaseCorrection
    GradientDelays
end
methods
    function SC = SCPars()   
        SC.CalibrationData=[];
        SC.NumberOfCalibrationSpokes=0;
        SC.PhaseCorrection='zero'; % 'fit', 'zero','none'
        SC.GradientDelayCorrection='none'; % 'sweep', 'smagdc', 'none'
        SC.GradientDelays=[];
    end
end

% END
end
