function CalculateTrajectory( MR )
% Calculate k-space trajectory analytically 

% Notification
fprintf('Calculating trajectory............................  ');tic

% Get radial angles 
radial_set_angles(MR);

% Perform gradient delay correction if required, not needed when GIRF is used!!
radial_gradient_delay_calibration(MR);
radial_gradient_delay_autocalibration(MR);

% Calculate k-space trajectory analytically, not for UTE!
radial_analytical_trajectory(MR);

% Calculate Ram-lak density function
radial_analytical_density(MR);

% Notification
fprintf('Finished [%.2f sec] \n',toc')

% END
end
