function radial_set_angles(MR)
% Function permute/reshapes the data and set radial angles for the nufft
% Todo: Add Kooshball trajectories

% Logic
if ~strcmpi(MR.Parameter.Scan.AcqMode,'Radial')
	return;end

% Get dimensions for data handling
dims=MR.UMCParameters.AdjointReconstruction.KspaceSize;num_data=numel(MR.Data);

% Set radial angles profile ordering for all data chunks
for n=1:num_data;

	% Golden angle spacing
	if MR.UMCParameters.AdjointReconstruction.Goldenangle>0
        d_angle=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1));
        MR.Parameter.Gridder.RadialAngles{n}=mod((0:d_angle:(dims{n}(2)*dims{n}(5)-1)*d_angle),2*pi);
        MR.Parameter.Gridder.RadialAngles{n}=reshape(mod((0:d_angle:(dims{n}(2)*dims{n}(5)-1)*d_angle),2*pi),[1 dims{n}(2) 1 1 dims{n}(5) 1 1 1 1 1 1]);
        MR.Parameter.Gridder.RadialAngles{n}=repmat(MR.Parameter.Gridder.RadialAngles{n},[1 1 1 1 1 1 dims{n}(7) 1 1 1 1 1]);end

	% Uniform radial linear spacing 
	if MR.UMCParameters.AdjointReconstruction.Goldenangle==0;d_angle=pi/(dims{n}(2));
        MR.Parameter.Gridder.RadialAngles{n}=mod((0:d_angle:(dims{n}(2)-1)*d_angle),2*pi);
        MR.Parameter.Gridder.RadialAngles{n}=repmat(MR.Parameter.Gridder.RadialAngles{n},[1 1 1 1 dims{n}(5) 1 dims{n}(7) 1 1 1 1 1]);
        if strcmpi(MR.Parameter.Gridder.AlternatingRadial,'yes');MR.Parameter.Gridder.RadialAngles{n}(:,2:2:end,:,:,:,:,:,:,:,:,:)=...
                mod(MR.Parameter.Gridder.RadialAngles{n}(:,2:2:end,:,:,:,:,:,:,:,:,:)+pi,2*pi);end;end

    % Angle spacing for UTE sequences, uniform for now
    if strcmpi(MR.Parameter.Scan.UTE,'yes') && MR.UMCParameters.AdjointReconstruction.Goldenangle==0;d_angle=2*pi/dims{n}(2);
       MR.Parameter.Gridder.RadialAngles{n}=mod((0:d_angle:(dims{n}(2)-1)*d_angle),2*pi);
       MR.Parameter.Gridder.RadialAngles{n}=repmat(MR.Parameter.Gridder.RadialAngles{n},[1 1 1 1 dims{n}(5) 1 dims{n}(7) 1 1 1 1 1]);end
 
	% Fingerprinting enabled requires a fixed configuration of radial angles 
    if strcmpi(MR.UMCParameters.Fingerprinting.Fingerprinting,'yes')
        d_angle=(pi/(((1+sqrt(5))/2)+MR.UMCParameters.AdjointReconstruction.Goldenangle-1)); % angle increment in time
        u_angle=2*pi/dims{n}(2); % Uniform angle increment across single timepoint
        MR.Parameter.Gridder.RadialAngles{n}=permute(repmat(mod((0:d_angle:(dims{n}(5)-1)*d_angle),2*pi),[dims{n}(2) 1 1 1 1 1 1 1 1 1 1 1]),[3 1 4 5 2]);
        MR.Parameter.Gridder.RadialAngles{n}=MR.Parameter.Gridder.RadialAngles{n}+repmat((0:u_angle:(dims{n}(2)-1)*u_angle),[1 1 1 1 dims{n}(5) 1 1 1 1 1 1]);
    end

	% Both gridders have a different reference, so they need slight modifications of the angles
    %if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard') && strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'3D');MR.Parameter.Gridder.RadialAngles{n}=mod(MR.Parameter.Gridder.RadialAngles{n}+pi/2,2*pi);end
    %if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard') && strcmpi(MR.UMCParameters.AdjointReconstruction.NufftType,'2D');MR.Parameter.Gridder.RadialAngles{n}=mod(MR.Parameter.Gridder.RadialAngles{n}-pi/2,2*pi);end
    %if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'fessler');MR.Parameter.Gridder.RadialAngles{n}=mod(MR.Parameter.Gridder.RadialAngles{n}+pi/2,2*pi);end
    %if strcmpi(MR.UMCParameters.AdjointReconstruction.NufftSoftware,'greengard');MR.Parameter.Gridder.RadialAngles{n}=mod(MR.Parameter.Gridder.RadialAngles{n}+pi,2*pi);end
    MR.Parameter.Gridder.RadialAngles{n}=mod(MR.Parameter.Gridder.RadialAngles{n},2*pi);
end

% END
end
