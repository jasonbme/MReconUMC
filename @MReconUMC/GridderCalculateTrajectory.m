function GridderCalculateTrajectory( MR )
%% Calculate k-space trajectory

if strcmpi(MR.UMCParameters.LinearReconstruction.ProfileSpacing,'golden')
    % Alternating is no
    MR.Parameter.Gridder.AlternatingRadial='no';
    
    % Reshape for reconframes reconstructions 
    [ns,nl,nz,nc,ndyn]=size(MR.Data);
    MR.Data=reshape(permute(MR.Data,[1 2 5 3 4]),[ns nl*ndyn nz nc 1]);

    % Set golden angles
    GA=@(n)(pi/(((1+sqrt(5))/2)+n-1)); 
    nGA=MR.UMCParameters.LinearReconstruction.Goldenangle; 
    MR.Parameter.Gridder.RadialAngles=mod((0:GA(nGA):(nl*ndyn-1)*GA(nGA)),2*pi);
    
    % Calculate trajectory (Kpos, Weights)
    GridderCalculateTrajectory@MRecon(MR)
    
    % Reshape back to [ns nl nz nc ndyn]
    MR.Data=permute(reshape(MR.Data,[ns nl ndyn nz nc]),[1 2 4 5 3]);
end

% Set weights and trajectory for greengard nufft
if strcmpi(MR.UMCParameters.LinearReconstruction.ProfileSpacing,'golden') && ...
        ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon')
    MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles+pi/2;
    MR.Parameter.Gridder.Kpos=radialTRAJ(MR.Parameter.Gridder.RadialAngles,MR.UMCParameters.LinearReconstruction.KspaceSize,...
        MR.UMCParameters.LinearReconstruction.ProfileSpacing,MR.UMCParameters.LinearReconstruction.Goldenangle);
    MR.Parameter.Gridder.Weights=radialDCF(MR.Parameter.Gridder.Kpos);
end

% END
end