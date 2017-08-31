classdef RFPars < dynamicprops & deepCopyable
%Declare parameters that are used as reconstruction flags (RF). For example to
% help the display function with Verbose.
% 
% 20170717 - T.Bruijnen

%% Parameters that are adjustable at configuration
properties
    Verbose % |Integer| 1=yes , 0=no 
end

%% Parameters that are extracted from PPE 
properties ( Hidden )
    NufftCsmMapping  % |Integer| 1=yes , 0=no 
end

%% Set default values
methods
    function RF = RFPars()   
        RF.NufftCsmMapping=0;
        RF.Verbose=0;
    end
end

% END
end