function radial_model_based_phase_estimation(MR,n)
% Get model_parameters for all desired dimension.
% So do not save the phase required for the correction.

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model')
    return;
end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};

% Preallocate model parameter matrix
model_parameters=zeros([2 dims(3:end)]);

% Store angles in variable for data handling
angles=MR.Parameter.Gridder.RadialAngles{n};

% If number of lines per data chunk is > 25 the fitting is well
% conditioned. Select 50 azimuthally distributed lines (idx) for speed.
if dims(2)>25;[~,idx]=sort(angles);idx=idx(1:ceil(end/25):end);else;[~,idx]=sort(angles);end

% Estimate nearest neighbour center point of the readouts
[~,cp]=min(MR.Parameter.Gridder.Weights{n}(:,1,1,1,1,1,1,1,1,1,1,1,1),[],1); % central point

% Organize central phase in matrix
cph=angle(MR.Data{n}(cp,:,:,:,:,:,:,:,:,:,:,:));

% Loop over all data dimensions and paramatrize model
for avg=1:dims(12) % Averages
for ex2=1:dims(11) % Extra2
for ex1=1:dims(10) % Extra1
for mix=1:dims(9)  % Locations
for loc=1:dims(8)  % Mixes
for ech=1:dims(7)  % Phases
for ph=1:dims(6)   % Echos
for dyn=1:dims(5)  % Dynamics
for coil=1:dims(4) % Coils
for z=1:dims(3)    % Z
    model_parameters(:,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
        radial_paramatrizephasemodel(cph(:,idx,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg),...
        angles(:,idx,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg));
end % Z
end % Coils
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Averages
    
% Assign values to struct
MR.UMCParameters.SystemCorrections.PhaseCorrection_model_parameters{n}=model_parameters;

% END
end