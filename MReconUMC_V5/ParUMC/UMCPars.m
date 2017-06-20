classdef UMCPars < dynamicprops & deepCopyable
%All seperate branches of the UMCParameters structure have to be defined
% and linked here. 
% 
% 20170717 - T.Bruijnen

%% Branches that can be seen from GUI
properties
    AdjointReconstruction
    GeneralComputing
    IterativeReconstruction
    SystemCorrections
end

%% Hidden branches, dont need modification from configure file
properties ( Hidden )
    ReconFlags
    Operators
    Fingerprinting
    Simulation
end

%% Set default values
methods
    function UMCParameters = UMCPars()
        UMCParameters.GeneralComputing=GCPars();
        UMCParameters.SystemCorrections=SCPars();
        UMCParameters.AdjointReconstruction=ARPars();
        UMCParameters.IterativeReconstruction=IRPars();
        UMCParameters.ReconFlags=RFPars();
        UMCParameters.Operators=Operators();
        UMCParameters.Simulation=SIMPars();
        UMCParameters.Fingerprinting=MRFPars();
    end
end

% END
end
