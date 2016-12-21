function CalculateTrajectory( MR )
% Calculate k-space trajectory

% Notification
fprintf('Calculating trajectory............................  ');tic
switch lower(MR.Parameter.Scan.AcqMode)
    case 'radial'
        if MR.UMCParameters.LinearReconstruction.Goldenangle>0
             % Alternating is no
             MR.Parameter.Gridder.AlternatingRadial='no';
             
             % Reshape for reconframe reconstructions
             [ns,nl,nz,nc,ndyn]=size(MR.Data);
             MR.Data=reshape(permute(MR.Data,[1 2 5 3 4]),[ns nl*ndyn nz nc 1]);
             
             % Set golden angles
             GA=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.LinearReconstruction.Goldenangle-1));
             MR.Parameter.Gridder.RadialAngles=mod((0:GA:(nl*ndyn-1)*GA),2*pi);
             
             % Initialize reconframe gridder struct
             MR.GridderCalculateTrajectory;
             
             % Reshape back to [ns nl nz nc ndyn]
             MR.Data=permute(reshape(MR.Data,[ns nl ndyn nz nc]),[1 2 4 5 3]);
             
        else
             MR.GridderCalculateTrajectory;
        end
        
        % Create different trajectories for Fessler/Greengard gridding
        if ~strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'mrecon')
             % Get gradient delays
             if strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'smagdc')
                 MR.UMCParameters.SystemCorrections.GradientDelays=smagdc(MR.UMCParameters.SystemCorrections.CalibrationData);
             elseif strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'sweep')
                 %MR.UMCParameters.SystemCorrections.GradientDelays=SWEEP(MR);
             end

             % Calculate trajectory
             if strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'greengard');MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles-pi/2;end
             if strcmpi(MR.UMCParameters.LinearReconstruction.NUFFTMethod,'fessler');MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles-3*pi/2;end
             MR.Parameter.Gridder.Kpos=radialTRAJ(MR.Parameter.Gridder.RadialAngles,MR.UMCParameters.LinearReconstruction.KspaceSize,...
                 MR.UMCParameters.LinearReconstruction.Goldenangle,fliplr(MR.UMCParameters.SystemCorrections.GradientDelays))*...
                 MR.UMCParameters.LinearReconstruction.SpatialResolutionRatio;
             MR.Parameter.Gridder.Weights=radialDCF(MR.Parameter.Gridder.Kpos);
        end

    case 'cartesian'
             MR.GridderCalculateTrajectory;
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
