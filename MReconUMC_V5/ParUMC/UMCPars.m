classdef UMCPars < dynamicprops & deepCopyable
% 20160615 - All new parameters have to be defined in here, this function
% also ensures overloading capabilities (dont change header).

properties
    AdjointReconstruction
    GeneralComputing
    IterativeReconstruction
    ReconFlags
    SystemCorrections
    Simulation
    Operators
    Fingerprinting
end

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
