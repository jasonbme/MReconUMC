
%% Recon head-and-neck over the weekend
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='C:\Users\s116555\Documents\Programming\Github_repositories\MReconUMC\MReconUMC_V5\Packages\simulations\Phantom\';
scan=1;

%%
clear MR
MR=MReconUMC(root,scan);
MR.UMCParameters.Operators.N_iter=50;
MR.UMCParameters.AdjointReconstruction.PrototypeMode=1;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='walsh';
MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
MR.UMCParameters.IterativeReconstruction.Potential_function=1;
MR.UMCParameters.IterativeReconstruction.Wavelet=2;
MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
MR.UMCParameters.IterativeReconstruction.TVdimension=[3 3 0 0 0 ];
MR.UMCParameters.IterativeReconstruction.TV_lambda={[2,2,0,0,0]};
MR.UMCParameters.IterativeReconstruction.JointReconstruction=3;
MR.UMCParameters.IterativeReconstruction.Wavelet_lambda={1};
MR.UMCParameters.AdjointReconstruction.NUFFTMethod='greengard';
MR.UMCParameters.AdjointReconstruction.R=6;
MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;

