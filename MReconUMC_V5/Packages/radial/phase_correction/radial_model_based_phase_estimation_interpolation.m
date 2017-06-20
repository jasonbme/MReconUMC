function radial_model_based_phase_estimation_interpolation(MR,n)
% Get model_parameters for all desired dimension.
% So do not save the phase required for the correction.

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model_interpolation')
    return;
end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};
    
% Preallocate model parameter matrix
model_parameters=zeros([2 dims(3:end)]);

% Store angles in variable for data handling
angles=MR.Parameter.Gridder.RadialAngles{n};

% If number of lines per data chunk is > 25 the fitting is well
% conditioned. Select 25 azimuthally distributed lines (idx) for speed.
if dims(2)>25;[~,idx]=sort(angles);idx=idx(1:ceil(end/25):end);else;[~,idx]=sort(angles);end

% Select point closest to zero for interpolation for each readout
[~,cp]=min(sqrt(MR.Parameter.Gridder.Kpos{n}(1,:,idx,:,:,:,:,:,:,:,:,:,:).^2+...
    MR.Parameter.Gridder.Kpos{n}(2,:,idx,:,:,:,:,:,:,:,:,:,:).^2+...
    MR.Parameter.Gridder.Kpos{n}(3,:,idx,:,:,:,:,:,:,:,:,:,:).^2),[],2);cp=squeeze(cp);

% Select triples surrounding the central point, interpolate phase and 
% define the model
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
for nl=idx   % Number of lines    

    % Store current centerpoint in variable
    cur_cp=cp(find(idx==nl),1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

    % Translate current line to absolute k-space triplet
    kspace_triplet=MR.Parameter.Gridder.Kpos{n}(1:2,cur_cp-1:cur_cp+1,nl,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg);

    % Assign central phase - 'v4' is only method that can extrapolate
    cph(nl)=griddata(kspace_triplet(1,:),kspace_triplet(2,:),double(angle(MR.Data{n}(cur_cp-1:cur_cp+1,nl,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)))',0,0,'v4');

end % Number of lines

    % Paramatrize model
    model_parameters(:,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
        radial_paramatrizephasemodel(cph(idx),angles(:,idx,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg));

    % Clear cph to remove ambiguity
    clear cph

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
