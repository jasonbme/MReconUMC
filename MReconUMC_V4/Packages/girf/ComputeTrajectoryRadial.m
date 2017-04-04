function Kpos = ComputeTrajectoryRadial(radialangles,waveforms_nom,waveforms_corrected,waveform_time,ADC_time,orientation,usenominal,verbose)
% Compute k-space coordinates [-1;1] for radial acquisitions from the GIRF
% modified gradient waveforms. Only works for 2D or stack-of-stars 3D with
% same trajectory in third dimensions.

% Allocate matrix
Kpos=zeros(numel(ADC_time),numel(radialangles));

% Gyromagnetic ratio
gamma=267.513e+06; % [Hz/T]

% Pre-compute the cummulative k-space for the maximum gradient
k_accumulated=gamma*cumsum(waveforms_corrected*waveform_time(2)); 
k_accumulated_nom=gamma*cumsum(repmat(waveforms_nom,[1 2])*waveform_time(2)); 

% Check orientations and delete whats not required
if isempty(regexp(orientation(1:5),'R'))
    k_accumulated(:,1)=[];
end

if isempty(regexp(orientation(1:5),'A')) 
    k_accumulated(:,2)=[];
end

if isempty(regexp(orientation(1:5),'F')) 
    k_accumulated(:,3)=[];
end

% Function handle to compute coordinates for every azimuthal angle
k_real=@(theta,k_time)(cos(theta)*k_time);
k_imag=@(theta,k_time)(sin(theta)*k_time);

% Loop over all readouts and compute 
for nl=1:numel(radialangles)
   Kpos(:,nl)=-1*interp1(waveform_time,k_real(radialangles(nl),k_accumulated(:,1)),ADC_time)-1j*interp1(waveform_time,k_imag(radialangles(nl),k_accumulated(:,2)),ADC_time);
   Kpos_nom(:,nl)=-1*interp1(waveform_time,k_real(radialangles(nl),k_accumulated_nom(:,1)),ADC_time)-1j*interp1(waveform_time,k_imag(radialangles(nl),k_accumulated_nom(:,2)),ADC_time);
end

% Scale to match the requirements of the gridders
Kpos=.5*Kpos/max(abs(Kpos(:)));
Kpos_nom=.5*Kpos_nom/max(abs(Kpos_nom(:)));

% Visualization
if verbose
    subplot(337);plot(1:numel(ADC_time),abs(Kpos(:,1)),'Linewidth',2);hold on;plot(1:numel(ADC_time),abs(Kpos_nom(:,1)),'Linewidth',2);grid on;box on;title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');
    xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');
end

if strcmpi(usenominal,'yes')
    Kpos=Kpos_nom;
end

% END
end