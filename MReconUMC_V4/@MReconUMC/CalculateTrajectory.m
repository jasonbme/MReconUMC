function CalculateTrajectory( MR )
% Calculate k-space trajectory

% Notification
fprintf('Calculating trajectory............................  ');tic

% Analytical trajectory and acquisition for radial
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial') 
    
    if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')  % Conventional gridder
        
         if MR.UMCParameters.AdjointReconstruction.Goldenangle>0

             % Get dimensions for data handling
             [ns,nl,nz,nc,ndyn]=size(MR.Data);
             
             % Reshape for reconframe reconstructions
             MR.Data=reshape(permute(MR.Data,[1 2 5 3 4]),[ns nl*ndyn nz nc 1]);
             
             % Set radial golden angles
             GA=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1));
             MR.Parameter.Gridder.RadialAngles=mod((0:GA:(nl*ndyn-1)*GA),2*pi);
             
             % Initialize reconframe gridder struct
             MR.GridderCalculateTrajectory;
             
             % Reshape back to [ns nl nz nc ndyn]
             MR.Data=permute(reshape(MR.Data,[ns nl ndyn nz nc]),[1 2 4 5 3]);
             
         else
         end
         
    else % Case gridding is performed with fessler or greengard
        
        if MR.UMCParameters.AdjointReconstruction.Goldenangle>0
             
             % Get dimensions for data handling
             [~,nl,~,~,ndyn]=size(MR.Data);
             
             % Set radial golden angles
             GA=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1));
             MR.Parameter.Gridder.RadialAngles=mod((0:GA:(nl*ndyn-1)*GA),2*pi);
        end
        
         % Get gradient delays from calibration or autocalibration
         if strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'calibration')
             MR.UMCParameters.SystemCorrections.GradientDelays=radial_delaycalibration(MR.UMCParameters.SystemCorrections.CalibrationData);
         elseif strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'autocalibration')
             MR.UMCParameters.SystemCorrections.GradientDelays=radial_delayautocalibration(MR);
         end

         % Both gridders have a difference reference so need slightly
         % different radial angles for alignment
         if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'greengard');MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles-pi/2;end
         if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler');MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles-3*pi/2;end
         
         % Calculate k-space trajectory analytically
         MR.Parameter.Gridder.Kpos=radial_trajectory(MR.Parameter.Gridder.RadialAngles,MR.UMCParameters.AdjointReconstruction.KspaceSize,...
             MR.UMCParameters.AdjointReconstruction.Goldenangle,fliplr(MR.UMCParameters.SystemCorrections.GradientDelays))*...
             MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio;
         
         % Calculate k-space trajectory analytically, so not taking gradient delays into account
         MR.Parameter.Gridder.Weights=radial_dcf(MR.Parameter.Gridder.Kpos);

    end
else % Case conventional MRecon
    MR.GridderCalculateTrajectory;
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
