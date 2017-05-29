function radial_analytical_trajectory(MR)
% Does not work for Kooshball type of trajectories 

% Logic
if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial') || strcmpi(MR.Parameter.Scan.UTE,'yes')
    return;end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);

% Set parameters from input
for n=1:num_data
    if isempty(MR.UMCParameters.SystemCorrections.GradientDelays)
        dk{n}=0;
    else
        dk{n}=repmat(((cos(2*(MR.Parameter.Gridder.RadialAngles{n}+pi/2))+1)*varargin{1}(1)+...
            (-cos(2*(MR.Parameter.Gridder.RadialAngles{n}{n}+pi/2))+1)*varargin{1}(2))/2,[dims{n}(1) 1]);
    end
end

% Compute trajectory based on angles
for n=1:num_data

    % Calculate sampling point on horizontal spoke
    x=linspace(0,dims{n}(1)-1,dims{n}(1))'-(dims{n}(1)-1)/2;

    % Modulate the phase of all the successive spokes
    k{n}=zeros(dims{n}(1),dims{n}(2));
    for l=1:dims{n}(2)
        k{n}(:,l)=x*exp(1j*MR.Parameter.Gridder.RadialAngles{n}(l));
    end

    % Add correction based on gradient delays
    k{n}=k{n}+(-1)*dk{n};

    % Normalize
    k{n}=k{n}/dims{n}(1);
    
    % Partition into dynamics and deal with nz
    k{n}=single(repmat(k{n},[1 1 1 1 dims{n}(5) 1 1 1 1 1 1 1]));

    % Split real and imaginary parts into channels
    for n=1:num_data;
        kn{n}(1,:,:,:,:,:,:,:,:,:,:,:)=real(k{n});
        kn{n}(2,:,:,:,:,:,:,:,:,:,:,:)=imag(k{n});
        kn{n}(3,:,:,:,:,:,:,:,:,:,:,:)=zeros([size(k{n})]);
    end

end

% Apply spatial resolution factor
MR.Parameter.Gridder.Kpos=cellfun(@(x) x*MR.UMCParameters.AdjointReconstruction.SpatialResolutionRatio,...
    kn,'UniformOutput',false);

% END
end