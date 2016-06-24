classdef CardiacParsDoc
    % These are the cardiac parameters of the current scan, describing functionalities such as
    % cardiac triggering and respiratory synchronization/compensation. 
    properties (SetObservable) 
        Synchronization;    % The cardiac synchronization method which was used in the current scan. The values can be 'No', 'Trigger', 'Gate', 'Retro' and 'PhaseWindow'.
        RespSync;           % The respiratory synchronization method which was used in the current scan. The values can be 'No', 'Trigger', 'Breathold', 'Pear', 'Gate'.
        RespComp;           % The respiratory compensation method which was used in the current scan. The values can be 'No', 'Gate', 'Track', 'GateAndTrack', 'Trigger', 'TriggerAndTrack'.
        RetroPhases;        % The number of reconstructed heart phases in a retrospectively triggered scan.
        HeartPhaseInterval; % The duration of the heart phase interval in a cardiac scan.
        PhaseWindow;        % The user has the possibility to reconstruct a single heart phase of a retrospective triggered scan. This parameter determines the phase interval in ms. Please set the Synchronization to PhaseInterval to use this option.
        RNAV;               % The respiratory navigator positions as calculated by the scanner
    end           
    methods        
        % ---------------------------------------------------------------%
        % Deep Copy of Class
        % ---------------------------------------------------------------%
        function new = Copy(this)            
        end
    end
end

