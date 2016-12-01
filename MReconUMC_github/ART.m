%% Script for automatic reconstruction
clear all;clc;clear classes
cd('/global_scratch/Tom/Internal_data/ARD/')

%% Loop over all content and check if it has been labeled
for scan=1:50
     if (exist(['Scan',num2str(scan)])==7)  % Check if folder exists
         root='/nfs/rtfile02/groupdata2/global_scratch/Tom/Internal_data/ARD/';
         %root='/global_scratch/Tom/Internal_data/ARD/';
         cd([root,'/Scan',num2str(scan)])
         if ~exist('RECON.mat') % check if it is labeled
             % Do the reconstruction if not labeled
             cd('/home/tbruijne/Documents/MATLAB/MReconUMC_github/')
             addpath(genpath(pwd))
             clear MR
             MR=MReconUMC(root,scan);
             MR.UMCParameters.LinearReconstruction.MRF='yes';
             MR.UMCParameters.RadialDataCorrection.PhaseCorrection='fit';
    
             MR.PerformUMC;
             data=MR.Data;
             csm=MR.Parameter.Recon.Sensitivities;
             cd('/global_scratch/Tom/Internal_data/ARD/')
             cd([root,'/Scan',num2str(scan)])
             save('RECON.mat','data','csm');
             slicer(squeeze(MR.Data));
             savefig('RECON.fig')

         end
         cd ..
     end
end



