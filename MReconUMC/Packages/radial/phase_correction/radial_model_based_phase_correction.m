function radial_model_based_phase_correction(MR,n)
% Apply the model parameters to the k-space phase

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model_interpolation')...
        && ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'model') 
    return;
end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize{n};

% Count number of elements in MR.Data. If its larger then 10^8 use a less
% memory intensive method
if numel(MR.Data{n})>2*10^8
    inst=1;
else
    inst=0;
end

% Define the model
phi=@(theta,A)(A(1).*cos(theta)+A(2).*sin(theta)); 

% Ful pre-computed matrix multiplication (inst=0)
if inst==0
    
    % Preallocate the matrix
    phase_corr_matrix=zeros(size(MR.Data{n}));
    
    % Loop over all lines and determine the correction phase
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
        
        cur_phase=phi(MR.Parameter.Gridder.RadialAngles{n}(:,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg),...
            MR.UMCParameters.SystemCorrections.PhaseCorrectionModelParameters{n}(:,z,1,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        phase_corr_matrix(:,:,z,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=...
            single(exp(-1j*repmat(cur_phase,[dims(1) 1 1 1 1 1 1 1 1 1 1 1])));
        
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
    
    % Apply matrix multiplication with single indexing
    MR.Data{n}=MR.Data{n}.*phase_corr_matrix;
    
else % inst==1
    
     % Preallocate the matrix
    phase_corr_matrix_instance=zeros(dims(1:3));
    
    % Loop over all lines and determine the correction phase
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
        
        cur_phase=phi(MR.Parameter.Gridder.RadialAngles{n}(:,:,1,1,dyn,ph,ech,loc,mix,ex1,ex2,avg),...
            MR.UMCParameters.SystemCorrections.PhaseCorrectionModelParameters{n}(:,z,1,dyn,ph,ech,loc,mix,ex1,ex2,avg));
        phase_corr_matrix_instance(:,:,z)=...
            single(exp(-1j*repmat(cur_phase,[dims(1) 1 1 1 1 1 1 1 1 1 1 1])));
        
    end % Z
    
        % Correct first instance (i.e. [x,y,z])
        MR.Data{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg)=MR.Data{n}(:,:,:,coil,dyn,ph,ech,loc,mix,ex1,ex2,avg).*phase_corr_matrix_instance;
        
    end % Coils
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Averages
    
end

% END
end