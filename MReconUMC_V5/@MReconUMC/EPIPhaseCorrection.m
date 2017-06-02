function EPIPhaseCorrection( MR )
% Overload EPI phase correction function

% logic
if ~strcmpi(MR.Parameter.Scan.FastImgMode,'EPI')
    return; end

% Perform linear gridding
% num_data=numel(MR.Data);dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;
% coords=MR.Parameter.Labels.NusEncNrs;
% D={};
% for n=1:num_data
%     for nl=1:dims{n}(2)
%         for c=1:dims{n}(4)
%             for dyn=1:dims{n}(5)
%                 D{n}(:,nl,1,c,dyn)=interp1(coords,real(MR.Data{n}(:,nl,1,c,dyn,1,1,1,1,1)),coords(1):(coords(end)-coords(1))/255:coords(end))+1j*interp1(coords,imag(MR.Data{n}(:,nl,1,c,dyn,1,1,1,1,1)),coords(1):(coords(end)-coords(1))/255:coords(end));
%             end
%         end
%     end
% end
% MR.Data=D;clear D

% Perform 1D iFFT along measurement direction
MR.Data=cellfun(@(x) fftshift(ifft(ifftshift(x,1)),1),MR.Data,'UniformOutput',false);
MR.Parameter.ReconFlags.isimspace=[1,0,0];
%MR.Parameter.ReconFlags.isgridded=1;

% Perform MRecons phase correction
EPIPhaseCorrection@MRecon(MR);

% If data is not in cell, transform to cell
if ~iscell(MR.Data)
    MR.Data={MR.Data};
end

% 1D FFT
MR.Data=cellfun(@(x) ifftshift(fft(fftshift(x,1)),1),MR.Data,'UniformOutput',false);
MR.Parameter.ReconFlags.isimspace=[0,0,0];
%MR.Parameter.ReconFlags.gridded=0;

% END
end
