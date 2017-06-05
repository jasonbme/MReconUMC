function Fingerprinting( MR )
% Use the MR time series to map the time domain pixels signals to the an
% existing dictionary. 

% Logic
if strcmpi(MR.UMCParameters.Fingerprinting.Fingerprinting,'no')
    return; end

% Exmamine the link to the dictionary location
if isempty(MR.UMCParameters.Fingerprinting.Dictionary)
    display('\nNo dictionary location provided - cant do fingerprinting reconstruction.\n');return;end

% Load dictionary and check if all parameters exist
load(MR.UMCParameters.Fingerprinting.Dictionary)
if ~exist('T1list','T2list','B1list','dictionary')
    display('\nInvalid dictionary, cant do fingerprinting reconstruction.\n');return;end

% Notification
fprintf('Performing MR Fingerprinting reconstruction.......  \n');tic

% Perform dot product based pattern recognition    
matchmap=pattern_recognition(dict,MR.Data);

% Generate the quantitative maps from the "matchmap"
MR.UMCParameters.Fingerprinting.QMaps=generate_maps(MR.Data,dic,matchmap,T1list,T2list,B1list,[],[]);

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end