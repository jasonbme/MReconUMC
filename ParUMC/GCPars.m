classdef GCPars < dynamicprops & deepCopyable
%% General Computing related parameters
properties
    DataRoot
    NumberOfCPUs
    ParallelComputing
    PermanentWorkingDirectory
    TemporateWorkingDirectory
end
methods
    function GC = GCPars()   
        GC.ParallelComputing='yes';
        GC.NumberOfCPUs=4;
        GC.PermanentWorkingDirectory='';
        GC.DataRoot='';
        GC.TemporateWorkingDirectory='';
    end
end

% END
end