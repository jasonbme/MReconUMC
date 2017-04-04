function [t,wf,adc] = PPE2WaveForm_proto( MR )
% Script to derive the nominal gradient waveforms for all readouts 

% Load in all required gradients
%GR.dt=0.0000064;
GR.dt=0.000001;
gradients={'mc0';'m0';'m1';'m2';'m3';'md';'blip';'s_ex';'d';'r';'py';'pyr'};


% Load in all atributes that I need
for j=1:numel(gradients);GR.([gradients{j}])=ExtractGradientInfo(MR,gradients{j});end
    
% Compute important time points per gradient from attributes
for j=1:numel(gradients);GR.([gradients{j}]).t=[GR.([gradients{j}]).offset GR.([gradients{j}]).slope1 GR.([gradients{j}]).lenc GR.([gradients{j}]).slope2 0.5*10^-3];end % .5 ms extra zero padding

% Replace 0s with the 0.0001 * dwell time, otherwise I get problems with the
% interpolation step (not monotoneously increasing
for j=1:numel(gradients);GR.([gradients{j}]).t(GR.([gradients{j}]).t==0)=0.0001*GR.dt;end

% Deal with the SQ`fin and SQ`xbase stuff with timings
for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'xbase');GR.([gradients{j}]).t(1)=GR.([gradients{j}]).t(1)+MR.Parameter.GetValue('SQ`base:dur2')*10^(-3);end;end
for j=1:numel(gradients);if strcmpi(GR.([gradients{j}]).sq,'fin');GR.([gradients{j}]).t(1)=GR.([gradients{j}]).t(1)+MR.Parameter.GetValue('SQ`base:dur2')*10^(-3)+MR.Parameter.GetValue('SQ`xbase:dur2')*10^(-3);end;end

% Get gradient amplitudes corresponding to the timepoints
for j=1:numel(gradients);GR.([gradients{j}]).A=[0 GR.([gradients{j}]).str GR.([gradients{j}]).str 0 0];end

% if EPI repeat timepoints and amps points N times
if strcmpi(MR.Parameter.Scan.Technique,'FEEPI')
    GR.m0.t=[GR.m0.t(1) repmat(GR.m0.t(2:4),[1 MR.Parameter.Scan.Samples(2)])];
    GR.m0.A=[0 repmat(GR.m0.A(2:4),[1 MR.Parameter.Scan.Samples(2)])];
    
    % Swap polarities of readout gradient
    for tps=2:3:numel(GR.m0.A)
        GR.m0.A(tps:tps+2)=GR.m0.A(tps:tps+2)*(-1)^((tps-2)/3);
    end
    
    GR.blip.t=[GR.blip.t(1) repmat([GR.blip.t(2:4) GR.m0.dur-GR.blip.dur],[1 MR.Parameter.Scan.Samples(2)-1])];
    GR.blip.A=[GR.blip.A(1) repmat([GR.blip.A(2:4) 0],[1 MR.Parameter.Scan.Samples(2)-1])];
end

% Calculate cummulative duration to get timelines
for j=1:numel(gradients);GR.([gradients{j}]).t=cumsum(GR.([gradients{j}]).t);end

% Interpolate all gradient amplitudes to a nominal timeline for each axis
% Calculate maximum timepoint that I need to know
maxt=0;for j=1:numel(gradients);if GR.([gradients{j}]).t(end)>maxt;maxt=GR.([gradients{j}]).t(end);end;end
t=-1000*GR.dt:GR.dt:maxt;C=zeros(numel(t),numel(gradients),3); % 3 = number of axis
for j=1:numel(gradients);C(:,j,GR.([gradients{j}]).ori+1)=interp1(GR.([gradients{j}]).t,GR.([gradients{j}]).A,t,'linear');end
C(isnan(C))=0; % Remove interpolation NaNs

% Sum all gradient waveforms
wf=squeeze(sum(C,2));

% Synchronize ADC points with gradient waveform
ADC=ExtractADCInfo(MR);adc=[];
for j=1:ADC.nr_acq;offset=(j-1)*ADC.epi_dt;adc=[adc offset+ADC.offset:ADC.dt:ADC.offset+ADC.dur-0.00000000001+offset];end

% IF radial sampling  P-axis equals M-axis 
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
    wf(:,2)=wf(:,1);
end
% Visualize
%figure,ax(1)=subplot(311);plot(t,wf(:,1));title('M-axis');hold on;scatter(adc,interp1(t,wf(:,1),adc),5,'r');ax(2)=subplot(312);plot(t,wf(:,2));title('P-axis');ax(3)=subplot(313);plot(t,wf(:,3));title('S-axis');linkaxes(ax,'x');
% END
end