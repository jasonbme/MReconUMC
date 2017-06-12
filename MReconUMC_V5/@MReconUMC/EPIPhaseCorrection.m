function EPIPhaseCorrection( MR )
% Overload EPI phase correction function

% logic
if ~strcmpi(MR.Parameter.Scan.FastImgMode,'EPI')
    return; end
% 
% % Dimensionality
% Kd=MR.UMCParameters.AdjointReconstruction.KspaceSize{1};
% Id=MR.Parameter.Gridder.OutputMatrixSize{1};
% 
% % Reshape calibration data to [Kd(1) Kd(2) Kd(4)]
% calib_data=permute(reshape(MR.UMCParameters.SystemCorrections.CalibrationData,[Kd(1) Kd(4) Kd(2)]),[1 3 4 2]);
% MR.UMCParameters.SystemCorrections.CalibrationData=[];
% 
% % Determine phase at k0 for each readout and receiver
% % First very coarse approach
% phase_errors=zeros(Kd(2),Kd(4));
% cp=ceil(Kd(1)/2)+1;
% for c=1:Kd(4)
%     for pe=2:2:Kd(2)-1
%         d1=angle(calib_data(cp,pe,1,c))-angle(calib_data(cp,pe-1,1,c));
%         d2=angle(calib_data(cp,pe,1,c))+angle(calib_data(cp,pe-1,1,c));
%         if abs(d1)>abs(d2)
%             d=d2;
%         else
%             d=d1;
%         end
%         phase_errors(floor(pe/2)+1,c)=d;
%         %phase_errors(pe,c)=d;
%     end
% end
% 
% % Now for every coil select a phase error to add to every even readout
% phase_correction_mtx=ones(Kd);
% for c=1:Kd(4)
%     phase_correction_mtx(:,2:2:end,:,c)=exp(-1j*median(phase_errors(:,c)));
% end
% 
% %phase_correction_mtx=repmat(permute(exp(-1j*phase_errors),[3 1 4 2]),[Kd(1) 1 1 1]);
% 
%     
% % Apply the correction
% %MR.Data{1}=MR.Data{1}.*phase_correction_mtx;
% a=MR.Data{1}.*phase_correction_mtx;
% 
% slicer(rot90(squeeze(abs(fftshift(fft2(ifftshift(a))))),1));


%END
end


%n1d_for=@(y)(nufft(y,d));
