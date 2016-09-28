function FillParameters( MR )
%% Load parameters from reconframe

% Tom's patch
if MR.Parameter.IsParameter('UGN1_TOM_goldenangle')==1;MR.UMCParameters.LinearReconstruction.Goldenangle=MR.Parameter.GetValue('`UGN1_TOM_goldenangle');end
if MR.Parameter.IsParameter('UGN1_TOM_prof_spacing')==1;MR.UMCParameters.LinearReconstruction.ProfileSpacing=MR.Parameter.GetValue('`UGN1_TOM_prof_spacing');end
if MR.Parameter.IsParameter('UGN1_TOM_calibrationspokes')==1;MR.UMCParameters.RadialDataCorrection.NumberOfCalibrationSpokes=MR.Parameter.GetValue('`UGN1_TOM_calibrationspokes');end
if MR.Parameter.IsParameter('UGN1_TOM_duyn')==1;MR.UMCParameters.RadialDataCorrection.GIRF=MR.Parameter.GetValue('`UGN1_TOM_duyn');end
if MR.Parameter.IsParameter('UGN1_TOM_duyn_nrreadouts')==1;MR.UMCParameters.RadialDataCorrection.GIRFNA=MR.Parameter.GetValue('`UGN1_TOM_duyn');end
if MR.Parameter.IsParameter('EX_ACQ_radial_density_of_angles')==1;MR.Parameter.Encoding.NrDyn=floor(MR.Parameter.GetValue('`EX_ACQ_radial_density_of_angles')/100);end

% MR.UMCParameters.LinearReconstruction.Bandwidth=MR.Parameter.GetValue('UGN12_ACQ_act_bw_per_pixel',1)* ...
%     MR.Parameter.GetValue('UGN12_ACQ_scan_resolutions',1) ;
% Bjorns patch
% if MR.Parameter.IsParameter('UGN1_ACQ_golden_angle')==1;MR.UMCParameters.LinearReconstruction.Goldenangle=MR.Parameter.GetValue('`UGN1_ACQ_golden_angle');end
% if MR.UMCParameters.LinearReconstruction.Goldenangle==0;MR.UMCParameters.LinearReconstruction.ProfileSpacing='uniform';else;MR.UMCParameters.LinearReconstruction.ProfileSpacing='golden';end
% if MR.Parameter.IsParameter('UGN1_ACQ_ga_calibration_spokes')==1;MR.UMCParameters.RadialDataCorrection.NumberOfCalibrationSpokes=MR.Parameter.GetValue('`UGN1_ACQ_ga_calibration_spokes');end
% if MR.Parameter.IsParameter('EX_ACQ_radial_density_of_angles')==1;MR.Parameter.Encoding.NrDyn=floor(MR.Parameter.GetValue('`EX_ACQ_radial_density_of_angles')/100);end

% % Hardset
% MR.UMCParameters.LinearReconstruction.Goldenangle=1;
% MR.UMCParameters.LinearReconstruction.ProfileSpacing='golden';
% MR.UMCParameters.RadialDataCorrection.NumberOfCalibrationSpokes=48;
% MR.Parameter.Encoding.NrDyn=165;

% END
end