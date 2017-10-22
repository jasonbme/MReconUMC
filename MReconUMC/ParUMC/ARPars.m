classdef ARPars < dynamicprops & deepCopyable
%Declare all parameters related to the adjoint reconstructions (AR).
% (non-iterative reconstructions)
%
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    CoilSensitivityMaps % |YesNo| Estimation of coil sensitivity maps
    IterativeDensityEstimation % |YesNo|
    LoadCoilSensitivityMaps % |YesNo| Load coil maps from previous recon
    NufftSoftware % |String| Which NUFFT package to select, 'greengard','fessler' or 'reconframe'
    NufftType % |String| Which nufft type '3D' or '2D'
    PrototypeMode % |Integer| Prototyping with fewer dynamics 
    R % |Double| Acceleration factor
    SpatialResolution % |Double| Reconstruction voxel size [mm], only for in-plane resolution
    CoilMapEchoNumber % |Integer| Choose which echo to use to obtain the csm
end

%% Parameters that are extracted from PPE 
properties ( Hidden )
    Goldenangle % |Integer| Selection of (tiny) golden angles extracted from PPE (1=112 deg)
    IspaceSize % |Cell of arrays| Image space dimensions, extracted from PPE
    KspaceSize % |Cell of arrays| K-space dimensions, extracted from PPE
    SpatialResolutionRatio % |Double| Involved in calculation of trajectory for different resolution
end

%% Set default values
methods
    function AR = ARPars()   
        AR.CoilSensitivityMaps='no'; % 'no', 'espirit','walsh','refscan'
        AR.LoadCoilSensitivityMaps='no'; % yesno
        AR.Goldenangle=0; % integer [0:1:10] --> 0 is uniform sampling
        AR.IspaceSize=[]; % No input needed
        AR.IterativeDensityEstimation='no';
        AR.KspaceSize=[]; % No input needed
        AR.NufftSoftware='fessler'; % 'greengard','reconframe','fessler'
        AR.NufftType='2D'; % 2D / 3D 
        AR.PrototypeMode=0; % 1-dynamics
        AR.R=1; % Double [1-inf] , note this is not Nyquist R but Cartesian R 
        AR.SpatialResolution=0; % Single double with resolution in [mm]
        AR.SpatialResolutionRatio=[]; % No input needed
        AR.CoilMapEchoNumber=1; % 1-nechos
    end
end

% END
end
