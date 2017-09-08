function radial_apply_phase_correction_2D(MR)
%Apply the girf obtained phase correction
% Interpolate the error matrix from apply_zeroth_order_gradient_impulse_response.m to the k-space data

% Logic
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'girf') || ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D')
    return;
end

% Allocate matrix
num_data=numel(MR.Parameter.Gridder.RadialAngles);
for n=1:num_data;Kd{n}=size(MR.Parameter.Gridder.RadialAngles{n});Kd{n}(end+1:13)=1;end

% Loop over all readouts and compute 
for n=1:num_data
for ex2=1:Kd{n}(11) % Extra2
for ex1=1:Kd{n}(10) % Extra1
for mix=1:Kd{n}(9)  % Locations
for loc=1:Kd{n}(8)  % Mixes
for ech=1:Kd{n}(7)  % Echoes
    % Prototyping to do interpolation once
    TMP=...
    [interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,-MR.UMCParameters.SystemCorrections.PhaseErrorMatrix(:,1),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
    interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,-MR.UMCParameters.SystemCorrections.PhaseErrorMatrix(:,2),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech))]';
        
for ph=1:Kd{n}(6)   % Phases
for dyn=1:Kd{n}(5)  % Dynamics
for c=1:MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(4)
for z=1:MR.UMCParameters.AdjointReconstruction.IspaceSize{1}(3)    % Z
    
    MR.Data{n}(:,:,z,c,dyn,ph,ech,loc,mix,ex1,ex2)=MR.Data{n}(:,:,z,c,dyn,ph,ech,loc,mix,ex1,ex2).*...
    exp(1j*permute(cos(MR.Parameter.Gridder.RadialAngles{n}(:,:,:,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP(1,:)+...
    sin(MR.Parameter.Gridder.RadialAngles{n}(:,:,:,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP(2,:),[2 1]));

end % Z
end % Coils
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Data chunks

% END
end