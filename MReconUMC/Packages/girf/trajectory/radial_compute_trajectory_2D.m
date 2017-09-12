function radial_compute_trajectory_2D(MR)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Only works for 2D or stack-of-stars 3D with
% same trajectory in third dimensions.

% Dont execute if 3D gridding is selected
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D') || ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
    return;
end

% Allocate matrix
num_data=numel(MR.Parameter.Gridder.RadialAngles);
for n=1:num_data;Kd{n}=size(MR.Parameter.Gridder.RadialAngles{n});Kd{n}(end+1:13)=1;end

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(MR.UMCParameters.SystemCorrections.GirfWaveform*MR.UMCParameters.SystemCorrections.GirfTime(2)); 
k_accumulated_nom=gamma*cumsum(MR.UMCParameters.SystemCorrections.NominalWaveform*MR.UMCParameters.SystemCorrections.GirfTime(2)); 

% Function handle to compute coordinates for every azimuthal angle
k_real=@(theta,k_time)(cos(theta)*k_time);
k_imag=@(theta,k_time)(sin(theta)*k_time);

% Loop over all readouts and compute 
for n=1:num_data
for ex2=1:Kd{n}(11) % Extra2
for ex1=1:Kd{n}(10) % Extra1
for mix=1:Kd{n}(9)  % Locations
for loc=1:Kd{n}(8)  % Mixes
for ech=1:Kd{n}(7)  % Echoes
    % Prototyping to do interpolation once
    TMP=...
    [interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_accumulated(:,1),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
    interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_accumulated(:,2),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
    zeros(numel(MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)),1)]';
        
    TMP_nom=...
    [interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_accumulated_nom(:,1),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
    interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_accumulated_nom(:,2),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
    zeros(numel(MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)),1)]';
for ph=1:Kd{n}(6)   % Phases
for dyn=1:Kd{n}(5)  % Dynamics
for z=1:Kd{n}(3)    % Z
    
    Kpos{n}(:,:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
    permute(cat(3,cos(MR.Parameter.Gridder.RadialAngles{n}(:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP(1,:),...
    sin(MR.Parameter.Gridder.RadialAngles{n}(:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP(2,:),...
    zeros(Kd{n}(2),1)*TMP(3,:)),[2 3 1]);

    Kpos_nom{n}(:,:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
    permute(cat(3,cos(MR.Parameter.Gridder.RadialAngles{n}(:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP_nom(1,:),...
    sin(MR.Parameter.Gridder.RadialAngles{n}(:,:,z,1,dyn,ph,ech,loc,mix,ex1,ex2)')*TMP_nom(2,:),...
    zeros(Kd{n}(2),1)*TMP_nom(3,:)),[2 3 1]);

end % Z
end % Dynamics
end % Echos
end % Phases
end % Mixes
end % Locations
end % Extra1
end % Extra2
end % Data chunks

% Scale to match the requirements of the gridders
Kpos=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos_nom,'UniformOutput',false);

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
    subplot(337);for n=1:num_data;for ech=1:Kd{n}(7);
            M1=Kpos{n}(1,:,1,1,1,1,ech);M2=Kpos{n}(2,:,1,1,1,1,ech);N1=Kpos_nom{n}(1,:,1,1,1,1,ech);N2=Kpos_nom{n}(2,:,1,1,1,1,ech);
            plot(MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech),sqrt(M1.*conj(M1)+M2.*conj(M2)),'k','Linewidth',2);hold on;
            plot(MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech),sqrt(N1.*conj(N1)+N2.*conj(N2)),'r--','Linewidth',2);hold on;end;end;grid on;box on;

            axis([MR.UMCParameters.SystemCorrections.GirfADCTime{1}(1,1) MR.UMCParameters.SystemCorrections.GirfADCTime{num_data}(end,Kd{num_data}(7)) 0 0.75 ]);
            title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

% Use nominal trajectory if required
if strcmpi(MR.UMCParameters.SystemCorrections.GirfNominalTrajectory,'yes')
    Kpos=Kpos_nom;
end

% Assign trajectory & Apply spatial resolution factor
MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,...
    Kpos,'UniformOutput',false);

% END
end