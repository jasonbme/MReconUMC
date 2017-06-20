classdef GCPars < dynamicprops & deepCopyable
%Declare all parameters related to general computing (GC), such as location of
% the raw data on the drive. Stuff involved in parallel computing.
%
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    NumberOfCPUs % |Integer| Number of available cpus
    ParallelComputing % |YesNo| 
end

%% Parameters that are extracted from PPE 
properties ( Hidden )
    DataRoot % |String| Location of the scan data, including reference scans
    PermanentWorkingDirectory % |String| Location of @MReconUMC directory
    TemporateWorkingDirectory % |String| Location of .raw & .lab files
end

%% Set default values
methods
    function GC = GCPars()   
        GC.ParallelComputing='no';
        GC.NumberOfCPUs=4;
        GC.PermanentWorkingDirectory='';
        GC.DataRoot='';
        GC.TemporateWorkingDirectory='';
    end
end

% END
end