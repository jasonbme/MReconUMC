classdef UMCPars < dynamicprops & deepCopyable
% 20160615 - All new parameters have to be defined in here, this function
% also ensures overloading capabilities (dont change header).

methods
    function ParUMC = UMCPars(MR)
        % Phase correction related parameters
        ParUMC.addprop('CustomRec');
        ParUMC.addprop('NumCalibrationSpokes');
        ParUMC.addprop('CalibrationData');
        ParUMC.addprop('GradDelayCorrMethod');
        ParUMC.addprop('ZerothMomentCorrection');
        
        % Gridding related parameters
        ParUMC.addprop('DCF');
        ParUMC.addprop('W');
        ParUMC.addprop('ProfileSpacing');
        ParUMC.addprop('Goldenangle');
        ParUMC.addprop('Gridder');
        ParUMC.addprop('NumberOfSpokes');
        ParUMC.addprop('Kdims');
        ParUMC.addprop('Rdims');
        ParUMC.addprop('SpatialResolution');
        ParUMC.addprop('ReconRatio');
        
        % Iterative reconstruction related parameters
        ParUMC.addprop('GetCoilMaps');
        ParUMC.addprop('Rawdata');
        ParUMC.addprop('NUFFT');
        ParUMC.addprop('Sense');
        ParUMC.addprop('CS');
        ParUMC.addprop('lambda');
        ParUMC.addprop('NLCG');
        ParUMC.addprop('Beta');
        ParUMC.addprop('Cost');
        ParUMC.addprop('Objective');
        ParUMC.addprop('CSData');
        ParUMC.addprop('TrackCS');
        ParUMC.addprop('Mask');
        
        % General parameters
        ParUMC.addprop('EnableCombineCoils');
        ParUMC.addprop('ParallelComputing');
        ParUMC.addprop('NumCores');
        ParUMC.addprop('PWD');
        ParUMC.addprop('Root');
        ParUMC.addprop('TWD');
    end
end
% END
end