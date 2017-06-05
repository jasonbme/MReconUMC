function apply_gradient_impulse_response(MR)
% Input requires the estimated waveform wf with corresponding time vector
% And the GIRF(frequency domain) with corresponding frequency vector

% Assign variables for increased readabillity
t=MR.UMCParameters.SystemCorrections.GIRF_time;
f=MR.UMCParameters.SystemCorrections.GIRF_frequencies;
girf=MR.UMCParameters.SystemCorrections.GIRF_transfer_function;
t_adc=MR.UMCParameters.SystemCorrections.GIRF_ADC_time;

% Fourier transform the input waveform
F_wf=fftshift(fft(fftshift(MR.UMCParameters.SystemCorrections.GIRF_input_waveforms,1),[],1),1);

% Generate frequency vector of input
dt_wf=abs(t(2)-t(1));
df_wf = 1/dt_wf/numel(t);
f_wf = df_wf*(0:numel(t)-1);
f_wf = f_wf-df_wf*ceil((numel(t)-1)/2); % Frequencies

% Resample the GIRF
for ax=1:3;rs_girf(:,ax)=interp1(f,girf(:,ax),f_wf);rs_girf(isnan(rs_girf))=0;end
%rs_girf=ones(size(rs_girf));

% Incorporate preemphasis if required & Apply girf
if strcmpi(MR.UMCParameters.SystemCorrections.GIRF_preemphasis,'no')
    F_wf_corr=F_wf.*rs_girf;
else
    %%% Preemp mode %%%
    nf=numel(f_wf);
    pe_filter=zeros(size(rs_girf(:,1)));
    pe_filter(nf/2+1-round(MR.UMCParameters.SystemCorrections.GIRF_preemphasis_bw/2/df_wf):nf/2+1+round(MR.UMCParameters.SystemCorrections.GIRF_preemphasis_bw/2/df_wf))=1;
    for j=1:3;inv_rs_girf(:,j)=pe_filter.*(1./conj(rs_girf(:,j)));end;inv_rs_girf(isnan(inv_rs_girf))=0;
    F_wf_corr=conj(rs_girf).*(F_wf.*inv_rs_girf);
end

% Inverse Fourier transform
MR.UMCParameters.SystemCorrections.GIRF_output_waveforms=-1*real(fftshift(ifft(ifftshift(F_wf_corr,1),[],1),1));

if MR.UMCParameters.ReconFlags.Verbose
    % Visualization
    t=t*10^3;
    t_adc=cellfun(@(x) x*10^3,t_adc,'UniformOutput',false);
    wf=MR.UMCParameters.SystemCorrections.GIRF_input_waveforms;
    incr=1;
    hfig=figure(9);
    scrsz = get(0,'ScreenSize');
    set(hfig,'position',scrsz);
    
    link(1)=subplot(331);for ax=1:3;plot(t,wf(:,ax),'LineWidth',2);hold on;end;axis([-0.5 1.1*max(t) -1.1*max(abs(wf(:,1))) 1.1*max(abs(wf(:,1)))]);
    title(['Input waveform |',' slewrate ~ ',num2str(round(max(diff(wf(:,1)))/(t(2)-t(1)))),' T/m/s']);legend('M','P','S')
    ylabel('Gradient str [mT/m]');xlabel('Time [ms]');hold on;plot([0.0005 0.0005 ],[-1 1],'k--');hold on;plot([t(end)-0.0005 t(end)-0.0005 ],[-1 1],'k--');grid on
    hold on;for ax=1:1;scatter(t_adc{1}(1:incr:end),interp1(t,wf(:,ax),t_adc{1}(1:incr:end)),5,'r');end;set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    %lnk(1)=subplot(332);plot(f_wf,abs(F_wf(:,1)),'LineWidth',2);axis([-25000 25000 0 1.1*max(abs(F_wf(:,1)))]);title('Input FFT waveform');xlabel('Frequency [Hz]');ylabel('Intensity [a.u.]');grid on;set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    link(2)=subplot(332);for ax=1:3;plot(t,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms(:,ax),'LineWidth',2);title('Corrected waveform');hold on;end;axis([-0.5 1.1*max(t) -1.1*max(abs(wf(:,1))) 1.1*max(abs(wf(:,1)))]);ylabel('Gradient str [mT/m]');xlabel('Time [ms]');hold on;plot([0.0005 0.0005 ],[-1 1],'k--');hold on;plot([t(end)-0.0005 t(end)-0.0005 ],[-1 1],'k--');grid on
    hold on;for ax=1:1;scatter(t_adc{1}(1:incr:end),interp1(t,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms(:,ax),t_adc{1}(1:incr:end)),5,'r');hold on;end;legend('M','P','S');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    %lnk(2)=subplot(334);plot(f_wf,abs(F_wf_corr(:,1)),'LineWidth',2);axis([-25000 25000 0 1.1*max(abs(F_wf(:,1)))]);title('Filtered FFT waveform');xlabel('Frequency [Hz]');ylabel('Intensity [a.u.]'); grid on;set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    subplot(333);for ax=1:3;plot(t,MR.UMCParameters.SystemCorrections.GIRF_output_waveforms(:,ax)-wf(:,ax),'LineWidth',2);hold on;end;title('Difference [Corrected - input]');axis([-0.5 1.1*max(t) -1.1*max(abs(wf(:,1))) 1.1*max(abs(wf(:,1)))]);ylabel('Gradient str [mT/m]');xlabel('Time [ms]'); grid on;set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    uwangle1=unwrap(angle(rs_girf(:,1)));cp=floor(size(uwangle1,1)/2)+1;legend('M','P','S')
    uwangle2=unwrap(angle(rs_girf(:,2)));cp=floor(size(uwangle1,1)/2)+1;
    uwangle3=unwrap(angle(rs_girf(:,3)));cp=floor(size(uwangle1,1)/2)+1;

    subplot(334);[axe,h1,h2]=plotyy(f_wf,abs(rs_girf(:,1)),f_wf,uwangle1-uwangle1(cp));set(h1,'linewidth',2);set(h2,'linewidth',2);set(axe(1),'YTick',0:.2:1.2);set(axe(2),'YTick',-10:2.5:10);title('Resampled GIRF 1');axis(axe(1),[-25000 25000 0 1.2]);axis(axe(2), [-25000 25000 -10 10]);xlabel('Frequency [Hz]');ylabel('Intensity [a.u.]');grid on;legend('Magnitude','Phase');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    subplot(335);[axe,h1,h2]=plotyy(f_wf,abs(rs_girf(:,2)),f_wf,uwangle2-uwangle2(cp));set(h1,'linewidth',2);set(h2,'linewidth',2);set(axe(1),'YTick',0:.2:1.2);set(axe(2),'YTick',-10:2.5:10);title('Resampled GIRF 2');axis(axe(1),[-25000 25000 0 1.2]);axis(axe(2), [-25000 25000 -10 10]);xlabel('Frequency [Hz]');ylabel('Intensity [a.u.]');grid on;legend('Magnitude','Phase');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')
    subplot(336);[axe,h1,h2]=plotyy(f_wf,abs(rs_girf(:,3)),f_wf,uwangle3-uwangle3(cp));set(h1,'linewidth',2);set(h2,'linewidth',2);set(axe(1),'YTick',0:.2:1.2);set(axe(2),'YTick',-10:2.5:10);title('Resampled GIRF 3');axis(axe(1),[-25000 25000 0 1.2]);axis(axe(2), [-25000 25000 -10 10]);xlabel('Frequency [Hz]');ylabel('Intensity [a.u.]');grid on;legend('Magnitude','Phase');set(gca,'LineWidth',2,'FontSize',12,'FontWeight','bold')

    linkaxes(link,'xy');%linkaxes(lnk,'xy');
end

%END
end
