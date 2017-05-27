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
% This is not making the images better yet, however a matrix of ones also should not give good results (eye(coils))
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(dims);
for n=1:num_data;MR.Data{n}=double(reshape(permute(MR.Data{n},[4 1 2 3 5 6 7 8 9 10 11 12]),[dims{n}(4) prod(dims{n})/dims{n}(4)]));
MR.Data{n}=single(permute(reshape(MR.UMCParameters.SystemCorrections.NoiseDecorrelationMtx*MR.Data{n},[dims{n}(4) dims{n}([1:3 5:12])]),[2 3 4 1 5 6 7 8 9 10 11 12]));end

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