
%% Recon philips data in one go
clear all;clc;clear classes;close all
addpath(genpath(pwd))
root='/global_scratch/Tom/Internal_data/20170619_Philips_EC_data/';

%%
scans=[1 2 6 7 8 9 10 11 12 13 14 15];
for j=1:numel(scans);
    scan=scans(j);
    clear MR
    MR=MReconUMC(root,scan);
    %MR.UMCParameters.SystemCorrections.GIRF='yes';
    MR.UMCParameters.IterativeReconstruction.SplitDimension=3;
    MR.PerformUMC;
    if size(MR.Data,5)>5
    slicer(squeeze(MR.Data));
    recon=MR.Data(:,:,:,:,5);
    else
    imshow(MR.Data,[]);
    recon=MR.Data(:,:,:,:,1);
    end
    cd(root);cd(['Scan',num2str(scan)])
    save('recon.mat','recon')
    saveas(gcf,'recon','fig')
    cd('/nfs/rtsan02/userdata/home/tbruijne/Documents/MATLAB/MReconUMC/MReconUMC/MReconUMC_V5/')
end

%% Visualization
root='/global_scratch/Tom/Internal_data/20170619_Philips_EC_data/';
dyn_scans=[14 1 6 8 12 13 15 2 7 9 10 11];
VIS=zeros(168,168,10);
for j=1:numel(dyn_scans);
    cd(root);cd(['Scan',num2str(dyn_scans(j))])
    load('recon.mat')
    recon=recon/max(recon(:));
    recon(recon>0.8)=.8;
    VIS(:,:,j)=recon(:,:,:,:,1);
end

figure,imshow3(VIS,[],[2 numel(dyn_scans)/2]);title('2D Radial acquisitions | Top row=bFFE & Bot row=T1-FFE | Colums: Cartesian | Uniform |  Tiny golden angle 1:2:7')
title({'2D Radial acquisitions | Top row = BFFE | Bot row = T1FFE';'                                   Cartesian                    |                    Uniform               |               Golden angle (111)                |               Golden angle (50)               |               Golden angle(32)               |               Golden angle (23)                 '})
title({'2D Radial acquisitions | Top row = BFFE | Bot row = T1FFE';'';'     Cartesian                                    Uniform angle                           Golden angle (111)                      Golden angle (50)                    Golden angle(32)                        Golden angle (23)'})

% [x,y]=meshgrid(1:240,1:240);
% [x1,y1]=meshgrid(1:240/168:240,1:240/168:240);
% recon=interp2(x,y,double(squeeze(recon(:,:,:,:,1))),x1,y1,'spline');

%% 3D scans
root='/global_scratch/Tom/Internal_data/20170619_Philips_EC_data/';
D3_scans=[3 4 5];
z=[7 8 13 19 25];
VIS=zeros(168,168,numel(z),3);
for j=1:numel(D3_scans);
    cd(root);cd(['Scan',num2str(D3_scans(j))])
    load('recon.mat')
    recon=recon/max(recon(:));
    recon(recon>0.6)=.6;
    VIS(:,:,:,j)=recon(:,:,z,:,:);
end
figure,imshow3(reshape(VIS,[168 168 numel(z)*3]),[],[3 numel(z)]);
title({'Radial stack-of-stars';''; 'Row 1 = BFFE linear z spacing      Row 2 = BFFE lowhigh z spacing      Row 3 = T1FFE linear z spacing'})

%% UTE ME scan
root='/global_scratch/Tom/Internal_data/20170619_Philips_EC_data/';
cd(root)
cd('Scan16')
load recon_nlcg.mat
load philips_recon.mat
philips_recon=double(philips_recon);
z_philips=[4 9 17 21];
z=[7 12 20 24];
for l=1:numel(z)
    recon_nlcg(:,:,z(l),:,:)=abs(recon_nlcg(:,:,z(l),:,:))/max(max(abs(recon_nlcg(:,:,z(l),:,:))));
    philips_recon(:,:,z_philips(l),:,:)=abs(philips_recon(:,:,z_philips(l),:,:))/max(max(abs(philips_recon(:,:,z_philips(l),:,:))));
end
%recon_nlcg=abs(squeeze(recon_nlcg/max(abs(recon_nlcg(:)))));recon_nlcg(recon_nlcg>.8)=.8;recon_nlcg=abs(squeeze(recon_nlcg/max(abs(recon_nlcg(:)))));
%philips_recon=abs(squeeze(philips_recon/max(abs(philips_recon(:)))));
figure,imshow3(cat(3,recon_nlcg(2:end,2:end,z,:,:),philips_recon(:,:,z_philips,:,:)),[],[2 numel(z)]);title({'UTE T1FFE 3D Stack-of-stars reconstructions';'';'Top row = my correctio & Bot row = Philips UI n'})

% Zoom
x1=[25,80,80,80];
x2=[85,140,140,140];
y1=[45,160,160,120];
y2=[105,220,220,180];
for l=1:numel(x1)
    zoom_nlcg(:,:,l,:,:)=abs(recon_nlcg(x1(l):x2(l),y1(l)+1:y2(l)+1,z(l),:,:));
    zoom_philips(:,:,l,:,:)=abs(philips_recon(x1(l):x2(l),y1(l):y2(l),z_philips(l),:,:));
end

figure,imshow3(abs(cat(3,zoom_nlcg,zoom_philips)),[],[2 numel(x1)]);title({'UTE T1FFE 3D Stack-of-stars reconstructions';'';'Top row = my correction & Bot row = Philips UI n'})