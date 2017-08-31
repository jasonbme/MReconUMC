
%% Recon for spatial resolution and oversampling
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/global_scratch/Tom/Internal_data/ARD/';
%root='/local_scratch/tbruijne/WorkingData/4DGA/';
%root='/nfs/bsc01/researchData/USER/tbruijne/Research_data/20170813_MRF_noise_sensor/';
scanlist=1:20;

%% Recon from raw data
cd('/global_scratch/Tom/SNR_thingy/');
for j=1:numel(scanlist)
scan=scanlist(j);
clear MR
%list=dir([root,'Scan',num2str(scan),'/','*.lab']);
%loc=[root,'Scan',num2str(scan),'/',list.name];
%MR=MRecon(loc);
MR=MReconUMC(root,scan);
%MR.UMCParameters.Operators.Niter=12;
%MR.UMCParameters.AdjointReconstruction.PrototypeMode=50;
%MR.UMCParameters.SystemCorrections.NoisePreWhitening='yes';
%MR.UMCParameters.AdjointReconstruction.CoilSensitivityMaps='espirit';
%MR.UMCParameters.AdjointReconstruction.LoadCoilSensitivityMaps='yes';
%MR.UMCParameters.IterativeReconstruction.PotentialFunction=1;
%MR.Parameter.Recon.ArrayCompression='yes';
%MR.Parameter.Recon.ACNrVirtualChannels=4;
%MR.UMCParameters.IterativeReconstruction.WaveletDimension=2;
%MR.UMCParameters.IterativeReconstruction.IterativeReconstruction='yes';
%MR.UMCParameters.IterativeReconstruction.TVDimension={[3 3 0 0 0 0 0]};
%MR.UMCParameters.IterativeReconstruction.TVLambda={[150 150 0 0 0 0 0]};
MR.UMCParameters.IterativeReconstruction.SplitDimension=5;
%MR.UMCParameters.IterativeReconstruction.WaveletLambda={5,5};
MR.UMCParameters.AdjointReconstruction.NufftSoftware='greengard';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=3;
%MR.UMCParameters.AdjointReconstruction.NufftType='3D';
%MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber=2;
%MR.UMCParameters.AdjointReconstruction.R=8;
%MR.UMCParameters.GeneralComputing.ParallelComputing='yes';
%MR.UMCParameters.SystemCorrections.PhaseCorrection='model';
%MR.UMCParameters.AdjointReconstruction.SpatialResolution=1;
%MR.UMCParameters.SystemCorrections.Girf='yes';
%MR.UMCParameters.ReconFlags.Verbose=1;
MR.PerformUMC;
%MR.Perform;
snr=mean(abs(MR.Data),5)./std(abs(MR.Data),0,5);
data=MR.Data;
t_name=['Tom3_Scan',num2str(j),'.mat'];
save(t_name,'snr')
end

%% Visualization
snrmat=zeros(200,200,20);
snrlist=zeros(4,5);
for j=1:20
    t_name=['Tom3_Scan',num2str(j),'.mat'];
    load(t_name);
    dim=size(snr,1);
    %snrlist2(j)=mean(mean(snr(dim/2-dim/4:dim/2-dim/4
    X=linspace(-1,1,dim);
    NX=linspace(-1,1,200);
    %imshow(abs(snr),[]);pause(1);
    [KX,KY]=meshgrid(X,X);
    [KX2,KY2]=meshgrid(NX,NX);
    snr=interp2(KX,KY,snr,KX2,KY2,'spline');    
    snrmat(:,:,j)=snr;
    snrlist(j)=mean(mean(snr(50:150,50:150)));
end

% Reorder some stuffs
A=zeros(size(snrmat));
A(:,:,1:5)=snrmat(:,:,11:15);
A(:,:,6:10)=snrmat(:,:,1:5);
A(:,:,11:15)=snrmat(:,:,16:20);
A(:,:,16:20)=snrmat(:,:,6:10);
snrmat=A;
A=zeros(4,5);
A(1,1:5)=snrlist(11:15);
A(2,1:5)=snrlist(1:5);
A(3,1:5)=snrlist(16:20);
A(4,1:5)=snrlist(6:10);
snrlist=A;

close all
% SNR vs voxel volume and normalize by acquisition time
voxelvol=[(1E-03)^2*(1E-02) (1.5E-03)^2*(1E-02) (2E-03)^2*(1E-02) (2.5E-03)^2*(1E-02) (3E-03)^2*(1E-02)];
corr=[1.5*200 1.5*132 1.5*100 1.5*80 1.5*67];corr=corr/max(abs(corr));
figure,imshow3(snrmat,[],[4 5]);title('SNR matrix - os=[1 2 4 8] - res=1:.5:3');colormap hot;colorbar
figure,imagesc(snrlist);title('Average SNR across object ');colormap hot;axis off;colorbar
figure,for j=1:4;plot(voxelvol,snrlist(j,:)./corr,'LineWidth',2);hold all;end;title('SNR vs voxel volume');legend('OS=1','OS=2','OS=3','OS=4');xlabel('Voxel volume');ylabel('SNR normalized by acquisition time');grid on;box on;set(gca,'FontWeight','bold','LineWidth',3,'FontSize',14)

