function WALSH(MR)
% Function to use Walsh et al. his method to compute the coil sensitivity
% maps for 2D/3D.

% Check whether its multi 2D or 3D data
if (strcmpi(MR.Parameter.Scan.ScanMode,'2D')) || (strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'2D') && strcmpi(MR.Parameter.Scan.AcqMode,'Radial'))
    
    % Track progress
    parfor_progress(MR.UMCParameters.AdjointReconstruction.IspaceSize{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber}(3));

    % (m)2D cases
    for z=1:MR.UMCParameters.AdjointReconstruction.IspaceSize{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber}(3)
        
        % Estimate csm
        [~,MR.Parameter.Recon.Sensitivities(:,:,:,z)]=openadapt(permute(MR.Data{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber}(:,:,z,:),[4 1 2 3]));
        
        % Track progress
        parfor_progress;
        
    end
    
    
elseif strcmpi(MR.Parameter.Scan.ScanMode,'3D')
    
    % 3D case
    [~,MR.Parameter.Recon.Sensitivities]=openadapt(permute(MR.Data{MR.UMCParameters.AdjointReconstruction.CoilMapEchoNumber},[4 1 2 3]));
        
end

% Reshape to [x,y,z,coil] dimension
MR.Parameter.Recon.Sensitivities=permute(single(MR.Parameter.Recon.Sensitivities),[2 3 4 1]);

% END
end