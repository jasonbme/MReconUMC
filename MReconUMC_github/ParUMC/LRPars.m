classdef LRPars < dynamicprops & deepCopyable
%% Linear Reconstruction related parameters
properties
    Autocalibrate
    AutocalibrateLoad
    Bandwidth
    CombineCoils
    CombineCoilsOperator
    DensityCompensationMethod
    DensityOperator
    Goldenangle
    IspaceSize
    KspaceSize
    Mask
    MRF
    NUFFTOperator
    NUFFTMethod
    ProfileSpacing
    PrototypeMode
    R
    CoilReferenceScan
    CoilReferenceScanLoad
    SpatialResolution
    SpatialResolutionRatio
end
methods
    function LR = LRPars()   
        LR.Autocalibrate='no';
        LR.AutocalibrateLoad='no';
        LR.CoilReferenceScan='no';
	LR.CoilReferenceScanLoad='no';
        LR.Mask=[];
        LR.DensityCompensationMethod='ram-lak'; % 'ram-lak', 'ram-lak adaptive'
        LR.DensityOperator={};
        LR.NUFFTOperator={};
	LR.MRF='no';
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
	LR.PrototypeMode=0;
    end
end

% END
end
