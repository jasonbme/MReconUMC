function radial_compute_trajectory_3D(MR)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Only works for 3D.

% Dont execute if 3D gridding is selected
if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D') || ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
    return;
end

% Allocate matrix
num_data=numel(MR.Parameter.Gridder.RadialAngles);
Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize;

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(MR.UMCParameters.SystemCorrections.GirfWaveform*(MR.UMCParameters.SystemCorrections.GirfTime(2)-MR.UMCParameters.SystemCorrections.GirfTime(1))); 
k_accumulated_nom=gamma*cumsum(MR.UMCParameters.SystemCorrections.NominalWaveform*(MR.UMCParameters.SystemCorrections.GirfTime(2)-MR.UMCParameters.SystemCorrections.GirfTime(1)));

% Stack-of-stars specific stuff
if strcmpi(MR.Parameter.Scan.KooshBall,'no')

    % Function handle to compute coordinates for every azimuthal angle
    k_real=@(theta,k_time)(cos(theta)*k_time);
    k_imag=@(theta,k_time)(sin(theta)*k_time);
    
    % Loop over all readouts and compute 
    for n=1:num_data
    for ex2=1:Kd{n}(11) % Extra2
    for ex1=1:Kd{n}(10) % Extra1
    for mix=1:Kd{n}(9)  % Locations
    for loc=1:Kd{n}(8)  % Mixes
    for ech=1:Kd{n}(7)  % Phases
    for ph=1:Kd{n}(6)   % Echos
    for dyn=1:Kd{n}(5)  % Dynamics
    for z=1:Kd{n}(3)    % Z
    for nl=1:Kd{n}(2)
        Kpos{n}(:,:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
            [interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_real(MR.Parameter.Gridder.RadialAngles{n}(:,nl,1,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated(:,1)),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_imag(MR.Parameter.Gridder.RadialAngles{n}(:,nl,1,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated(:,2)),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,((z-ceil(Kd{n}(3)/2))/floor(Kd{n}(3)/2))*k_accumulated(:,3),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech))];
        
        Kpos_nom{n}(:,:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
            [interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_real(MR.Parameter.Gridder.RadialAngles{n}(:,nl,1,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated_nom(:,1)),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,k_imag(MR.Parameter.Gridder.RadialAngles{n}(:,nl,1,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated_nom(:,2)),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech)) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GirfTime,((z-ceil(Kd{n}(3)/2))/floor(Kd{n}(3)/2))*k_accumulated_nom(:,3),MR.UMCParameters.SystemCorrections.GirfADCTime{n}(:,ech))];
    end
    end % Z
    end % Dynamics
    end % Echos
    end % Phases
    end % Mixes
    end % Locations
    end % Extra1
    end % Extra2
    end % Data chunks
end

% Permute k-positions
Kpos=cellfun(@(x) permute(x,[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) permute(x,[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos_nom,'UniformOutput',false);

% Scale to match the requirements of the gridders & apply spatial resolution ratio
Kpos=cellfun(@(x) cell2mat(arrayfun(@(rows) 0.5*x(rows,:,:,:,:,:,:,:,:,:,:,:,:,:)/max(x(rows,:)),1:3,'UniformOutput',false)'),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) cell2mat(arrayfun(@(rows) 0.5*x(rows,:,:,:,:,:,:,:,:,:,:,:,:,:)/max(x(rows,:)),1:3,'UniformOutput',false)'),Kpos_nom,'UniformOutput',false);

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
    subplot(337);for z=1:round(Kd{1}(3)/10):Kd{1}(3);for nl=1:round(Kd{1}(2)/25):Kd{1}(2);plot3((Kpos{1}(1,:,nl,z)),(Kpos{1}(2,:,nl,z)),(Kpos{1}(3,:,nl,z)),'k');hold on;...
                plot3((Kpos_nom{1}(1,:,nl,z)),(Kpos{1}(2,:,nl,z)),(Kpos{1}(3,:,nl,z)),'r');end;end;axis([-.5 .5 -.5 .5 -.5 .5])
    grid on;box on;title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');xlabel('Kx');ylabel('Ky');zlabel('Kz');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

% Use nominal trajectory if required
if strcmpi(MR.UMCParameters.SystemCorrections.GirfNominalTrajectory,'yes')
    Kpos=Kpos_nom;
end

% Assign trajectory 
for n=1:num_data;Kpos{n}(1:2,:,:,:,:,:,:,:,:,:,:,:,:,:)=Kpos{n}(1:2,:,:,:,:,:,:,:,:,:,:,:,:,:)*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio;end
MR.Parameter.Gridder.Kpos=Kpos;

% END
end
