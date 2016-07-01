function FillParameters( MR )
% 20160615 - Set default values for all parameters, all these parameters
% are overloaded when you manually change them in MRECON.m. Four parameters
% are derived from the acquisition object, which therefore should be set
% accordingly.

% Phase/gradient delay correction related parameters
MR.ParUMC.CustomRec='yes';
MR.ParUMC.NumCalibrationSpokes=0;
MR.ParUMC.CalibrationData=[];
MR.ParUMC.GradDelayCorrMethod='no'; % 'smagdc' or 'sweep' or 'none' 
MR.ParUMC.ZerothMomentCorrection='no';
MR.ParUMC.PhaseHardSet='no';
MR.ParUMC.MimicGradientDelay=0;

% Gridding related parameters
MR.ParUMC.DCF='ram-lak adaptive'; %'ram-lak' or 'ram-lak adaptive'
MR.ParUMC.W={};
MR.ParUMC.ProfileSpacing='empty'; 
MR.ParUMC.Goldenangle=0;
MR.ParUMC.Gridder='greengard'; % 'greengard' or 'fessler' or 'mrecon' 
MR.ParUMC.NumberOfSpokes=0;

% Iterative reconstruction related parameters
MR.ParUMC.GetCoilMaps='no'; 
MR.ParUMC.Rawdata=[];
MR.ParUMC.Sense=[];
MR.ParUMC.NUFFT=[];
MR.ParUMC.CS='no';
MR.ParUMC.lambda=40;
MR.ParUMC.NLCG={3,25}; % number of iterations
MR.ParUMC.Beta=.035;
MR.ParUMC.Cost=0;
MR.ParUMC.Objective=0;
MR.ParUMC.CSData=[];
MR.ParUMC.Mask='no';

% General parameters
MR.ParUMC.EnableCombineCoils='yes';
MR.ParUMC.NumCores=4;
MR.ParUMC.ParallelComputing='yes';
MR.Parameter.Gridder.AlternatingRadial='no';

% Get parameters from acquisition data
%MR.ParUMC.Goldenangle=MR.Parameter.GetValue('`UGN1_TOM_goldenangle');
MR.ParUMC.Goldenangle=MR.Parameter.GetValue('`UGN1_ACQ_golden_angle');
%MR.ParUMC.ProfileSpacing=MR.Parameter.GetValue('`UGN1_TOM_prof_spacing');
if MR.ParUMC.Goldenangle == 0
    MR.ParUMC.ProfileSpacing='uniform';
else
    MR.ParUMC.ProfileSpacing='golden';
end
%MR.ParUMC.NumCalibrationSpokes=MR.Parameter.GetValue('`UGN1_TOM_calibrationspokes');
MR.ParUMC.NumCalibrationSpokes=MR.Parameter.GetValue('`UGN1_ACQ_ga_calibration_spokes');
MR.Parameter.Encoding.NrDyn=floor(MR.Parameter.GetValue('EX_ACQ_radial_density_of_angles')/100); 

% If 2D fill in ZRes and ZReconRes
if strcmpi(MR.Parameter.Scan.ScanMode,'2D')
    MR.Parameter.Encoding.ZRes=1;
    MR.Parameter.Encoding.ZReconRes=1;
end

% END
end