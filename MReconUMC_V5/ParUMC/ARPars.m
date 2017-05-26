classdef ARPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to linear reconstructions.

properties
    CoilSensitivityMaps % Estimation of coil sensitivity maps
    LoadCoilSensitivityMaps % Load coil maps from directory if present
    DensityCompensationMethod % Which density function to apply
    Goldenangle % Selection of (tiny) golden angles
    IspaceSize % Image space dimensions
    KspaceSize % K-space dimensions
    NUFFTMethod % Which NUFFT package to select
    NUFFTtype % Which nufft class, 3D, 2D, or 2D per slice
    PrototypeMode % Prototyping with fewer dynamics
    R % Acceleration factor
    SpatialResolution % Reconstruction voxel size [mm]
    SpatialResolutionRatio % Working parameter, dont need to set
    CoilMapEchoNumber % If echos have different k-space dimensions, process seperately
    % Operators 
    DensityOperator
    CombineCoilsOperator
    NUFFTOperator



end
methods
    function AR = ARPars()   
        AR.CoilSensitivityMaps='no'; % 'no', 'espirit','openadaptive','refscan'
        AR.LoadCoilSensitivityMaps='no'; % yesno
        AR.DensityCompensationMethod='ram-lak'; % 'ram-lak' or 'adaptive'
        AR.Goldenangle=0; % integer [0:1:10] --> 0 is uniform sampling
        AR.IspaceSize=[]; % No input needed
        AR.KspaceSize=[]; % No input needed
        AR.NUFFTMethod='greengard'; % 'greengard','mrecon','fessler'
        AR.NUFFTtype='2D'; % 2D / 3D / 2Dp
        AR.PrototypeMode=0;
        AR.R=1; % Double [1-inf] , note this is not Nyquist R 
        AR.SpatialResolution=0; % Single double with resolution in [mm]
        AR.SpatialResolutionRatio=[]; % No input needed
        AR.CoilMapEchoNumber=1;
        % Operators
        AR.DensityOperator={};
        AR.NUFFTOperator={};
        AR.CombineCoilsOperator={};
        
    end
end

% END
end
