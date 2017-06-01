function FillParameters( MR )
% Load parameters from reconframe from specific patches

% Radial related parameters
if MR.Parameter.IsParameter('UGN1_ACQ_golden_angle')==1;MR.UMCParameters.AdjointReconstruction.Goldenangle=MR.Parameter.GetValue('`UGN1_ACQ_golden_angle');end
if MR.Parameter.IsParameter('UGN1_ACQ_ga_calibration_spokes')==1;MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes=MR.Parameter.GetValue('`UGN1_ACQ_ga_calibration_spokes');end
if MR.Parameter.IsParameter('EX_ACQ_radial_density_of_angles')==1;MR.Parameter.Encoding.NrDyn=floor(MR.Parameter.GetValue('`EX_ACQ_radial_density_of_angles')/100);end

% Fingerprinting
if MR.Parameter.IsParameter('EX_TOM_mrf')==1;MR.UMCParameters.AdjointReconstruction.Fingerprinting=MR.Parameter.GetValue('`EX_TOM_mrf');end

% Hardcode
%MR.UMCParameters.AdjointReconstruction.Goldenangle=0;
%MR.UMCParameters.SystemCorrections.NumberOfCalibrationSpokes=0;
%MR.Parameter.Encoding.NrDyn=1;

% If simulation mode is activated, load the structure
if strcmpi(MR.UMCParameters.Simulation.Simulation,'yes')
    MR=generate_simulation_data(MR);
end

% END
end