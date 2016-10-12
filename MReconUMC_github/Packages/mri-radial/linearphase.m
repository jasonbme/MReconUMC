function phase_kdata = linearphase(kdata,ktraj,varargin )
% Add a sinusoidal varying absolute phase to every spoke

% Get radial angles from the trajectory
angles=angle(ktraj(1,:));

% Create model from "Correction of gradient-induced phase errors in radial MRI" 
% Set parameters for the model according to input or default.
if numel(varargin)>0
    if numel(varargin)==1
        psi_x=varargin{1};
        psi_y=psi_x;
    else
        psi_x=varargin{1};
        psi_y=varargin{2};
    end
else
    psi_x=2.3;
    psi_y=1.8;
end
psi_0=1.7453; 
phi=@(theta)(psi_x*cos(theta)+psi_y*sin(theta)+psi_0);
d_phase=phi(angles);

% Add the phases 
for nl=1:size(kdata,2) % Loop over spokes
    phase_kdata(:,nl)=kdata(:,nl)*exp(-1j*d_phase(nl));
end

% END
end