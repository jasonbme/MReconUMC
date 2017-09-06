classdef SCPars < dynamicprops & deepCopyable
%Declares all parameters related to system corrections, which include noise
% prewhitening, phase correction, delay corrections and gradient impulse
% response functions.
% 
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    GradientDelayCorrection % |String| 'autocalibration','calibration'or 'no' Enable/disable gradient delay correction
    PhaseCorrection % |String| 'model','zero','no','model_interpolation','zero_interpolation' see radial_phasecorrection.m for more info
    Girf % |YesNo| Enable/disable gradient impulse response function
    GirfNominalTrajectory % |YesNo| Use nominal trajectory derived from gradient waveforms
    NoisePreWhitening % |YesNo| Perform noise prewhitening based on noise samples
end

%% Parameters that are extracted from PPE 
properties ( Hidden )
    CalibrationData % |Matri| Containing radial calibration spokes or epi calibration data
    NoiseData % |Matrix| Noise samples taken from every scan
    NoiseDecorrelationMtx % |Matrix| Matrix containing the noise decorrelation coefficients
    NoiseCorrelationMtx % |Matrix| Noise covariance matrix
    NumberOfCalibrationSpokes % |Integer| Number of calibration spokes used for radial
    PhaseCorrectionModelParameters % |Matrix| Fitted parameters for model based radial phase correction
    PhaseErrorMatrix
    GradientDelays % |Array| Estimated gradient delays expressed in sample points in k-space
    GirfFrequency % |Array| Frequencies of the gradient impulse response coefficients
    GirfADCTime % |Array| Timepoints where samples are taken after center of RF-pulse
    GirfTime % |Array| Timepoints of the girf corrected gradient waveform
    GirfTransferFunction % |Array| Coefficients of the gradient impulse response
    GirfZerothFrequency
    GirfZeroth
    NominalWaveform % |Matrix| Theoretical gradient waveform extracted from PPE
    GirfWaveform % |Matrix| Girf corrected gradient waveform
end

%% Set default values
methods
    function SC = SCPars()   
        SC.CalibrationData=[];
        SC.NumberOfCalibrationSpokes=0;
        SC.PhaseCorrection='zero';
        SC.PhaseCorrectionModelParameters=[];
        SC.PhaseErrorMatrix=[];
        SC.GradientDelayCorrection='no'; 
        SC.GradientDelays=[];
        SC.Girf='no'; 
        SC.NoisePreWhitening='no';
        SC.NoiseData=[];
        SC.NoiseDecorrelationMtx=[];
        SC.NoiseCorrelationMtx=[];
        SC.GirfNominalTrajectory='no';
        SC.GirfFrequency=[];
        SC.GirfADCTime=[];
        SC.GirfTime=[];
        SC.GirfTransferFunction=[];
        SC.GirfZeroth=[];
        SC.GirfZerothFrequency=[];        
        SC.NominalWaveform=[];
        SC.GirfWaveform=[];
    end
end

% END
end
