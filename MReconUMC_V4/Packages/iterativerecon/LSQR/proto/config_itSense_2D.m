function data = config_itSense_2D(MR,IR)

% LSQR settings
ops=optimset('Display','off');

% Get dimensions
[nx,ny,nz,nc,ndyn]=MR.UMCParameters.AdjointReconstruction.IspaceSize(5);

% Track progress
parfor_progress(ndyn*nz);

for dyn=1:ndyn
    
    % Save temporarily arrays
    params.k=MR.Parameter.Gridder.Kpos(:,:,:,:,dyn);
    params.w=MR.Parameter.Gridder.Weights(:,:,:,:,dyn);
    
    for z=1:nz
        params.data=MR.Data(:,:,z,:);
        parfor_progress;
        
    end
end

% END
end