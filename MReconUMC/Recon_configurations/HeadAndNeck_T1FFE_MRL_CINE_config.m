%% Recon configuration for MRL head-and-neck T1-weighted FFE data - 20 seconds of data

%% 96 ms
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/2DGA/';
scan=3;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.AdjointReconstruction.PrototypeMode=200;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={1};
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[1,1,0,0,25]};
MR.UMCParameters.AdjointReconstruction.R=8.2;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

cd(root);cd('Scan3');
nlcg_tv_21spokes_96ms=MR.Data;save('nlcg_tv_21spokes_96ms.mat','nlcg_tv_21spokes_96ms');

%% 96 ms
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/2DGA/';
scan=3;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.AdjointReconstruction.PrototypeMode=350;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={1};
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[1,1,0,0,25]};
MR.UMCParameters.AdjointReconstruction.R=13.2;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

cd(root);cd('Scan3');
nlcg_tv_13spokes_60ms=MR.Data;save('nlcg_tv_13spokes_60ms.mat','nlcg_tv_13spokes_60ms');


