function CalculateTrajectoryAndDensity( MR )
%Calculate k-space trajectory and density compensation. 
% All functions below have build-in checks whether they are applicable,
% e.g. radial_set_angles only runs when imaging mode = radial.
% So far this is only implemented for radial sampling. Radial angle order
% is determined from PPE parameters which runs for various patches.
% Furthermore it has the option to calculate gradient delays and process 
% them in the trajectory (note that these barely make a difference on 
% Philips systems). MR.UMCParameters.SystemCorrections.GradientDelayCorrection 
% controls this option. When GIRF is enabled the trajectory can be
% estimated from the PPE objects, this only works for radial and epi sofar.
%
% 20170717 - T.Bruijnen

%% Logic & display
% Notification
fprintf('Calculating trajectory............................  ');tic

%% CalculateTrajectory
% Get radial angles 
radial_set_angles(MR);

% Perform gradient delay correction if required, not needed when GIRF is used!!
radial_gradient_delay_calibration(MR);
radial_gradient_delay_autocalibration(MR);

% Calculate k-space trajectory analytically, not for UTE!
radial_analytical_trajectory(MR);

% Calculate Ram-lak density function
radial_analytical_density(MR);

% Calculate trajectory for Cartesian
cartesian_analytical_trajectory(MR);

% Use PPE GR` objects to compute trajectory and apply GIRF
gradient_impulse_response_function(MR);

%% Display 
% Notification
if strcmpi(MR.UMCParameters.SystemCorrections.Girf,'no');fprintf('Finished [%.2f sec] \n',toc');end

% END
end
