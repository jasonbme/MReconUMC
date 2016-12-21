classdef UMCPars < dynamicprops & deepCopyable
% 20160615 - All new parameters have to be defined in here, this function
% also ensures overloading capabilities (dont change header).

properties
    GeneralComputing
    LinearReconstruction
    NonlinearReconstruction
    SystemCorrections
end
methods
    function UMCParameters = UMCPars()
        UMCParameters.GeneralComputing=GCPars();
        UMCParameters.SystemCorrections=SCPars();
        UMCParameters.LinearReconstruction=LRPars();
        UMCParameters.NonlinearReconstruction=NLRPars();
    end
end
% END
end
