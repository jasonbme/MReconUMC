function apply_zeroth_order_gradient_impulse_response(MR)
%Applies the girf on the nominal gradient waveform, and save it in a matrix
% for phase correction on the data.
%
% 20170830 - T.Bruijnen

%% Logic & display 
% Only perform if this is desired
if ~strcmpi(MR.UMCParameters.SystemCorrections.PhaseCorrection,'girf')
    return;
end

% Assign variables for increased readabillity
t=MR.UMCParameters.SystemCorrections.GirfTime;
f=MR.UMCParameters.SystemCorrections.GirfZerothFrequency;
girf=MR.UMCParameters.SystemCorrections.GirfZeroth;
t_adc=MR.UMCParameters.SystemCorrections.GirfADCTime;

% Zeropad nominal waveform and time vector with 5 ms on both sides
dt_wf=abs(t(2)-t(1));
t_us=0:dt_wf:10E-03+t(end)-dt_wf;
zp=round(5E-03/dt_wf);
wf_us=zeros(numel(t_us),3);
wf_us(zp+1:zp+numel(t),:)=MR.UMCParameters.SystemCorrections.NominalWaveform*10^-3;

% Fourier transform the input waveform
F_waveform=fftshift(fft(fftshift(wf_us,1),[],1),1);

% Generate frequency vector of input
df_wf = 1/dt_wf/numel(t_us);
f_wf = df_wf*(0:numel(t_us)-1);
f_wf = f_wf-df_wf*ceil((numel(t_us)-1)/2); % Frequencies

% Resample the GIRF
for ax=1:3;rs_girf(:,ax)=interp1(f,girf(:,ax),f_wf);rs_girf(isnan(rs_girf))=0;end

% Apply girf
F_phase_error=F_waveform.*rs_girf;

% Store phase in matrix for trajectory specific interpolation operation
error_us=real(fftshift(ifft(ifftshift(F_phase_error,1),[],1),1));
MR.UMCParameters.SystemCorrections.PhaseErrorMatrix=error_us(zp+1:zp+numel(t),:);

%END
end
