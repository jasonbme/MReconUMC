classdef MRFPars < dynamicprops & deepCopyable
% 20161206 - Declare all parameters related to general computing
% informatics.

properties
    Fingerprinting % If fingerprinting is performed the data needs slightly different organizing
    Dictionary
    QMaps
end

methods
    function MRF = MRFPars()   
        MRF.Fingerprinting='no';
        MRF.Dictionary='';
        MRF.QMaps=[];
    end
end

% END
end