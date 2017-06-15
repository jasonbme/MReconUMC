function w = radial_analytical_density(MR)
% Function to get analytical density functions for radial acquisitions.
% Input: Cell of k-space trajectory
% Output: Cell of density weights
% Tom Bruijnen - University Medical Center Utrecht - 201609

% Logic
if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.Parameter.Scan.UTE,'yes')
    return;end

% Get dimensionality
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;

% Set parameters from input
num_data=numel(dims);
for n=1:num_data;cp{n}=dims{n}(1)/2+1;end % k0

for n=1:num_data;
    
    % Create a Ram-Lak filter
    w{n}=ones(dims{n}(1),1);
    for i=1:dims{n}(1)
        w{n}(i)=abs(dims{n}(1)/2 - (i - .5));
    end
    w{n}=pi/(dims{n}(2)*dims{n}(5))*w{n};
    w{n}=w{n}/max(abs(w{n}(:)));
    
    % Partition into dynamics
    w{n}=repmat(w{n},[1 dims{n}(2) 1 1 dims{n}(5) 1 dims{n}(7)]);
    
end

if strcmpi(MR.UMCParameters.AdjointReconstruction.NUFFTtype,'3D')
    for n=1:num_data
        w{n}=repmat(w{n},[1 1 dims{1}(3) 1 1 1 1 1 1 1 1 1]);
    end
end

% Assign to struct
MR.Parameter.Gridder.Weights=w;

% END
end