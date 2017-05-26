classdef UMCPars < dynamicprops & deepCopyable
% 20160615 - All new parameters have to be defined in here, this function
% also ensures overloading capabilities (dont change header).

properties
    GeneralComputing
    AdjointReconstruction
    IterativeReconstruction
    SystemCorrections
    Simulation
    ReconFlags
end
methods
    function UMCParameters = UMCPars()
        UMCParameters.GeneralComputing=GCPars();
        UMCParameters.SystemCorrections=SCPars();
        UMCParameters.AdjointReconstruction=ARPars();
        UMCParameters.IterativeReconstruction=IRPars();
        UMCParameters.ReconFlags=RFPars();
        UMCParameters.Simulation=SIMPars();
    end
end
% END
end
