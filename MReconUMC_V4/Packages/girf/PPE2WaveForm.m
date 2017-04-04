function [t,wf,adc] = PPE2WaveForm( MR )
% Script to derive the nominal gradient waveforms for all readouts 

% Load in all required gradients
%GR.dt=0.0000064;
GR.dt=0.000001;
gradients={'mc0';'m0';'m1';'m2';'m3';'md'};

% Load in all atributes that I need
for j=1:numel(gradients);GR.([gradients{j}])=ExtractGradientInfo(MR,gradients{j});end
    
% Compute important time points per gradient from attributes
for j=1:numel(gradients);GR.([gradients{j}]).t=[GR.([gradients{j}]).offset GR.([gradients{j}]).slope1 GR.([gradients{j}]).lenc GR.([gradients{j}]).slope2];end

% Replace 0s with the 0.0001 * dwell time, otherwise I get problems with the
% interpolation step (not monotoneously increasing
for j=1:numel(gradients);GR.([gradients{j}]).t(GR.([gradients{j}]).t==0)=0.0001*GR.dt;end

% Calculate cummulative duration to get timelines
for j=1:numel(gradients);GR.([gradients{j}]).t=cumsum(GR.([gradients{j}]).t);end

% Get gradient amplitudes corresponding to the timepoints
for j=1:numel(gradients);GR.([gradients{j}]).A=[0 GR.([gradients{j}]).str GR.([gradients{j}]).str 0];end

% Interpolate all gradient amplitudes to a nominal timeline
% Calculate maximum timepoint that I need to know
maxt=0;for j=1:numel(gradients);if GR.([gradients{j}]).t(end)>maxt;maxt=GR.([gradients{j}]).t(end);end;end
t=0:GR.dt:maxt;C=[];
for j=1:numel(gradients);C(:,j)=interp1(GR.([gradients{j}]).t,GR.([gradients{j}]).A,t,'linear');end
C(isnan(C))=0; % Remove interpolation NaNs

% Sum all gradient waveforms
wf=sum(C,2);

% Synchronize ADC points with gradient waveform
ADC=ExtractADCInfo(MR);
adc=ADC.time-ADC.ref:ADC.dt:ADC.time-ADC.ref+ADC.dur;

% END
end