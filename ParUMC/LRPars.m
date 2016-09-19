classdef LRPars < dynamicprops & deepCopyable
%% Linear Reconstruction related parameters
properties
    Autocalibrate
    Bandwidth
    CombineCoils
    CombineCoilsOperator
    DensityCompensationMethod
    DensityOperator
    Goldenangle
    IspaceSize
    KspaceSize
    Mask
    NUFFTOperator
    NUFFTMethod
    ProfileSpacing
    R
    ReferenceScan
    SpatialResolution
    SpatialResolutionRatio
end
methods
    function LR = LRPars()   
        LR.Autocalibrate='no';
        LR.ReferenceScan='no';
        LR.Mask=[];
        LR.DensityCompensationMethod='ram-lak'; % 'ram-lak', 'ram-lak adaptive'
        LR.DensityOperator={};
        LR.NUFFTOperator={};
        LR.CombineCoilsOperator={};
        LR.NUFFTMethod='greengard'; % 'greengard','mrecon','fessler'
        LR.ProfileSpacing='golden'; % 'golden', 'uniform'  
        LR.Goldenangle=0; % 0-10
        LR.R=1;
        LR.KspaceSize=[];
        LR.IspaceSize=[];
        LR.SpatialResolution=0;
        LR.SpatialResolutionRatio=[];
        LR.CombineCoils='yes';
        LR.Bandwidth=[];
    end
end

% END
end
