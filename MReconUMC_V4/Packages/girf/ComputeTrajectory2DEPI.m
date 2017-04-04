function Kpos = ComputeTrajectory2DEPI(Kdims,waveforms_nom,waveforms_corrected,waveform_time,ADC_time,orientation,usenominal,vis)

% Allocate matrix
Kpos=zeros(Kdims(1),Kdims(2));
Kpos_nom=zeros(Kdims(1),Kdims(2));

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

% Compute trajectory
Kpos=reshape(interp1(waveform_time,k_accumulated(:,1),ADC_time)+1j*interp1(waveform_time,k_accumulated(:,2),ADC_time),[Kdims(1) Kdims(2)]);
Kpos_nom=reshape(interp1(waveform_time,k_accumulated_nom(:,1),ADC_time)+1j*interp1(waveform_time,k_accumulated_nom(:,2),ADC_time),[Kdims(1) Kdims(2)]);


% Scale to match the requirements of the gridders, slightly different
% scaling then for radial
if max(abs(real(Kpos(:))))>max(abs(imag(Kpos(:))))
    maxval=max(abs(real(Kpos(:))));
else
    maxval=max(abs(imag(Kpos(:))));
end

if max(abs(real(Kpos_nom(:))))>min(abs(real(Kpos_nom(:))))
    maxval_nom=max(abs(real(Kpos_nom(:))));
else
    maxval_nom=max(abs(imag(Kpos_nom(:))));
end

Kpos=.5*Kpos/maxval;
Kpos_nom=.5*Kpos_nom/maxval_nom;

% Visualization
if verbose
    subplot(337);plot(real(Kpos(:)),imag(Kpos(:)),'Linewidth',2);hold on;plot(real(Kpos_nom(:)),imag(Kpos_nom(:)),'Linewidth',2);grid on;box on;title('Corrected vs nominal K-space trajectory');legend('Corrected','Nominal');
    xlabel('Time [ms]');ylabel('K-space cycles/m');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold');axis([-.6 .6 -.6 .6])
end

% Use nominal trajectory if selected
if strcmpi(usenominal,'yes')
    Kpos=Kpos_nom;
end

% END
end