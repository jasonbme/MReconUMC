classdef SCPars < dynamicprops & deepCopyable
% 20161206 - Introduce all parameters that are related to system
% corrections.

properties
    CalibrationData
    GradientDelayCorrection
    GradientDelays
    NoiseData
    NoisePreWhitening
    NoiseDecorrelationMtx
    NoiseCorrelationMtx
    NumberOfCalibrationSpokes
    PhaseCorrection
    PhaseCorrection_model_parameters
    GIRF
    GIRF_preemphasis
    GIRF_preemphasis_bw
    GIRF_vis
    GIRF_nominaltraj
    GIRF_frequencies
    GIRF_ADC_time
    GIRF_delaytime
    GIRF_time
    GIRF_transfer_function
    GIRF_input_waveforms
    GIRF_output_waveforms
end
methods
    function SC = SCPars()   
        SC.CalibrationData=[];
        SC.NumberOfCalibrationSpokes=0;
        SC.PhaseCorrection='zero'; % 'model', 'zero','none', 'model_interpolation'
        SC.PhaseCorrection_model_parameters=[];
        SC.GradientDelayCorrection='no'; % 'autocalibration', 'calibration', 'none'
        SC.GradientDelays=[];
        SC.GIRF='no'; 
        SC.NoisePreWhitening='no';
        SC.NoiseData=[];
        SC.NoiseDecorrelationMtx=[];
        SC.NoiseCorrelationMtx=[];
        SC.GIRF_vis='no';
        SC.GIRF_nominaltraj='no';
        SC.GIRF_frequencies=[];
        SC.GIRF_ADC_time=[];
        SC.GIRF_time=[];
        SC.GIRF_delaytime=0; % usec
        SC.GIRF_preemphasis='no';
        SC.GIRF_preemphasis_bw=40000;
        SC.GIRF_transfer_function=[];
        SC.GIRF_input_waveforms=[];
        SC.GIRF_output_waveforms=[];
    end
end

% END
end
