classdef GCPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to general computing
% informatics.

properties
    DataRoot
    NumberOfCPUs
    ParallelComputing
    PermanentWorkingDirectory
    TemporateWorkingDirectory
end
methods
    function GC = GCPars()   
        GC.ParallelComputing='no';
        GC.NumberOfCPUs=0;
        GC.PermanentWorkingDirectory='';
        GC.DataRoot='';
        GC.TemporateWorkingDirectory='';
    end
end

% END
end