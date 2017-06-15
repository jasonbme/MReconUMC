
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/local_scratch/tbruijne/WorkingData/UTE/';
scan=5;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.SystemCorrections.GIRF='yes';
%MR.UMCParameters.SystemCorrections.GIRF_nominaltraj='yes';
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.Operators.N_iter=10;
%MR.UMCParameters.IterativeReconstruction.JointReconstruction=7;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 0 0 1 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[100,100,0,0,0,0,500]};
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
%MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='fessler';
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;


%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
%MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;


%%
clear MR
MR=MReconUMC(root,scan);
%MR.UMCParameters.SystemCorrections.GIRF='yes';
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
MR.UMCParameters.AdjointReconstruction.NUFFTtype='3D';
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;



