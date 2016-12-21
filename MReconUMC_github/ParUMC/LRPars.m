classdef LRPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to linear reconstructions.

properties
    CoilSensitivityMaps % Estimation of coil sensitivity maps
    LoadCoilSensitivityMaps % Load coil maps from directory if present
    DensityCompensationMethod % Which density function to apply
    Goldenangle % Selection of (tiny) golden angles
    IspaceSize % Image space dimensions
    KspaceSize % K-space dimensions
    NUFFTMethod % Which NUFFT package to select
    PrototypeMode % Prototyping with fewer dynamics
    R % Acceleration factor
    SpatialResolution % Reconstruction voxel size [mm]
    SpatialResolutionRatio % Working parameter, dont need to set
    
    % Operators 
    DensityOperator
    CombineCoilsOperator
    NUFFTOperator



end
methods
    function LR = LRPars()   
        LR.CoilSensitivityMaps='no'; % 'no', 'espirit','openadaptive','refscan'
        LR.LoadCoilSensitivityMaps='no'; % yesno
        LR.DensityCompensationMethod='ram-lak'; % 'ram-lak' or 'adaptive'
        LR.Goldenangle=0; % integer [0:1:10] --> 0 is uniform sampling
        LR.IspaceSize=[]; % No input needed
        LR.KspaceSize=[]; % No input needed
        LR.NUFFTMethod='greengard'; % 'greengard','mrecon','fessler'
        LR.PrototypeMode=0;
        LR.R=1; % Double [1-inf] , note this is not Nyquist R 
        LR.SpatialResolution=0; % Single double with resolution in [mm]
        LR.SpatialResolutionRatio=[]; % No input needed
        
        % Operators
        LR.DensityOperator={};
        LR.NUFFTOperator={};
        LR.CombineCoilsOperator={};
        
    end
end

% END
end
