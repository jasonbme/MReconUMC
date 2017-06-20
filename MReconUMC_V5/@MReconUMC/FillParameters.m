function FillParameters( MR )
%Load parameters from the PPE into the reconframe struct. It checks whether
% the parameters exist in the PPE to avoid errors when they do not. This
% allows the use of parameter allocation for multiple patches. Furthermore
% it deals with the consequences of the PPE parameters, i.e. automatically
% changes certain other reconframe parameters.
%
% 20170717 - T.Bruijnen

%% FillParameters
% Radial related parameters
if MR.Parameter.IsParameter('UGN1_ACQ_golden_angle')==1;MR.UMCParameters.AdjointReconstruction.Goldenangle=MR.Parameter.GetValue('`UGN1_ACQ_golden_angle');end
if MR.Parameter.IsParameter('UGN1_ACQ_ga_calibration_spokes')==1;MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes=MR.Parameter.GetValue('`UGN1_ACQ_ga_calibration_spokes');end
if MR.Parameter.IsParameter('EX_TOM_goldenangle')==1;MR.UMCParameters.AdjointReconstruction.Goldenangle=MR.Parameter.GetValue('`EX_TOM_goldenangle');end
if MR.Parameter.IsParameter('UGN1_TOM_calibrationspokes')==1;MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes=MR.Parameter.GetValue('`UGN1_TOM_calibrationspokes');end

% Fingerprinting related parameters
if MR.Parameter.IsParameter('EX_TOM_mrf')==1;MR.UMCParameters.Fingerprinting.Fingerprinting=MR.Parameter.GetValue('`EX_TOM_mrf');end

if MR.Parameter.IsParameter('EX_ACQ_radial_density_of_angles')==1 && strcmpi(MR.Parameter.Scan.AcqMode,'Radial') && MR.UMCParameters.AdjointReconstruction.Goldenangle>0;MR.Parameter.Encoding.NrDyn=floor(MR.Parameter.GetValue('`EX_ACQ_radial_density_of_angles')/100);...
    if MR.Parameter.Encoding.NrDyn==0;MR.Parameter.Encoding.NrDyn=1;end;end

%% Consequences of PPE parameters
if strcmpi(MR.UMCParameters.Fingerprinting.Fingerprinting,'yes');MR.Parameter.Encoding.NrDyn=1000;end

% END
end