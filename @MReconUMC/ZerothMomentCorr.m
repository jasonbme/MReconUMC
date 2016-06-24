function ZerothMomentCorr( MR )
% 20160616 - Apply zeroth moment correction. This has not been thoroughly
% tested, I am not using this at the moment. Will probably be beneficial
% when we fix the k-space trajectory.

if strcmp(MR.ParUMC.ZerothMomentCorrection,'yes');
    % Notification
    fprintf('Applying zeroth moment correction ................  ');tic
    
    % Find zero moment scaling factors (zmmatrix)
    dims=size(MR.Data);
    MR.Data=permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2)*dims(5) 1]),[1 4 2 3 5]);
    ndims=size(MR.Data);
    zmabs=abs(MR.Data(dims(1)/2+1,:,:,:));
    zmreal=real(MR.Data(dims(1)/2+1,:,:,:));
    zmimag=imag(MR.Data(dims(1)/2+1,:,:,:));
    zm2=sum(abs(MR.Data));
    avgzm=sum(squeeze(zm2))/(dims(2)*dims(5)); % Mean zeroth moment per coil
    zmmatrix=zeros(ndims);
    for nc=1:dims(4)
        zmmatrix(:,:,:,nc,:)=repmat((avgzm(nc))./(zm2(:,:,:,nc,:)),[dims(1) 1 dims(3) 1 1 ]);
    end
    
    % Apply zero momenth scaling
    MR.Data=MR.Data.*zmmatrix;
    MR.Data=fft(permute(reshape(permute(MR.Data,[1 3 4 2 5]),[dims(1) dims(3) dims(4) dims(2) dims(5)]),[1 4 2 3 5]));
    % Notification
    fprintf('Finished [%.2f sec] \n',toc')
end

% END
end