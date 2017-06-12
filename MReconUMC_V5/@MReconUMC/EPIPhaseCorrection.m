function EPIPhaseCorrection( MR )
% Overload EPI phase correction function

% logic
if ~strcmpi(MR.Parameter.Scan.FastImgMode,'EPI')
    return; end

% Dimensionality
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{1};
Id=MR.Parameter.Gridder.OutputMatrixSize{1};

% Reshape calibration data to [Kd(1) Kd(2) Kd(4)]
calib_data=permute(reshape(MR.UMCParameters.SystemCorrections.CalibrationData,[Kd(1) Kd(4) Kd(2)]),[1 3 4 2]);
MR.UMCParameters.SystemCorrections.CalibrationData=[];

% Determine phase at k0 for each readout



%END
end


%n1d_for=@(y)(nufft(y,d));
