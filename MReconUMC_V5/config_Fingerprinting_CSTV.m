
%% Balanced MRF case  - 15 sec per timepoints ~ 4 hours
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/MRF/';
scan=2;


clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.Operators.N_iter=10;
MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 0 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,0]};
MR.UMCParameters.IterativeReconstruction.JointReconstruction=5;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={1};
MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

csm=MR.Parameter.Recon.Sensitivities;
cs_mrf=MR.Data;
scaninfo=mrfinfo(MR);
cd(root);cd('Scan2')
save('cs_mrf.mat','cs_mrf','scaninfo','csm','-v7.3')

%% Spoiled MRF case  - 15 sec per timepoints ~ 4 hours
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/MRF/';
scan=1;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.Operators.N_iter=10;
MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 0 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[1,1,0,0,0]};
MR.UMCParameters.IterativeReconstruction.JointReconstruction=5;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={1};
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

cs_mrf=MR.Data;
scaninfo=mrfinfo(MR);
cd(root);cd('Scan1')
save('cs_mrf.mat','cs_mrf','scaninfo','csm','-v7.3')