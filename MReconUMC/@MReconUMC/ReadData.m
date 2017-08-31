function ReadData( MR )
%Overloaded reconframe function to seperate process epi calibration data
% the noise data when noise prewhitening is required.
%
% 20170717 - T.Bruijnen

%% ReadData
% Seperate EPI phase correction data if required
if strcmpi(MR.Parameter.Scan.FastImgMode,'EPI')
    MR.Parameter.Parameter2Read.typ=3;
    ReadData@MRecon(MR);
    MR.RandomPhaseCorrection;
    MR.RemoveOversampling;
    MR.PDACorrection;
    MR.DcOffsetCorrection;
    MR.MeasPhaseCorrection;
    MR.UMCParameters.SystemCorrections.CalibrationData=MR.Data;
end

% Seperate noise data if required
if strcmpi(MR.UMCParameters.SystemCorrections.NoisePreWhitening,'yes') 
    MR.Parameter.Parameter2Read.typ=5;
    ReadData@MRecon(MR);
    MR.RandomPhaseCorrection;
    MR.RemoveOversampling;
    MR.PDACorrection;
    MR.DcOffsetCorrection;
    MR.MeasPhaseCorrection;
    MR.UMCParameters.SystemCorrections.NoiseData=MR.Data;
end

% Run Sort from MRecon
MR.Parameter.Parameter2Read.typ=1;
ReadData@MRecon(MR);

% END
end

