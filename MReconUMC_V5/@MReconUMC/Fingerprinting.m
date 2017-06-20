function Fingerprinting( MR )
%Routine uses the generated MR time series to extract pixel-by-pixel time series 
% and maps the time domain signals to the an existing dictionary. If the
% dictionary doesnt exist it will notify the user. The user is free to
% provide a dictionary location in MR.UMCParameters.Fingerprinting.Dictionary
%
% 20170717 - T.Bruijnen

%% Logic and display
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

%% Fingerprinting
% Perform dot product based pattern recognition    
matchmap=pattern_recognition(dict,MR.Data);

% Generate the quantitative maps from the "matchmap"
MR.UMCParameters.Fingerprinting.QuantitativeMaps=generate_maps(MR.Data,dic,matchmap,T1list,T2list,B1list,[],[]);

%% Display
% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end