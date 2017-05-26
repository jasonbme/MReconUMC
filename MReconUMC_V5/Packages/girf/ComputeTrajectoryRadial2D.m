function ComputeTrajectoryRadial2D(MR)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Only works for 2D or stack-of-stars 3D with
% same trajectory in third dimensions.

% Dont execute if 3D gridding is selected
if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    return;
end

% Allocate matrix
num_data=numel(MR.Parameter.Gridder.RadialAngles);
for n=1:num_data;Kd{n}=size(MR.Parameter.Gridder.RadialAngles{n});Kd{n}(end+1:13)=1;end

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(MR.UMCParameters.SystemCorrections.GIRF_output_waveforms*MR.UMCParameters.SystemCorrections.GIRF_time(2)); 
k_accumulated_nom=gamma*cumsum(repmat(MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,[1 2])*MR.UMCParameters.SystemCorrections.GIRF_time(2)); 

% Check orientations and delete whats not required 
if isempty(regexp(MR.Parameter.Scan.REC(1:5),'R'))
    k_accumulated(:,1)=[];
end

if isempty(regexp(MR.Parameter.Scan.REC(1:5),'A'))
    k_accumulated(:,2)=[];
end

if isempty(regexp(MR.Parameter.Scan.REC(1:5),'F'))
    k_accumulated(:,3)=[];
end

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
for ph=1:Kd{n}(6)   % Phases
for dyn=1:Kd{n}(5)  % Dynamics
for z=1:Kd{n}(3)    % Z
    for nl=1:Kd{n}(2)
        Kpos{n}(:,:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
            [interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_real(MR.Parameter.Gridder.RadialAngles{n}(:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated(:,1)),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_imag(MR.Parameter.Gridder.RadialAngles{n}(:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated(:,2)),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
            zeros(numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),1)];
        
        Kpos_nom{n}(:,:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2)=...
            [interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_real(MR.Parameter.Gridder.RadialAngles{n}(:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated_nom(:,1)),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
            interp1qr(MR.UMCParameters.SystemCorrections.GIRF_time,k_imag(MR.Parameter.Gridder.RadialAngles{n}(:,nl,z,1,dyn,ph,ech,loc,mix,ex1,ex2),k_accumulated_nom(:,2)),MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}) ...
            zeros(numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),1)];
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

% Scale to match the requirements of the gridders
Kpos=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos,'UniformOutput',false);
Kpos_nom=cellfun(@(x) permute(.5*x/max(abs(x(:))),[2 1 3 4 5 6 7 8 9 10 11 12]),Kpos_nom,'UniformOutput',false);

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
    subplot(337);for n=1:num_data;plot(1:numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),sqrt(Kpos{n}(1,:,1).*conj(Kpos{n}(1,:,1)+Kpos{n}(2,:,1)).*conj(Kpos{n}(2,:,1))),'Linewidth',2);hold on;end;...
            plot(1:numel(MR.UMCParameters.SystemCorrections.GIRF_ADC_time{n}),sqrt(Kpos_nom{n}(1,:,1).*conj(Kpos_nom{n}(1,:,1)+Kpos_nom{n}(2,:,1)).*conj(Kpos_nom{n}(2,:,1))),'Linewidth',2);grid on;box on;...
            title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

% Use nominal trajectory if required
if strcmpi(MR.UMCParameters.SystemCorrections.GIRF_nominaltraj,'yes')
    Kpos=Kpos_nom;
end

% Assign trajectory
MR.Parameter.Gridder.Kpos=Kpos;

% END
end