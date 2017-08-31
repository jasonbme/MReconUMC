%% Recon configuration for MRL abdominal T1-weighted FFE data

%% 50 ms
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/global_scratch/Tom/Internal_data/20170405_MRL_data/';
scan=5;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.AdjointReconstruction.PrototypeMode=400;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={5};
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,75]};
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
MR.UMCParameters.AdjointReconstruction.R=10;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

cd(root);cd('Scan5');
nlcg_tv_16spokes_62ms=MR.Data;save('nlcg_tv_16spokes_62ms.mat','nlcg_tv_16spokes_62ms');

%% 25 ms
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/global_scratch/Tom/Internal_data/20170405_MRL_data/';
scan=5;

clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.AdjointReconstruction.PrototypeMode=400;
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={5};
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[5,5,0,0,75]};
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
MR.UMCParameters.AdjointReconstruction.R=20;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

cd(root);cd('Scan5');
nlcg_tv_8spokes_31ms=MR.Data;save('nlcg_tv_8spokes_31ms.mat','nlcg_tv_8spokes_31ms');