function CalculateTrajectory( MR )
% Calculate k-space trajectory analytically 

% Notification
fprintf('Calculating trajectory............................  ');tic

% Get radial angles 
radial_set_angles(MR);

% Perform gradient delay correction if required, not needed when GIRF is used!!
radial_gradient_delay_calibration(MR);
radial_gradient_delay_autocalibration(MR);

% Calculate k-space trajectory analytically, not for UTE
MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,radial_analytical_trajectory(MR.Parameter.Gridder.RadialAngles(:),MR.UMCParameters.AdjointReconstruction.KspaceSize,...
 MR.UMCParameters.AdjointReconstruction.Goldenangle,fliplr(MR.UMCParameters.SystemCorrections.GradientDelays)),'UniformOutput',false);

% Calculate k-space trajectory analytically, so not taking gradient errors into account
MR.Parameter.Gridder.Weights=radial_analytical_density(MR);


% Analytical trajectory and acquisition for radial
if strcmpi(MR.Parameter.Scan.AcqMode,'Radial') && strcmpi(MR.Parameter.Scan.UTE,'no')
    
    if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'mrecon')  % Conventional gridder
        
         if MR.UMCParameters.AdjointReconstruction.Goldenangle>0

             % Get dimensions for data handling
             dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);
             
             % Reshape for reconframe reconstructions
             for n=1:num_data;MR.Data{n}=reshape(permute(MR.Data{n},[1 2 5 3 4 6:12]),[dims{n}(1) dims{n}(2)*dims{n}(5) dims{n}(3:4) dims{n}(6:11)]);end
             
             % Set radial golden angles
             GA=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1));
             for n=1:num_data;MR.Parameter.Gridder.RadialAngles{n}=mod((0:GA:(dims{1}(2)*dims{1}(5)-1)*GA),2*pi);end
             
             % Initialize reconframe gridder struct
             if num_data==1;MR.Parameter.Gridder.RadialAngles=MR.Parameter.Gridder.RadialAngles{1};end
             MR.GridderCalculateTrajectory;
             
             % Reshape back to [ns nl nz nc ndyn .... ]
             for n=1:num_data;MR.Data{n}=permute(reshape(MR.Data{n},[dims{n}(1:2) dims{n}(5) dims{n}(3) dims{n}(4) dims{n}(6:12)]),[1 2 4 5 3 6:12]);end
         end
         
    else % Case gridding is performed with fessler or greengard
        
        if MR.UMCParameters.AdjointReconstruction.Goldenangle>0
             
             % Get dimensions for data handling
             dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);
             
             % Set radial golden angles
             GA=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1));
             for n=1:num_data;MR.Parameter.Gridder.RadialAngles{n}=reshape(mod((0:GA:(dims{n}(2)*dims{n}(5)-1)*GA),2*pi),[1 dims{n}(2) 1 1 dims{n}(5:11)]);end
        end
        
         % Get gradient delays from calibration or autocalibration
         if strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'calibration')
             MR.UMCParameters.SystemCorrections.GradientDelays=radial_delaycalibration(MR.UMCParameters.SystemCorrections.CalibrationData);
         elseif strcmpi(MR.UMCParameters.SystemCorrections.GradientDelayCorrection,'autocalibration')
             MR.UMCParameters.SystemCorrections.GradientDelays=radial_delayautocalibration(MR);
         end

         % Both gridders have a difference reference so need slightly
         % different radial angles for alignment
         if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'greengard');MR.Parameter.Gridder.RadialAngles=cellfun(@(x) mod(x-+1/2*pi,2*pi),MR.Parameter.Gridder.RadialAngles,'UniformOutput',false);end
         if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler');MR.Parameter.Gridder.RadialAngles=cellfun(@(x) mod(x+pi/2,2*pi),MR.Parameter.Gridder.RadialAngles,'UniformOutput',false);end
         
         % Calculate k-space trajectory analytically
         MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,radial_analytical_trajectory(MR.Parameter.Gridder.RadialAngles(:),MR.UMCParameters.AdjointReconstruction.KspaceSize,...
             MR.UMCParameters.AdjointReconstruction.Goldenangle,fliplr(MR.UMCParameters.SystemCorrections.GradientDelays)),'UniformOutput',false);
         
         % Calculate k-space trajectory analytically, so not taking gradient errors into account
         MR.Parameter.Gridder.Weights=radial_analytical_density(MR);

    end
elseif strcmpi(MR.Parameter.Scan.UTE,'yes')
    
    % Get dimensions for data handling
    dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);                 

    % Fill in radial angles the same for each echo for now
    for n=1:num_data;MR.Parameter.Gridder.RadialAngles{n}=(0:2*pi/(dims{n}(2)-1:2*pi);end
    for n=1:num_data;if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'greengard');MR.Parameter.Gridder.RadialAngles{n}=MR.Parameter.Gridder.RadialAngles{n}-pi/2;end;end
    for n=1:num_data;if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTMethod,'fessler');MR.Parameter.Gridder.RadialAngles{n}=MR.Parameter.Gridder.RadialAngles{n}+pi/2;end;end
    
else% Case conventional MRecon
    MR.GridderCalculateTrajectory;
end

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
