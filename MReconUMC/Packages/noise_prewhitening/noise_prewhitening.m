function noise_prewhitening( MR )
% Perform noise_prewhitening

if strcmpi(MR.UMCParameters.SystemCorrections.NoisePreWhitening,'no')
    return
end

% Notification
fprintf('     Include noise prewhitening ..................  ');tic;

% Calculate noise covariance matrix
MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx=noise_covariance_mtx(squeeze(MR.UMCParameters.SystemCorrections.NoiseData));

% Calculate noise decorrelation matrix
MR.UMCParameters.SystemCorrections.NoiseDecorrelationMtx=noise_decorrelation_mtx(MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx);

% Apply noise prewhitening
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(dims);
for n=1:num_data;MR.Data{n}=ipermute(apply_noise_decorrelation_mtx(permute(MR.Data{n},[1 2 3 5:12 4]),MR.UMCParameters.SystemCorrections.NoiseDecorrelationMtx),[1 2 3 5:12 4]);end
    
% Remove noise samples
MR.UMCParameters.SystemCorrections.NoiseData=[];

% Visualization
if MR.UMCParameters.ReconFlags.Verbose
   subplot(339);imagesc(abs(MR.UMCParameters.SystemCorrections.NoiseCorrelationMtx));colormap jet;axis off;title('Noise covariance matrix');colorbar
end    

% Notification
fprintf('Finished [%.2f sec]\n',toc')

% END
end